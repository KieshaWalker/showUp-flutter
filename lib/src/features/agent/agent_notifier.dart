// agent_notifier.dart — Rule-based assistant with intent routing + fuzzy matching.
//
// No external AI API. Uses keyword detection, regex parsing, and fuzzy string
// matching to understand intent and act directly via the app's own notifiers.
//
// AgentState:
//   messages — chat history for the current session
//   loading  — true while handling (500ms think delay)
//
// Private field (_pending):
//   Holds a multi-step action awaiting user input (disambiguation, delete confirm).
//   Checked at the top of every _handle() call. Not in AgentState — the UI
//   doesn't need to observe it.
//
// Intent routing (priority order):
//   1.  Pending resolution   — disambiguation / confirmation from previous turn
//   2.  Greeting + recall    — hello, hi, hey
//   3.  Day self-rating      — "rate my day 7", "feeling a 6"
//   4.  Substance logging    — "had alcohol", "used weed last night"
//   5.  Daily summary        — "how am I doing", "summary"
//   6.  Remaining habits     — "what's left", "remaining habits"
//   7.  Water logging        — "drank 500ml", "2 cups water"
//   8.  Create meal          — "add breakfast" (no food/macros)
//   9.  Add habit            — "add habit yoga", "new habit run 3x a week"
//   10. Delete habit         — "delete habit yoga"
//   11. Habit toggle         — "done yoga", "didn't do yoga"
//          + negation guard  — flips direction when not/didn't/never detected
//          + disambiguation  — prompts when two matches are within 0.15
//   12. Meal query           — "what did I eat for lunch?"
//   13. Nutrition query      — "calories today", "my macros"
//   14. Add food to meal     — "add chicken 300 cal 30g protein to lunch"
//   15. Pantry search        — "find chicken", "macros for oats"
//   16. Fallback
//
// Connections:
//   habits_notifier.dart    — toggle, add, delete habits
//   nutrition_notifier.dart — meals, food entries, water, totals
//   pantry_notifier.dart    — pantry search
//   readiness_notifier.dart — log substances, submit self-rating
//   supabase (direct)       — write/read agent_memories

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:string_similarity/string_similarity.dart';
import '../habits/habits_notifier.dart';
import '../nutrition/nutrition_notifier.dart';
import '../pantry/pantry_notifier.dart';
import '../readiness/readiness_notifier.dart';

// ---------------------------------------------------------------------------
// Multi-step pending action
// ---------------------------------------------------------------------------

class _Pending {
  final String type; // 'hab_disambig' | 'hab_delete_confirm'
  final Map<String, dynamic> data;
  const _Pending(this.type, this.data);
}

// ---------------------------------------------------------------------------
// Provider + data models
// ---------------------------------------------------------------------------

final agentProvider = NotifierProvider<AgentNotifier, AgentState>(
  AgentNotifier.new,
);

class AgentMessage {
  final String text;
  final bool isUser;
  const AgentMessage({required this.text, required this.isUser});
}

class AgentState {
  final List<AgentMessage> messages;
  final bool loading;

  const AgentState({required this.messages, this.loading = false});

