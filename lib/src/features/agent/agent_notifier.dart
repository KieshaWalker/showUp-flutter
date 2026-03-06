// agent_notifier.dart — The AI assistant that understands plain-English messages.
//
// The agent does NOT call an external AI API. Instead it uses local rule-based
// intent matching (keyword detection + fuzzy string matching) to understand
// what the user wants and takes action directly using the app's own notifiers.
//
// AgentState holds:
//   messages — the chat history (user + agent bubbles) for the current session
//   loading  — true while the agent is "thinking" (500ms delay)
//
// sendMessage() flow:
//   1. Adds the user's message to the chat
//   2. Waits 500ms (feels more natural)
//   3. Calls _handle() to route the message to the right handler
//   4. Adds the agent's response to the chat
//   5. Saves the interaction to Supabase (agent_memories table) for recall
//
// Intent routing in _handle():
//   Greetings      → personalised hello, optionally recalls last session
//   Water logging  → parses ml/cups/litres, calls nutritionNotifier.logWater()
//   Habit toggle   → fuzzy-matches habit name, calls habitsNotifier.toggleCompletion()
//   Nutrition info → reads today's totals from nutritionNotifier
//   Pantry search  → filters pantry list by keyword
//   Summaries      → combines habit progress + nutrition into one message
//
// Memory:
//   _saveMemory()      — writes each interaction to Supabase `agent_memories`
//   _recallLastContext()— reads the most recent answer from previous sessions
//
// Connections:
//   habits_notifier.dart    — read habit list + call toggleCompletion()
//   nutrition_notifier.dart — read totals + call logWater()
//   pantry_notifier.dart    — read pantry food list for search
//   supabase_client.dart    — writes memory to Supabase `agent_memories` table
//   presentation_screen.dart— hosts the chat UI that calls sendMessage()

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../habits/habits_notifier.dart';
import '../nutrition/nutrition_notifier.dart';
import '../pantry/pantry_notifier.dart';
import 'package:string_similarity/string_similarity.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final agentProvider = NotifierProvider<AgentNotifier, AgentState>(
  AgentNotifier.new,
);

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class AgentMessage {
  final String text;
  final bool isUser;

  const AgentMessage({required this.text, required this.isUser});
}

class AgentState {
  final List<AgentMessage> messages;
  final bool loading;

  const AgentState({required this.messages, this.loading = false});

  AgentState copyWith({List<AgentMessage>? messages, bool? loading}) {
    return AgentState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
//
// Intent routing — add a new branch in _handle() + a handler method to extend.
//
//  1. Habit complete   — "done yoga", "finished my run", "completed workout"
//  2. Habit undo       — "undo workout", "didn't do yoga", "remove run"
//  3. Pantry search    — "search chicken", "find oats", "calories in salmon"
//  4. Log water        — "drank 500ml", "2 cups of water", "1 litre"
//  5. Nutrition today  — "what did I eat", "calories today", "my macros"
//  6. Habit progress   — "habit progress", "remaining habits", "habits today"
//  7. Daily summary    — "how am I doing", "today's summary", "my progress"

class AgentNotifier extends Notifier<AgentState> {
  @override
  AgentState build() => const AgentState(messages: []);

  final _supabase = Supabase.instance.client;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Snapshot history before the new user message for context passing
    final history = List<AgentMessage>.unmodifiable(state.messages);

    state = state.copyWith(
      messages: [...state.messages, AgentMessage(text: trimmed, isUser: true)],
      loading: true,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    final response = await _handle(trimmed, history: history);

    state = state.copyWith(
      messages: [...state.messages, AgentMessage(text: response, isUser: false)],
      loading: false,
    );

    // Save once per interaction after state is updated
    await _saveMemory(
      content: 'Interaction regarding: $trimmed',
      type: 'chat_log',
      question: trimmed,
      answer: response,
    );
  }

  // ── Helper: Word Boundary Matching ────────────────────────────────────────
  bool _matches(String input, List<String> keywords) {
    final lowerInput = input.toLowerCase();
    return keywords.any((k) {
      final regex = RegExp('\\b${RegExp.escape(k.toLowerCase())}\\b', caseSensitive: false);
      return regex.hasMatch(lowerInput);
    });
  }

  // ── Memory Saving & Recall ────────────────────────────────────────────────
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
    } catch (e) {
      // ignore: avoid_print
      print('DB Error: $e');
    }
  }

  // ── Database: Recall Context ──────────────────────────────────────────────
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

  // ── Session context: last N messages as readable string ──────────────────
  String _sessionContext(List<AgentMessage> history, {int limit = 4}) {
    if (history.isEmpty) return '';
    final recent = history.length > limit ? history.sublist(history.length - limit) : history;
    return recent.map((m) => '${m.isUser ? "You" : "Me"}: ${m.text}').join('\n');
  }

