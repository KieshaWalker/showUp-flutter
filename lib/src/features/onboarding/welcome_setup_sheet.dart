// welcome_setup_sheet.dart — One-time, skippable setup shown after first
// login, so a brand-new user doesn't land on an empty Overview dashboard
// with no idea what to do first.
//
// maybeShowWelcomeSetup() checks a local "seen it" flag (SharedPreferences,
// scoped per user id since the device may be shared across accounts) and,
// if unset, shows _WelcomeSetupSheet. Every step can be skipped — this is a
// nudge toward the two things new users otherwise never find (adding a
// habit, setting a calorie goal), not a gate.
//
// Connections:
//   main.dart               — calls maybeShowWelcomeSetup() from AppShell.initState()
//   habits_notifier.dart    — addHabit() for the chosen starter habit
//   nutrition_notifier.dart — updateGoals() for the calorie goal
//   nutrition_screen.dart   — NutritionRDA defaults used to fill unset macros

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets.dart' show AppDragHandle;
import '../habits/habits_notifier.dart';
import '../habits/habits_screen.dart' show HabitFreqChip;
import '../nutrition/nutrition_notifier.dart';
import '../nutrition/nutrition_screen.dart' show NutritionRDA;

const _starterHabits = [
  'Drink water',
  'Move for 10 min',
  'Read',
  'Sleep on time',
];

Future<void> maybeShowWelcomeSetup(BuildContext context, WidgetRef ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  final prefs = await SharedPreferences.getInstance();
  final key = 'welcome_setup_seen_$userId';
  if (prefs.getBool(key) ?? false) return;

  if (!context.mounted) return;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => const _WelcomeSetupSheet(),
  );

  await prefs.setBool(key, true);
}

class _WelcomeSetupSheet extends ConsumerStatefulWidget {
  const _WelcomeSetupSheet();

  @override
  ConsumerState<_WelcomeSetupSheet> createState() =>
      _WelcomeSetupSheetState();
}

class _WelcomeSetupSheetState extends ConsumerState<_WelcomeSetupSheet> {
  int _step = 0;
  String? _selectedHabit;
  late final TextEditingController _calorieCtrl;

  @override
  void initState() {
    super.initState();
    _calorieCtrl =
        TextEditingController(text: NutritionRDA.calories.round().toString());
  }

  @override
  void dispose() {
    _calorieCtrl.dispose();
    super.dispose();
  }

  Future<void> _finishStepOne() async {
    final habit = _selectedHabit;
    if (habit != null) {
      await ref.read(habitsNotifierProvider.notifier).addHabit(habit);
    }
    if (mounted) setState(() => _step = 1);
  }

  Future<void> _finishStepTwo({required bool saveGoal}) async {
    if (saveGoal) {
      final calories =
          double.tryParse(_calorieCtrl.text) ?? NutritionRDA.calories;
      await ref.read(nutritionNotifierProvider.notifier).updateGoals(
            calories: calories,
            protein: NutritionRDA.protein,
            carbs: NutritionRDA.carbs,
            fat: NutritionRDA.fat,
            waterMl: NutritionRDA.waterMl,
          );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg - 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppDragHandle(),
          Text(
            'Step ${_step + 1} of 2',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textOnDarkTertiary),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (_step == 0) _buildStepOne() else _buildStepTwo(),
        ],
      ),
    );
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pick a habit to start with', style: AppTextStyles.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'You can add more, or change this, any time.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textOnDarkSecondary),
        ),
        const SizedBox(height: AppSpacing.lg - 4),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _starterHabits
              .map((habit) => HabitFreqChip(
                    label: habit,
                    selected: _selectedHabit == habit,
                    onTap: () => setState(() =>
                        _selectedHabit = _selectedHabit == habit ? null : habit),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _step = 1),
                child: const Text('Skip'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _finishStepOne,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Set your daily calorie goal',
            style: AppTextStyles.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'You can change this any time from the tune icon on the Nutrition tab.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textOnDarkSecondary),
        ),
        const SizedBox(height: AppSpacing.lg - 4),
        TextField(
          controller: _calorieCtrl,
          style: AppTextStyles.bodyLarge,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily calories',
            suffixText: 'kcal',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => _finishStepTwo(saveGoal: false),
                child: const Text('Skip'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _finishStepTwo(saveGoal: true),
                child: const Text('Finish'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