  AgentState copyWith({List<AgentMessage>? messages, bool? loading}) =>
      AgentState(
        messages: messages ?? this.messages,
        loading: loading ?? this.loading,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AgentNotifier extends Notifier<AgentState> {
  @override
  AgentState build() => const AgentState(messages: []);

  final _supabase = Supabase.instance.client;
  _Pending? _pending;

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final history = List<AgentMessage>.unmodifiable(state.messages);
    state = state.copyWith(
      messages: [...state.messages, AgentMessage(text: trimmed, isUser: true)],
      loading: true,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    final response = await _handle(trimmed, history: history);

    state = state.copyWith(
      messages: [
        ...state.messages,
        AgentMessage(text: response, isUser: false),
      ],
      loading: false,
    );

    await _saveMemory(
      content: trimmed,
      type: 'chat_log',
      question: trimmed,
      answer: response,
    );
  }

  // ── Intent router ──────────────────────────────────────────────────────────

  Future<String> _handle(String raw, {required List<AgentMessage> history}) async {
    final input = raw.toLowerCase().trim();

    // 1. Resolve pending multi-step action
    if (_pending != null) {
      final resolved = await _resolvePending(input);
      if (resolved != null) return resolved;
      _pending = null; // unrecognised reply — abandon pending, fall through
    }

    // 2. Greeting
    if (_matches(input, ['hello', 'hi', 'hey', 'greetings'])) {
      final name =
          _supabase.auth.currentUser?.userMetadata?['username'] ?? 'there';
      if (history.isNotEmpty) {
        return 'Hey $name! What else can I help with?';
      }
      final last = await _recallLastContext();
      return last != null
          ? 'Hello, $name!\nLast time: "$last". How\'s it going?'
          : 'Hello, $name! How can I help today?';
    }

    // 3. Day self-rating
    if (_matches(input, ['rate my day', 'day rating', 'day was a', "i'd give", 'feeling a']) ||
        RegExp(r'\brate\s+(?:my\s+)?day\b|\btoday\s+(?:was\s+)?\d').hasMatch(input)) {
      return await _handleRateDay(input);
    }

    // 4. Substance logging — try; if no substance matched, fall through
    if (_matches(input, ['had', 'used', 'took', 'consumed', 'smoked', 'vaped'])) {
      final result = await _handleLogSubstance(input);
      if (result != null) return result;
    }
    // "logged [substance]" — separate check so "logged water" falls through
    if (_matches(input, ['logged']) && !input.contains('water')) {
      final result = await _handleLogSubstance(input);
      if (result != null) return result;
    }

    // 5. Daily summary
    if (_matches(input, ['summary', 'overview', 'how am i', "how's my", 'am i doing'])) {
      return input.contains('habit')
          ? _handleHabitProgress()
          : await _handleDailySummary();
    }

    // 6. Remaining habits
    if (_matches(input, ['remaining', "what's left", 'still need', 'not done', 'incomplete', 'left to do'])) {
      return _handleRemainingHabits();
    }

    // 7. Water logging
    final hasNumber = RegExp(r'\d').hasMatch(input);
    if (_matches(input, ['ml', 'litre', 'liter', 'oz']) ||
        (input.contains('water') && hasNumber) ||
        (input.contains('cup') && hasNumber) ||
        (input.contains('drank') && hasNumber)) {
      return await _handleLogWater(input);
    }

    // 8. Create standalone meal (no food/calorie info)
    if (_matches(input, ['breakfast', 'lunch', 'dinner', 'snack', 'brunch']) &&
        _matches(input, ['add', 'new', 'start', 'create', 'log']) &&
        !hasNumber) {
      return await _handleCreateMeal(raw);
    }

    // 9. Add habit
    if (_matches(input, ['add habit', 'new habit', 'create habit', 'track habit', 'start habit'])) {
      return await _handleAddHabit(raw);
    }

    // 10. Delete habit
    if (_matches(input, ['delete habit', 'remove habit', 'stop tracking', 'delete my habit'])) {
      return _handleDeleteHabit(input);
    }

    // 11. Habit toggle (with negation guard)
    if (_matches(input, ['done', 'complete', 'completed', 'finish', 'finished', 'did',
        'checked', 'ticked', 'undo', "didn't", 'didnt', 'did not', "haven't", 'havent'])) {
      final isExplicitUndo = _matches(input,
          ['undo', 'remove', "didn't", 'didnt', 'did not', "haven't", 'havent', 'mark undone']);
      final markDone = isExplicitUndo ? false : !_hasNegation(input);
      return _handleHabitToggle(input, markDone: markDone);
    }

    // 12. Meal query
    if (_matches(input, ['what did i eat', 'show me', 'show breakfast', 'show lunch',
        'show dinner', "what's in my", 'what was in'])) {
      return _handleMealQuery(input);
    }

    // 13. Nutrition query
    if (_matches(input, ['eat', 'calories', 'macros', 'nutrition', 'food', 'protein', 'carbs', 'fat'])) {
      return await _handleNutritionSummary();
    }

    // 14. Add food to meal
    if (_matches(input, ['add', 'log']) &&
        (hasNumber || _matches(input, ['to breakfast', 'to lunch', 'to dinner', 'to snack', 'to my meal']))) {
      return await _handleAddFoodEntry(raw);
    }

    // 15. Pantry search
    if (_matches(input, ['find', 'search', 'look up', 'macros for', 'what is in', 'calories in'])) {
      return _handlePantrySearch(input);
    }

    // 16. Fallback
    return 'I can help with:\n'
        '• Habits: "done yoga" / "didn\'t do run" / "add habit meditate"\n'
        '• Food: "what did I eat for lunch?" / "add eggs 140 cal to breakfast"\n'
        '• Water: "drank 500ml"\n'
        '• Substances: "had alcohol last night"\n'
        '• Rate your day: "rate my day 7"\n'
        '• Summary: "how am I doing?"';
  }

  // ── Pending resolution ─────────────────────────────────────────────────────

  Future<String?> _resolvePending(String input) async {
    final p = _pending!;

    if (p.type == 'hab_disambig') {
      final options = p.data['options'] as List<String>;
      final markDone = p.data['markDone'] as bool;

      if (input == '1' || input.startsWith('first') || input.startsWith('1.')) {
        _pending = null;
        return _toggleHabit(options[0], markDone: markDone);
      }
      if (input == '2' || input.startsWith('second') || input.startsWith('2.')) {
        _pending = null;
        return _toggleHabit(options[1], markDone: markDone);
      }
      if (_matches(input, ['cancel', 'never mind', 'nevermind', 'stop', 'no'])) {
        _pending = null;
        return 'Cancelled.';
      }
      // Try to match by partial name
      final nameMatch = options.firstWhere(
        (o) =>
            o.contains(input.split(' ').first) ||
            input.contains(o.split(' ').first),
        orElse: () => '',
      );
      if (nameMatch.isNotEmpty) {
        _pending = null;
        return _toggleHabit(nameMatch, markDone: markDone);
      }
      return 'Reply "1" for ${_capitalize(options[0])}, "2" for ${_capitalize(options[1])}, or "cancel".';
    }

    if (p.type == 'hab_delete_confirm') {
      final habitId = p.data['habitId'] as String;
      final habitName = p.data['habitName'] as String;
      _pending = null;
      if (_matches(input, ['yes', 'confirm', 'delete it', 'do it', 'yeah', 'yep', 'sure'])) {
        await ref.read(habitsNotifierProvider.notifier).deleteHabit(habitId);
        return 'Deleted "$habitName" and all its history.';
      }
      return 'Cancelled — "$habitName" is still here.';
    }

    return null;
  }

  // ── Habit toggle ───────────────────────────────────────────────────────────

  String _handleHabitToggle(String input, {required bool markDone}) {
    final habits = ref.read(habitsNotifierProvider).value ?? [];
    if (habits.isEmpty) return "You don't have any habits set up yet.";

    // Strip all action/direction/filler words to isolate the habit name
    final stripped = input
        .replaceAll(
          RegExp(
            r"\b(mark|done|undo|didn'?t|did\s+not|did|my|finish|complete|"
            r"finished|absolutely|not|never|haven'?t|remove|i|a|the|today|"
            r"for|just|already|habit|completed|completion|check(?:ed)?|tick(?:ed)?)\b",
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (stripped.isEmpty) {
      return "Which habit? Try \"done yoga\" or \"didn't do run\".";
    }

    final habitNames = habits.map((h) => h.habit.name.toLowerCase()).toList();
    final result = stripped.bestMatch(habitNames);
    final ratings = result.ratings
        .where((r) => r.rating! >= 0.35)
        .toList()
      ..sort((a, b) => b.rating!.compareTo(a.rating!));

    // Disambiguation: two candidates too close to call
    if (ratings.length >= 2 && (ratings[0].rating! - ratings[1].rating!) < 0.15) {
      _pending = _Pending('hab_disambig', {
        'options': [ratings[0].target!, ratings[1].target!],
        'markDone': markDone,
      });
      return 'Did you mean:\n  1. ${_capitalize(ratings[0].target!)}\n  2. ${_capitalize(ratings[1].target!)}\nReply "1" or "2".';
    }

    if (ratings.isEmpty) {
      final examples = habitNames.take(3).map(_capitalize).join(', ');
      return "Couldn't find a habit like \"$stripped\". Your habits: $examples.";
    }

    return _toggleHabit(ratings[0].target!, markDone: markDone);
  }

  String _toggleHabit(String lowerName, {required bool markDone}) {
    final habits = ref.read(habitsNotifierProvider).value ?? [];
    final matches = habits.where((h) => h.habit.name.toLowerCase() == lowerName).toList();
    if (matches.isEmpty) return "Couldn't find that habit.";
    final match = matches.first;
    if (markDone && match.completedToday) return '"${match.habit.name}" is already marked done.';
    if (!markDone && !match.completedToday) return '"${match.habit.name}" isn\'t marked done yet.';
    ref.read(habitsNotifierProvider.notifier).toggleCompletion(match.habit.id);
    return markDone
        ? '✓ "${match.habit.name}" marked done!'
        : '↩ Removed completion for "${match.habit.name}".';
  }

  // ── Add habit ──────────────────────────────────────────────────────────────

  Future<String> _handleAddHabit(String raw) async {
    // Remove trigger phrase, preserve case for the habit name
    String cleaned = raw
        .replaceAll(
            RegExp(r'\b(add|new|create|track|start)\s+habit\b',
                caseSensitive: false),
            '')
        .replaceAll(
            RegExp(r'\b(daily|every\s+day|each\s+day)\b',
                caseSensitive: false),
            '')
        .trim();

    // Parse "X times a week" / "Xx/week"
    final weeklyRx = RegExp(
        r'(\d+)\s*(?:times?\s*(?:a|per)\s*week|x\s*(?:a|per)?\s*week|×\s*week)',
        caseSensitive: false);
    final weeklyMatch = weeklyRx.firstMatch(cleaned);
    final targetDays = weeklyMatch != null ? int.parse(weeklyMatch.group(1)!) : null;

    final name = cleaned.replaceAll(weeklyMatch?.group(0) ?? '', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (name.isEmpty) return 'What should I call the habit? Try "add habit meditate".';

    await ref.read(habitsNotifierProvider.notifier).addHabit(
          name,
          frequencyType: targetDays != null ? 'weekly' : 'daily',
          targetDaysPerWeek: targetDays ?? 7,
        );

    return targetDays != null
        ? '+ Added "$name" — weekly, $targetDays× per week.'
        : '+ Added "$name" — daily.';
  }

  // ── Delete habit ───────────────────────────────────────────────────────────

  String _handleDeleteHabit(String input) {
    final habits = ref.read(habitsNotifierProvider).value ?? [];
    if (habits.isEmpty) return "You don't have any habits to delete.";

    final stripped = input
        .replaceAll(
            RegExp(r'\b(delete|remove|stop\s+tracking|delete\s+my)\s+habit\b',
                caseSensitive: false),
            '')
        .trim();

    if (stripped.isEmpty) return 'Which habit should I delete?';

    final habitNames = habits.map((h) => h.habit.name.toLowerCase()).toList();
    final result = stripped.bestMatch(habitNames);
    if (result.bestMatch.rating! < 0.35) {
      return 'Couldn\'t find a habit like "$stripped".';
    }

    final match = habits.firstWhere(
        (h) => h.habit.name.toLowerCase() == result.bestMatch.target!);
    _pending = _Pending('hab_delete_confirm', {
      'habitId': match.habit.id,
      'habitName': match.habit.name,
    });
    return 'Delete "${match.habit.name}" and all its history? Reply "yes" to confirm.';
  }

  // ── Log substance ──────────────────────────────────────────────────────────

  Future<String?> _handleLogSubstance(String input) async {
    final substances = ref.read(userSubstancesProvider).value ?? [];
    if (substances.isEmpty) return null;

    final isYesterday = RegExp(
            r'\b(last\s+night|yesterday|last\s+evening|prev\w*)\b',
            caseSensitive: false)
        .hasMatch(input);
    final date =
        isYesterday ? DateTime.now().subtract(const Duration(days: 1)) : null;

    // Strip logging verbs + time words to isolate the substance name
    final stripped = input
        .replaceAll(
          RegExp(
            r'\b(had|used|took|consumed|smoked|vaped|logged|some|a\b|bit\s+of|'
            r'last\s+night|yesterday|tonight|today|last\s+evening|earlier|just)\b',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (stripped.isEmpty) return null;

    final substanceNames = substances.map((s) => s.name.toLowerCase()).toList();

    // Substring match first (catches short names like "weed", "cbd", "alcohol")
    final substrMatch = substanceNames.firstWhere(
      (n) =>
          stripped.contains(n) ||
          n.split(' ').any((word) => word.length > 2 && stripped.contains(word)),
      orElse: () => '',
    );

    // Fuzzy fallback
    final fuzzyResult = stripped.bestMatch(substanceNames);
    final fuzzyMatch = fuzzyResult.bestMatch.rating! >= 0.4
        ? fuzzyResult.bestMatch.target!
        : null;

    final matchedName = substrMatch.isNotEmpty ? substrMatch : fuzzyMatch;
    if (matchedName == null) return null;

    final substance =
        substances.firstWhere((s) => s.name.toLowerCase() == matchedName);
    await ref.read(substanceLogsProvider.notifier).logSubstance(
          substanceName: substance.name,
          direction: substance.direction,
          impactSnapshot: substance.learnedImpact ?? substance.defaultImpact,
          date: date,
        );

    final when = isYesterday ? 'yesterday' : 'today';
    final dir = substance.direction == 'positive' ? '+' : '−';
    final impact =
        (substance.learnedImpact ?? substance.defaultImpact).toStringAsFixed(1);
    return 'Logged ${substance.name} for $when ($dir$impact/10).';
  }

  // ── Rate day ───────────────────────────────────────────────────────────────

  Future<String> _handleRateDay(String input) async {
    final numMatch = RegExp(r'\b([0-9]|10)\b').firstMatch(input);
    if (numMatch == null) return 'What score? Try "rate my day 7" (0–10).';
    final rating = double.parse(numMatch.group(1)!).clamp(0.0, 10.0);
    await ref.read(readinessProvider.notifier).submitSelfRating(rating);
    return 'Rated ${rating.toStringAsFixed(0)}/10 — readiness learning updated.';
  }

  // ── Create meal ────────────────────────────────────────────────────────────

  Future<String> _handleCreateMeal(String raw) async {
    // Extract meal name — first meal keyword found
    for (final keyword in ['breakfast', 'lunch', 'dinner', 'snack', 'brunch']) {
      if (raw.toLowerCase().contains(keyword)) {
        final mealName = '${keyword[0].toUpperCase()}${keyword.substring(1)}';
        await ref.read(nutritionNotifierProvider.notifier).addMeal(mealName);
        return '+ Created "$mealName". Now try "add eggs 140 cal 12g protein to $keyword".';
      }
    }
    return 'Which meal? Try "add breakfast" or "add lunch".';
  }

  // ── Add food entry ─────────────────────────────────────────────────────────

  Future<String> _handleAddFoodEntry(String raw) async {
    final input = raw.toLowerCase();

    // Parse macros
    double cal = 0, protein = 0, carbs = 0, fat = 0;
    final calRx    = RegExp(r'(\d+(?:\.\d+)?)\s*(?:cal(?:ories?)?|kcal)');
    final proRx    = RegExp(r'(\d+(?:\.\d+)?)\s*g?\s*pro(?:tein)?');
    final carbRx   = RegExp(r'(\d+(?:\.\d+)?)\s*g?\s*carbs?');
    final fatRx    = RegExp(r'(\d+(?:\.\d+)?)\s*g?\s*fat');
    final calMatch  = calRx.firstMatch(input);
    final proMatch  = proRx.firstMatch(input);
    final carbMatch = carbRx.firstMatch(input);
    final fatMatch  = fatRx.firstMatch(input);
    if (calMatch  != null) cal     = double.parse(calMatch.group(1)!);
    if (proMatch  != null) protein = double.parse(proMatch.group(1)!);
    if (carbMatch != null) carbs   = double.parse(carbMatch.group(1)!);
    if (fatMatch  != null) fat     = double.parse(fatMatch.group(1)!);

    // Extract target meal from "to [meal name]" at end of string
    final toMatch = RegExp(r'\bto\s+([\w\s]+?)(?:\s*$)', caseSensitive: false)
        .firstMatch(raw);
    final targetMeal = toMatch?.group(1)?.trim().toLowerCase();

    // Isolate food name: remove trigger words, macros, and "to [meal]"
    String foodName = raw
        .replaceAll(RegExp(r'\b(?:add|log)\b', caseSensitive: false), '')
        .replaceAll(calMatch?.group(0) ?? r'(?!)', '')
        .replaceAll(proMatch?.group(0) ?? r'(?!)', '')
        .replaceAll(carbMatch?.group(0) ?? r'(?!)', '')
        .replaceAll(fatMatch?.group(0) ?? r'(?!)', '')
        .replaceAll(RegExp(r'\bto\s+[\w\s]+$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (foodName.isEmpty) {
      return 'What food? Try "add 2 eggs 140 cal 12g protein to breakfast".';
    }

    // Find or create target meal
    final nutrition = ref.read(nutritionNotifierProvider).value;
    String mealId;

    if (nutrition != null && nutrition.meals.isNotEmpty) {
      if (targetMeal != null) {
        final meal = nutrition.meals.firstWhere(
          (m) => m.meal.name.toLowerCase().contains(targetMeal),
          orElse: () => nutrition.meals.last,
        );
        mealId = meal.meal.id;
      } else {
        mealId = nutrition.meals.last.meal.id;
      }
    } else {
      final mealName = targetMeal != null
          ? '${targetMeal[0].toUpperCase()}${targetMeal.substring(1)}'
          : 'Meal';
      mealId =
          await ref.read(nutritionNotifierProvider.notifier).addMeal(mealName);
    }

    await ref.read(nutritionNotifierProvider.notifier).addFoodEntry(
          mealId: mealId,
          name: foodName,
          calories: cal,
          protein: protein,
          carbs: carbs,
          fat: fat,
        );

    return '+ "$foodName" added — ${cal.toInt()} kcal | P: ${protein.toInt()}g C: ${carbs.toInt()}g F: ${fat.toInt()}g.';
  }

  // ── Meal query ─────────────────────────────────────────────────────────────

  String _handleMealQuery(String input) {
    final nutrition = ref.read(nutritionNotifierProvider).value;
    if (nutrition == null || nutrition.meals.isEmpty) {
      return 'Nothing logged today yet.';
    }

    // Look for a specific meal name
    for (final keyword in ['breakfast', 'lunch', 'dinner', 'snack', 'brunch']) {
      if (input.contains(keyword)) {
        final meals = nutrition.meals
            .where((m) => m.meal.name.toLowerCase().contains(keyword))
            .toList();
        if (meals.isEmpty) return 'No $keyword logged today.';
        return meals.map(_formatMeal).join('\n\n');
      }
    }

    // Show all
    return nutrition.meals.map(_formatMeal).join('\n\n');
  }

  String _formatMeal(MealWithEntries m) {
    final items = m.entries.isEmpty
        ? '  (no items)'
        : m.entries
            .map((e) => '  • ${e.name} — ${e.calories.toInt()} kcal')
            .join('\n');
    return '${m.meal.name} — ${m.calories.toInt()} kcal total\n$items';
  }

  // ── Remaining habits ───────────────────────────────────────────────────────

  String _handleRemainingHabits() {
    final habits = ref.read(habitsNotifierProvider).value ?? [];
    final remaining = habits.where((h) => !h.isDone).toList();
    if (remaining.isEmpty) return 'All habits done — great work!';
    final list = remaining.map((h) => '○ ${h.habit.name}').join('\n');
    return 'Still to do (${remaining.length}):\n$list';
  }

  // ── Pantry search ──────────────────────────────────────────────────────────

  String _handlePantrySearch(String input) {
    const stopWords = {
      'find', 'search', 'for', 'what', 'is', 'calories', 'in',
      'macros', 'look', 'up', 'the',
    };
    final query = input
        .split(' ')
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .join(' ')
        .trim();

    final pantry = ref.read(pantryNotifierProvider).value ?? [];
    final results =
        pantry.where((f) => f.name.toLowerCase().contains(query)).toList();

    if (results.isEmpty) return 'No foods found matching "$query".';
    final lines = results
        .take(3)
        .map((f) =>
            '• ${f.name}: ${f.calories.toInt()} kcal | P: ${f.protein.toInt()}g C: ${f.carbs.toInt()}g F: ${f.fat.toInt()}g')
        .join('\n');
    return 'Found:\n$lines';
  }

  // ── Water logging ──────────────────────────────────────────────────────────

  Future<String> _handleLogWater(String input) async {
    final numMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(input);
    if (numMatch == null) return 'How much? Try "drank 500ml".';

    double ml = double.parse(numMatch.group(1)!);
    if (RegExp(r'\b(litre|liter|l\b)').hasMatch(input)) {
      ml *= 1000;
    } else if (input.contains('cup') || input.contains('glass')) {
      ml *= 240;
    } else if (input.contains('oz')) {
      ml *= 29.6;
    }

    await ref.read(nutritionNotifierProvider.notifier).logWater(ml);
    final label = ml >= 1000
        ? '${(ml / 1000).toStringAsFixed(1)}L'
        : '${ml.toInt()}ml';
    return '💧 Logged $label.';
  }

  // ── Summaries ──────────────────────────────────────────────────────────────

  Future<String> _handleNutritionSummary() async {
    final n = ref.read(nutritionNotifierProvider).value;
    if (n == null) return 'Loading...';
    final goals = n.goals;
    final calStr = goals != null
        ? '${n.totalCalories.toInt()} / ${goals.calories.toInt()} kcal'
        : '${n.totalCalories.toInt()} kcal';
    return 'Today: $calStr\n'
        'P: ${n.totalProtein.toInt()}g  C: ${n.totalCarbs.toInt()}g  F: ${n.totalFat.toInt()}g\n'
        'Water: ${(n.totalWaterMl / 1000).toStringAsFixed(1)}L';
  }

  String _handleHabitProgress() {
    final habits = ref.read(habitsNotifierProvider).value ?? [];
    if (habits.isEmpty) return 'No habits set up yet.';
    final done = habits.where((h) => h.isDone).length;
    final doneLines = habits
        .where((h) => h.isDone)
        .map((h) => '✓ ${h.habit.name}')
        .join('\n');
    final todoLines = habits
        .where((h) => !h.isDone)
        .map((h) => '○ ${h.habit.name}')
        .join('\n');
    final lines = [doneLines, todoLines].where((s) => s.isNotEmpty).join('\n');
    return 'Habits: $done / ${habits.length}\n$lines';
  }

  Future<String> _handleDailySummary() async {
    final habits = _handleHabitProgress();
    final nutrition = await _handleNutritionSummary();
    return '$habits\n\n$nutrition';
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool _matches(String input, List<String> keywords) {
    final lower = input.toLowerCase();
    return keywords.any((k) {
      if (k.contains(' ')) return lower.contains(k.toLowerCase());
      return RegExp(
        '\\b${RegExp.escape(k.toLowerCase())}\\b',
        caseSensitive: false,
      ).hasMatch(lower);
    });
  }

  bool _hasNegation(String input) => RegExp(
        r"\b(not|never|didn'?t|did\s+not|haven'?t|have\s+not|couldn'?t|won'?t)\b",
        caseSensitive: false,
      ).hasMatch(input);

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  // ── Memory ─────────────────────────────────────────────────────────────────

  Future<void> _saveMemory({
    required String content,
    required String type,
    required String question,
    required String answer,
    String? habitId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _supabase.from('agent_memories').insert({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': user.id,
        'content': content,
        'type': type,
        'source': 'agent',
        'most_recent_question': question,
        'most_recent_answer': answer,
        'related_habit_id': habitId,
        'synced': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<String?> _recallLastContext() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    try {
      final data = await _supabase
          .from('agent_memories')
          .select('most_recent_answer')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return data?['most_recent_answer'] as String?;
    } catch (_) {
      return null;
    }
  }
}
