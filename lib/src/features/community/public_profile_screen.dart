// public_profile_screen.dart — Read-only view of another user's profile,
// pantry, and habits — with buttons to copy their pantry foods / habits
// into your own.
//
// Deliberately a separate screen from profile_screen.dart's ProfileScreen,
// not a reused "view mode" of it: ProfileScreen's save()/uploadAvatar()
// always act on profileProvider (i.e. the CURRENT logged-in user)
// regardless of which profile was passed in, so reusing it here would
// silently edit the viewer's own profile instead of showing the tapped
// user's — this screen has no edit affordances for the profile itself.
//
// Reached by tapping a row in community_screen.dart.
//
// Pantry/habits data is fetched live from Supabase (otherUserPantryProvider /
// otherUserHabitsProvider) rather than local Drift, since local Drift only
// ever holds the current user's own rows + presets. This relies on the
// pantry_foods/habits/habit_completions/habit_skips SELECT RLS policies
// being open to any authenticated user (widened 2026-09-18 for this feature,
// same pattern as the profiles widening for community_notifier.dart).
//
// "Add to mine" buttons call the existing addFood()/addHabit() mutations
// with a fresh id — the copy becomes an independent row owned by the
// current user, never a reference back to the source user's row.
//
// Connections:
//   profile_notifier.dart — UserProfile model (passed in directly; no
//                            fetch here, community_screen.dart already has it)
//   pantry_notifier.dart  — otherUserPantryProvider, pantryNotifierProvider.addFood
//   habits_notifier.dart  — otherUserHabitsProvider, habitsNotifierProvider.addHabit
//   habits_screen.dart    — HabitFreqChip, reused to display frequency

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import '../habits/habits_notifier.dart';
import '../habits/habits_screen.dart';
import '../pantry/pantry_notifier.dart';
import '../profile/profile_notifier.dart';

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  String get _initials {
    final name = profile.displayName;
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = profile.displayName;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(name.isNotEmpty ? name : 'Profile')),
        body: ListView(
          padding: AppPaddings.all,
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.terracotta.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.terracotta.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: profile.avatarUrl != null
                      ? Image.network(
                          profile.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _InitialsText(_initials),
                        )
                      : _InitialsText(_initials),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppGlass.card(
              padding: AppPaddings.section,
              borderRadius: AppRadius.lgAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name', style: AppTextStyles.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    name.isNotEmpty ? name : 'Not set',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Username', style: AppTextStyles.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    profile.username != null && profile.username!.isNotEmpty
                        ? '@${profile.username}'
                        : 'Not set',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _HabitsSection(userId: profile.id),
            const SizedBox(height: AppSpacing.lg),
            _PantrySection(userId: profile.id),
          ],
        ),
      ),
    );
  }
}

class _InitialsText extends StatelessWidget {
  final String initials;
  const _InitialsText(this.initials);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.terracotta,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Habits section
// ---------------------------------------------------------------------------

class _HabitsSection extends ConsumerWidget {
  const _HabitsSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(otherUserHabitsProvider(userId));

    return AppGlass.card(
      padding: AppPaddings.section,
      borderRadius: AppRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Habits', style: AppTextStyles.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          habitsAsync.when(
            data: (habits) {
              if (habits.isEmpty) {
                return Text('No habits yet', style: AppTextStyles.bodyMedium);
              }
              return Column(
                children: [
                  for (final h in habits) _HabitRow(status: h),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) =>
                Text('Could not load habits', style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.status});

  final HabitWithStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = status.habit;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    HabitFreqChip(habit: habit, dense: true),
                    if (status.streak > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '🔥 ${status.streak}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Add to my habits',
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.terracotta,
            onPressed: () async {
              await ref.read(habitsNotifierProvider.notifier).addHabit(
                    habit.name,
                    frequencyType: habit.frequencyType,
                    targetDaysPerWeek: habit.targetDaysPerWeek,
                    skipsAllowedPerWeek: habit.skipsAllowedPerWeek,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added "${habit.name}" to your habits')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pantry section
// ---------------------------------------------------------------------------

class _PantrySection extends ConsumerWidget {
  const _PantrySection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryAsync = ref.watch(otherUserPantryProvider(userId));

    return AppGlass.card(
      padding: AppPaddings.section,
      borderRadius: AppRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pantry', style: AppTextStyles.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          pantryAsync.when(
            data: (foods) {
              if (foods.isEmpty) {
                return Text(
                  'No personal foods yet',
                  style: AppTextStyles.bodyMedium,
                );
              }
              return Column(
                children: [
                  for (final f in foods) _PantryRow(food: f),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) =>
                Text('Could not load pantry', style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _PantryRow extends ConsumerWidget {
  const _PantryRow({required this.food});

  final PantryFood food;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${food.calories.toInt()} kcal · ${food.servingLabel}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Add to my pantry',
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.terracotta,
            onPressed: () async {
              await ref.read(pantryNotifierProvider.notifier).addFood(
                    name: food.name,
                    calories: food.calories,
                    protein: food.protein,
                    carbs: food.carbs,
                    fat: food.fat,
                    servingLabel: food.servingLabel,
                    sugar: food.sugar,
                    fiber: food.fiber,
                    sodium: food.sodium,
                    cholesterol: food.cholesterol,
                    potassium: food.potassium,
                    calcium: food.calcium,
                    iron: food.iron,
                    vitaminA: food.vitaminA,
                    vitaminC: food.vitaminC,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added "${food.name}" to your pantry')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