  // ── Main Intent Router ────────────────────────────────────────────────────
  Future<String> _handle(String rawInput, {required List<AgentMessage> history}) async {
    final input = rawInput.toLowerCase();
    String response;

    // 1. Greetings & Recall
    if (_matches(input, ['hello', 'hi', 'hey', 'greetings', 'up'])) {
      final username = _supabase.auth.currentUser?.userMetadata?['username'] ?? 'there';
      if (history.isNotEmpty) {
        // Already in a session — acknowledge the ongoing conversation
        response = 'Hey $username! We\'ve been chatting for a bit. What else can I help with?';
      } else {
        // Fresh session — try to recall last cross-session context
        final lastContext = await _recallLastContext();
        response = 'Hello, $username!';
        if (lastContext != null) {
          response += '\nLast time we spoke, I helped with: "$lastContext". How are we doing now?';
        } else {
          response += ' How can I help you today?';
        }
      }
      return response;
    }

    // 2. Follow-up context — "what about [X]?" or "and [X]?"
    final isFollowUp = _matches(input, ['what about', 'and', 'how about']) && history.isNotEmpty;

    // 3. High Priority: Summaries
    if (_matches(input, ['summary', 'overview', 'progress', 'how am i'])) {
      if (input.contains('habit')) {
        response = _handleHabitProgress();
      } else {
        response = await _handleDailySummary();
      }
    }

    // 4. Water Logging
    else if (_matches(input, ['drank', 'water', 'ml', 'litre', 'liter', 'cup'])) {
      response = await _handleLogWater(input);
    }

    // 5. Habit Actions (Undo vs Done)
    else if (_matches(input, ['done', 'complete', 'finish', 'did', 'undo', 'remove', 'didnt'])) {
      final isUndo = _matches(input, ['undo', 'remove', 'didnt', "didn't"]);
      response = _handleHabitToggle(input, markDone: !isUndo);
    }

    // 6. Nutrition Queries
    else if (_matches(input, ['eat', 'calories', 'macros', 'nutrition', 'food', 'add a meal', 'add a food'])) {
      if (_matches(input, ['edit', 'change', 'update', 'add', 'remove'])) {
        response = 'What food would you like to edit?';
      } else {
        response = await _handleNutritionSummary();
      }
    }

    // 7. Pantry Search
    else if (_matches(input, ['find', 'search', 'what is', 'macros for', 'look up'])) {
      response = _handlePantrySearch(input);
    }

    // Default Fallback — include session hint if we have context
    else {
      if (isFollowUp && history.isNotEmpty) {
        final ctx = _sessionContext(history);
        response = 'Not sure what you mean in context of our chat. Here\'s what we covered:\n$ctx';
      } else {
        response = 'I can help with habits, water, calories, or searching your pantry. Try "How am I doing today?"';
      }
    }

    return response;
  }

  // ── Habit Toggle with Fuzzy Matching ──────────────────────────────────────
  String _handleHabitToggle(String input, {required bool markDone}) {
    final habits = ref.read(habitsNotifierProvider).value ?? [];
    if (habits.isEmpty) return "You don't have any habits set up yet.";

    final habitNames = habits.map((h) => h.habit.name.toLowerCase()).toList();
    final query = input
        .replaceAll(RegExp(r'\b(mark|done|undo|did|my|finish|complete|finished)\b'), '')
        .trim();

    final bestMatch = query.bestMatch(habitNames);
    if (bestMatch.bestMatch.rating! < 0.4) {
      return "I couldn't find a habit like '$query'. Try: ${habitNames.take(2).join(', ')}";
    }

    final matchedName = bestMatch.bestMatch.target!;
    final match = habits.firstWhere((h) => h.habit.name.toLowerCase() == matchedName);

    if (markDone && match.completedToday) return '"${match.habit.name}" is already done!';

    ref.read(habitsNotifierProvider.notifier).toggleCompletion(match.habit.id);
    return markDone
        ? '✓ Marked "${match.habit.name}" as done!'
        : '↩ Removed completion for "${match.habit.name}".';
  }

  // ── Pantry Search ─────────────────────────────────────────────────────────
  String _handlePantrySearch(String input) {
    const stopWords = {'find', 'search', 'for', 'what', 'is', 'calories', 'in', 'macros'};
    final query = input
        .split(' ')
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .join(' ')
        .trim();

    final pantry = ref.read(pantryNotifierProvider).value ?? [];
    final results = pantry.where((f) => f.name.toLowerCase().contains(query)).toList();

    if (results.isEmpty) return 'No foods found matching "$query".';

    final lines = results.take(3).map((f) => '• ${f.name}: ${f.calories.toInt()} kcal').join('\n');
    return 'Found results:\n$lines';
  }

  // ── Water Logging ─────────────────────────────────────────────────────────
  Future<String> _handleLogWater(String input) async {
    final numMatch = RegExp(r'(\d+(\.\d+)?)').firstMatch(input);
    if (numMatch == null) return 'How much water? Try "drank 500ml".';

    final amount = double.parse(numMatch.group(1)!);
    double ml = amount;

    if (input.contains('litre') || input.contains('liter') || input.contains(' l ')) {
      ml *= 1000;
    } else if (input.contains('cup') || input.contains('glass')) {
      ml *= 240;
    }

    await ref.read(nutritionNotifierProvider.notifier).logWater(ml);
    return '💧 Logged ${ml >= 1000 ? '${(ml / 1000).toStringAsFixed(1)}L' : '${ml.toInt()}ml'} of water!';
  }

  // ── Summaries ─────────────────────────────────────────────────────────────
  Future<String> _handleNutritionSummary() async {
    final n = ref.read(nutritionNotifierProvider).value;
    if (n == null) return 'Loading nutrition...';
    return 'Today: ${n.totalCalories.toInt()} kcal | P: ${n.totalProtein.toInt()}g | C: ${n.totalCarbs.toInt()}g | Fat: ${n.totalFat.toInt()}g';
  }

  String _handleHabitProgress() {
    final habits = ref.read(habitsNotifierProvider).value ?? [];
    final done = habits.where((h) => h.isDone).length;
    return 'Habits: $done / ${habits.length} completed today.';
  }

  Future<String> _handleDailySummary() async {
    final h = _handleHabitProgress();
    final n = await _handleNutritionSummary();
    return 'Summary:\n$h\n$n';
  }
}
