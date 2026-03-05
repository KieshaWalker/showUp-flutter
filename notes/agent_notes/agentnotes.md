

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:string_similarity/string_similarity.dart'; // Add this to pubspec.yaml

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AgentNotifier extends Notifier<AgentState> {
  @override
  AgentState build() => const AgentState(messages: []);

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      messages: [...state.messages, AgentMessage(text: trimmed, isUser: true)],
      loading: true,
    );

    // Small delay to make it feel "real"
    await Future.delayed(const Duration(milliseconds: 400));
    final response = await _handle(trimmed.toLowerCase());

    state = state.copyWith(
      messages: [...state.messages, AgentMessage(text: response, isUser: false)],
      loading: false,
    );
  }

  Future<String> _handle(String input) async {
    // 1. High-Priority Overlays (Summary/Progress)
    if (_matches(input, ['how am i', 'summary', 'overview', 'progress', 'status'])) {
      if (input.contains('habit')) return _handleHabitProgress();
      return await _handleDailySummary();
    }

    // 2. Nutrition & Water (Check for units first to avoid collisions)
    if (_matches(input, ['ml', 'litre', 'liter', 'cup', 'glass', 'oz', 'drank'])) {
      return await _handleLogWater(input);
    }

    if (_matches(input, ['eat', 'calories', 'macros', 'nutrition', 'food today'])) {
      // If it's a question about "today", show summary. If "in", it's a search.
      if (input.contains('in') || input.contains('for') || input.contains('search')) {
        return _handlePantrySearch(input);
      }
      return await _handleNutritionSummary();
    }

    // 3. Habit Actions (Undo vs Done)
    bool isUndo = _matches(input, ['undo', 'remove', 'unmark', 'didnt', "didn't"]);
    bool isDone = _matches(input, ['done', 'complete', 'finish', 'did my', 'just did']);
    
    if (isUndo || isDone) {
      return _handleHabitToggle(input, markDone: !isUndo);
    }

    // 4. Fallback: Pantry Search
    if (_matches(input, ['find', 'search', 'look up', 'calories in', 'macros for'])) {
      return _handlePantrySearch(input);
    }

    return 'I can help you:\n'
        '• "I finished my workout"\n'
        '• "Undo my run"\n'
        '• "Drank 500ml water"\n'
        '• "Search for chicken"\n'
        '• "How are my macros today?"';
  }

  // ── Helper: Word Boundary Matching ────────────────────────────────────────
  bool _matches(String input, List<String> keywords) {
    return keywords.any((k) => input.contains(RegExp('\\b$k\\b')));
  }

  // ── Habit Toggle with Fuzzy Matching ──────────────────────────────────────
  String _handleHabitToggle(String input, {required bool markDone}) {
    final habits = ref.read(habitsNotifierProvider).value;
    if (habits == null || habits.isEmpty) return "You don't have any habits set up.";

    // Clean the input to isolate the habit name
    final cleanInput = input.replaceAll(RegExp(r'\b(mark|as|done|complete|undo|didnt|did|my|just|finish|finished)\b'), '').trim();

    // 1. Try Exact/Partial match
    var match = habits.where((h) {
      final name = h.habit.name.toLowerCase();
      return cleanInput.contains(name) || name.contains(cleanInput);
    }).firstOrNull;

    // 2. Try Fuzzy match if no direct hit (Handles typos like "yogga")
    if (match == null && cleanInput.length > 2) {
      final ratings = habits.map((h) => MapEntry(h, cleanInput.similarityTo(h.habit.name.toLowerCase()))).toList();
      ratings.sort((a, b) => b.value.compareTo(a.value));
      if (ratings.first.value > 0.6) match = ratings.first.key;
    }

    if (match == null) return "I couldn't find a habit matching '$cleanInput'.";

    if (markDone && match.completedToday) return '"${match.habit.name}" is already done!';
    
    ref.read(habitsNotifierProvider.notifier).toggleCompletion(match.habit.id);
    return markDone ? '✓ Done: ${match.habit.name}' : '↩ Undid: ${match.habit.name}';
  }

  // ── Enhanced Water Logging ────────────────────────────────────────────────
  Future<String> _handleLogWater(String input) async {
    // Robust Regex: handles "1.5L", "500 ml", "2 cups"
    final match = RegExp(r'(\d+(\.\d+)?)\s*(ml|l|litre|liter|cup|glass|oz)', caseSensitive: false).firstMatch(input);
    
    if (match == null) return 'How much? Try "500ml" or "2 cups".';

    final amount = double.parse(match.group(1)!);
    final unit = match.group(3)!.toLowerCase();
    
    double ml = amount;
    if (unit.startsWith('l')) ml = amount * 1000;
    if (unit.contains('cup') || unit.contains('glass')) ml = amount * 240;
    if (unit == 'oz') ml = amount * 29.57;

    await ref.read(nutritionNotifierProvider.notifier).logWater(ml);
    return '💧 Logged ${ml >= 1000 ? '${(ml/1000).toStringAsFixed(1)}L' : '${ml.toInt()}ml'}!';
  }

  // ── Pantry Search ─────────────────────────────────────────────────────────
  String _handlePantrySearch(String input) {
    final stopWords = {'find', 'search', 'for', 'what', 'is', 'calories', 'in', 'macros'};
    final query = input.split(' ').where((w) => w.length > 2 && !stopWords.contains(w)).join(' ').trim();

    if (query.isEmpty) return 'What should I look up?';

    final pantry = ref.read(pantryNotifierProvider).value ?? [];
    final results = pantry.where((f) => f.name.toLowerCase().contains(query)).toList();

    if (results.isEmpty) return 'No results for "$query".';

    final lines = results.take(3).map((f) => 
      '• ${f.name}: ${f.calories.toInt()}kcal (P:${f.protein.toInt()}g C:${f.carbs.toInt()}g)'
    ).join('\n');

    return 'I found:\n$lines';
  }

  // ── Summary Handlers ──────────────────────────────────────────────────────
  Future<String> _handleNutritionSummary() async {
    final n = ref.read(nutritionNotifierProvider).value;
    if (n == null) return "Loading nutrition...";
    return 'Today: ${n.totalCalories.toInt()} kcal | P: ${n.totalProtein.toInt()}g | C: ${n.totalCarbs.toInt()}g | W: ${(n.totalWaterMl/1000).toStringAsFixed(1)}L';
  }

  String _handleHabitProgress() {
    final habits = ref.read(habitsNotifierProvider).value ?? [];
    final done = habits.where((h) => h.completedToday).length;
    return 'Habits: $done/${habits.length} done. ${done == habits.length ? "Perfect score! 🎉" : "Keep going!"}';
  }

  Future<String> _handleDailySummary() async {
    final habitText = _handleHabitProgress();
    final nutritionText = await _handleNutritionSummary();
    return "Summary:\n$habitText\n$nutritionText";
  }
}