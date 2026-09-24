// presentation_screen.dart — The Overview (home) dashboard tab.
//
// This is the first screen the user sees after logging in. It brings together
// data from habits and nutrition into a single at-a-glance summary.
//
// Shows:
//   • Today's habit completion ring / count
//   • Nutrition calorie + macro summary for today
//   • Habits completed today (cards)
//   • AppBar: Community icon (left) + Settings icon (right, edge) — Community
//     moved here from Settings' "Browse Community" row so it's a one-tap
//     reach from the screen users land on, rather than buried in Settings
//
// Reused nutrition widgets (defined here, imported by nutrition_screen.dart):
//   NutritionCalorieSummary — calorie ring summary card
//   NutritionMacroRow       — row of macro badges
//   NutritionMacroPill      — single macro badge (e.g. "32g Protein")
//
// Connections:
//   habits_notifier.dart    — habitsNotifierProvider for today's habit status
//   nutrition_notifier.dart — nutritionNotifierProvider for today's calorie/macro totals
//   nutrition_screen.dart   — imports NutritionCalorieSummary, NutritionMacroRow,
//                             NutritionMacroPill for reuse in the nutrition tab
//   community_screen.dart   — AppBar's Community icon opens this
//   app_theme.dart          — AppGlass, AppColors, AppTextStyles

import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import '../../shared/widgets.dart'
    show
        AppLogoTitle,
        AppDragHandle,
        AppStepButton,
        SelectableChip,
        StreakBadge,
        formatWaterMl;
import '../community/community_screen.dart';
import '../habits/habits_notifier.dart';
import '../nutrition/nutrition_notifier.dart';
import '../nutrition/nutrition_screen.dart';
import '../onboarding/app_tour.dart';
import '../onboarding/app_tour_keys.dart';
import '../pantry/pantry_notifier.dart';
import '../profile/profile_notifier.dart';
import '../scoring/score.dart';
import '../settings/settings_screen.dart';

const List<String> _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class PresentationScreen extends ConsumerStatefulWidget {
  const PresentationScreen({super.key});

  @override
  ConsumerState<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends ConsumerState<PresentationScreen> {
  late final ConfettiController _confettiCtrl;

  static String _greeting(int hour, String? name) {
    final suffix = name != null ? ', $name.' : '.';
    if (hour < 12) return 'Good morning$suffix';
    if (hour < 17) return 'Good afternoon$suffix';
    return 'Good evening$suffix';
  }

  static String _dateLabel(DateTime d) {
    return '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
  }

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nutritionAsync = ref.watch(nutritionNotifierProvider);
    final profile = ref.watch(profileProvider).value;

    ref.listen(habitsNotifierProvider, (prev, next) {
      final nextList = next.value ?? [];
      if (nextList.isEmpty) return;
      // Only fire when there's a genuine prior state to compare against —
      // otherwise the first data emission after AsyncLoading (prev.value ==
      // null) looks like a 0-to-all-done transition and confetti plays just
      // from opening the app, not from actually completing anything.
      final prevList = prev?.value;
      if (prevList == null) return;
      final prevAllDone =
          prevList.isNotEmpty && prevList.every((h) => h.isDone);
      final nextAllDone = nextList.every((h) => h.isDone);
      if (!prevAllDone && nextAllDone) _confettiCtrl.play();
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const AppLogoTitle(),
            titleTextStyle: AppTextStyles.displayLarge,
            actions: [
              IconButton(
                icon: const Icon(Icons.groups_outlined),
                tooltip: 'Community',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CommunityScreen()),
                ),
              ),
              IconButton(
                icon: appTourTarget(
                  key: settingsIconKey,
                  title: 'Settings',
                  description:
                      'Manage your profile, account, and preferences.',
                  child: const Icon(Icons.settings_outlined),
                ),
                tooltip: 'Settings',
                onPressed: () => openSettingsScreen(context),
              ),
            ],
          ),
          body: ListView(
            padding: AppPaddings.all,
            children: [
              // Greeting — lives outside any card so it feels like the screen talking
              Text(
                _greeting(
                  now.hour,
                  profile?.displayName.isNotEmpty == true
                      ? profile!.displayName
                      : null,
                ),
                style: AppTextStyles.displayLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _dateLabel(now),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textOnDarkSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              appTourTarget(
                key: heroCardKey,
                title: 'Your daily progress',
                description:
                    'This ring tracks today\'s habits and nutrition at a glance.',
                child: const _HeroCard(),
              ),
              const SizedBox(height: AppSpacing.sm),
              const _StatsRow(),
              const SizedBox(height: AppSpacing.lg),
              nutritionAsync.when(
                data: (nutrition) => NutritionMacroRow(nutrition: nutrition),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _IncompleteHabitsListForDay(),
              const SizedBox(height: AppSpacing.lg),
              appTourTarget(
                key: quickAddKey,
                title: 'Quick add',
                description: 'Tap a food to log it in one step.',
                child: const _QuickAddSection(),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _ShowFoodsToday(),
              const SizedBox(height: AppSpacing.lg),
              const _HabitsCompletedToday(),
              const SizedBox(height: 100),
            ],
          ),
        ),
        IgnorePointer(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.07,
              numberOfParticles: 22,
              gravity: 0.18,
              colors: const [
                Color(0xFF9E8F8A), // terracotta
                Color(0xFF4C9C2F), // eucalyptus
                Color(0xFF4ECDC4), // teal
                Color(0xFF6BCB77), // green
                Color(0xFFFFB347), // gold
                Color(0xFFBF7800), // ochre
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Score helpers
// ---------------------------------------------------------------------------

Color _heroScoreColor(double score) {
  if (score >= 80) return AppColors.eucalyptus;
  if (score >= 60) return const Color.fromARGB(199, 191, 121, 0);
  if (score >= 40) return const Color.fromARGB(211, 158, 143, 138);
  return const Color.fromARGB(228, 161, 73, 56);
}

String _heroScoreLabel(double score) {
  if (score >= 80) return 'Great';
  if (score >= 65) return 'Good';
  if (score >= 50) return 'Moderate';
  if (score >= 35) return 'Low';
  return 'Getting started';
}

String _heroScoreSubtitle(double score) {
  if (score >= 80) return "You're on top of it today.";
  if (score >= 65) return "Solid progress so far.";
  if (score >= 50) return "Halfway there — keep going.";
  if (score >= 35) return "A few more things to check off.";
  return "Let's get today started.";
}

// ---------------------------------------------------------------------------
// _DualDial — two concentric arcs: habits / nutrition
// ---------------------------------------------------------------------------
//
// Outer arc → habit completion (done / total)
// Inner arc → calorie goal progress (logged / goal)
//
// Both arcs animate from 0 → target over 1400 ms on first paint.
// Arc geometry: 270° sweep starting at −135° (bottom-left to bottom-right).

class _DualDial extends CustomPainter {
  static const double _stroke = 16.0;
  static const double _gap = 10.0;
  static const double _start = -pi * 0.75; // −135°
  static const double _sweep = pi * 1.5; // 270°

  final double habitsPct;
  final double nutritionPct;
  final double animValue;

  const _DualDial({
    required this.habitsPct,
    required this.nutritionPct,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = cx - _stroke / 2;
    final innerR = outerR - _stroke - _gap;

    _arc(canvas, cx, cy, outerR, habitsPct, AppColors.terracotta);
    _arc(canvas, cx, cy, innerR, nutritionPct, AppColors.waterColor);
  }

  void _arc(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double pct,
    Color color,
  ) {
    // Progress arcs render at full opacity so they stay bold and legible
    // even when the base palette color (e.g. terracotta) is itself
    // semi-transparent — only the background track stays faint.
    final solid = color.withValues(alpha: 1.0);
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final track =
        Paint()
          ..color = solid.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep, false, track);

    final progress = (pct * animValue).clamp(0.0, 1.0);
    if (progress > 0.01) {
      canvas.drawArc(
        rect,
        _start,
        _sweep * progress,
        false,
        Paint()
          ..color = solid
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_DualDial o) =>
      o.animValue != animValue ||
      o.habitsPct != habitsPct ||
      o.nutritionPct != nutritionPct;
}

// ---------------------------------------------------------------------------
// _HeroCard — the overview's primary visual anchor
// ---------------------------------------------------------------------------

class _HeroCard extends ConsumerStatefulWidget {
  const _HeroCard();

  @override
  ConsumerState<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends ConsumerState<_HeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsNotifierProvider).value ?? [];
    final nutrition = ref.watch(nutritionNotifierProvider).value;

    // habitPct feeds both the outer arc and the score: weekly-frequency
    // habits get feasibility-based credit (see habitDailyCredit) instead of
    // a flat done/not-done, so a 3x/week habit with days still left to hit
    // it doesn't drag the ring down. No habits configured -> null, excluded
    // from the score average (not treated as a 0).
    final habitPct = habitPctForDay(habits);

    final calories = nutrition?.totalCalories ?? 0.0;
    final calGoal = (nutrition?.goals?.calories ?? NutritionRDA.calories)
        .clamp(1.0, double.infinity);
    final rawCalPct = (calories / calGoal).clamp(0.0, 1.0);
    // Paced against the waking window so being at the expected pace (e.g.
    // 30% of the goal 30% through the day) reads as fully on-track, not a
    // discouraging raw percentage. Also drives the inner arc, so the visual
    // and the number agree.
    final calPct = nutrition == null ? null : paceCalPct(rawCalPct);

    final overPenalty = overconsumptionPenalty(
      fat: nutrition?.totalFat ?? 0,
      fatGoal: nutrition?.goals?.fat,
      sugar: nutrition?.totalSugar ?? 0,
      sugarGoal: NutritionRDA.sugar, // no per-user goal column for sugar
      sodium: nutrition?.totalSodium ?? 0,
      sodiumGoal: nutrition?.goals?.sodium,
      cholesterol: nutrition?.totalCholesterol ?? 0,
      cholesterolGoal: nutrition?.goals?.cholesterol,
      carbs: nutrition?.totalCarbs ?? 0,
      carbsGoal: nutrition?.goals?.carbs,
    );
    final waterBonusPts = waterBonus(
      nutrition?.totalWaterMl ?? 0,
      nutrition?.goals?.waterMl,
    );

    final score = combineScore(
          habitPct: habitPct,
          nutritionPct: calPct,
          overconsumptionPts: overPenalty,
          waterBonusPts: waterBonusPts,
        ) ??
        0.0;
    final scoreColor = _heroScoreColor(score);

    return AppGlass.card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.xlAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dual arc dial
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: AnimatedBuilder(
                animation: _anim,
                builder:
                    (context, _) => CustomPaint(
                      painter: _DualDial(
                        habitsPct: habitPct ?? 0.0,
                        nutritionPct: calPct ?? 0.0,
                        animValue: _anim.value,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              score.round().toString(),
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                color: scoreColor,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              _heroScoreLabel(score),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: scoreColor.withValues(alpha: 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Insight line
          Text(
            _heroScoreSubtitle(score),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textOnDarkSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Arc legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ArcLegend('Habits', AppColors.terracotta),
              const SizedBox(width: AppSpacing.md),
              _ArcLegend('Nutrition', AppColors.waterColor),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _StatPill — a labeled stat in the hero card's bottom strip
// ---------------------------------------------------------------------------

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ArcLegend — tiny dot + label explaining each arc in the dial
// ---------------------------------------------------------------------------

class _ArcLegend extends StatelessWidget {
  const _ArcLegend(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 1.0),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textOnDarkTertiary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _StatsRow — three stat pills displayed below the hero card
// ---------------------------------------------------------------------------

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsNotifierProvider).value ?? [];
    final nutrition = ref.watch(nutritionNotifierProvider).value;

    final done = habits.where((h) => h.isDone).length;
    final total = habits.length;
    final calories = nutrition?.totalCalories ?? 0.0;
    final waterMl = nutrition?.totalWaterMl ?? 0.0;

    return Row(
      children: [
        _StatPill(
          label: 'habits',
          value: '$done / $total',
          color: AppColors.terracotta,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatPill(
          label: 'kcal',
          value: calories.toInt().toString(),
          color: AppColors.ochre,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatPill(
          label: 'water',
          value: formatWaterMl(waterMl),
          color: AppColors.waterColor,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _SectionHeader — consistent titled section divider with left accent bar
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.terracotta,
              borderRadius: AppRadius.smAll,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: AppTextStyles.titleMedium),
          if (trailing != null) ...[
            const Spacer(),
            Text(trailing!, style: AppTextStyles.labelSmall),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Add section
// ---------------------------------------------------------------------------

class _QuickAddSection extends ConsumerStatefulWidget {
  const _QuickAddSection();

  @override
  ConsumerState<_QuickAddSection> createState() => _QuickAddSectionState();
}

class _QuickAddSectionState extends ConsumerState<_QuickAddSection> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showQuickAddSheet(PantryFood food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _QuickAddSheet(food: food),
    );
  }

  void _showTemplateOptions(
    MealTemplateWithItems template,
    List<PantryFood> pantryFoods,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (sheetContext) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit template'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _editTemplate(template, pantryFoods);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.overLimit,
                  ),
                  title: const Text('Delete template'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDeleteTemplate(template);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _confirmDeleteTemplate(MealTemplateWithItems template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete template?'),
            content: Text(
              'Remove "${template.template.name}"? This can\'t be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.overLimit,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;

    await ref
        .read(mealTemplatesNotifierProvider.notifier)
        .deleteTemplate(template.template.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted "${template.template.name}"')),
    );
  }

  Future<void> _editTemplate(
    MealTemplateWithItems template,
    List<PantryFood> pantryFoods,
  ) async {
    final pantryFoodsById = {for (final f in pantryFoods) f.id: f};
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => _EditTemplateSheet(
            template: template,
            pantryFoodsById: pantryFoodsById,
          ),
    );
  }

  Future<void> _applyTemplate(MealTemplateWithItems template) async {
    final result = await ref
        .read(mealTemplatesNotifierProvider.notifier)
        .applyTemplate(template.template.id);
    if (!mounted) return;

    final skippedCount = result.skippedPantryFoodIds.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          skippedCount == 0
              ? 'Logged "${template.template.name}"'
              : 'Logged "${template.template.name}" — $skippedCount '
                  '${skippedCount == 1 ? 'item' : 'items'} skipped (no longer in your pantry)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pantryAsync = ref.watch(pantryNotifierProvider);
    // Soft-fail to {} (no reorder) rather than blocking the section on
    // loading/error — only the pantry list itself gates visibility below.
    final rankingCounts = ref.watch(quickAddRankingProvider).value ?? {};
    final templates = ref.watch(mealTemplatesNotifierProvider).value ?? [];

    return pantryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
      data: (foods) {
        if (foods.isEmpty) return const SizedBox.shrink();

        final ranked = rankPantryFoodsForQuickAdd(foods, rankingCounts);
        final filtered =
            _query.isEmpty
                ? ranked
                : ranked
                    .where(
                      (f) =>
                          f.name.toLowerCase().contains(_query.toLowerCase()),
                    )
                    .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 16,
                  color: AppColors.terracotta,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('Quick Add', style: AppTextStyles.titleMedium),
                const SizedBox(width: AppSpacing.xs),
                Text('from pantry', style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Saved meal templates — one-tap re-log of a previously-built meal
            if (templates.isNotEmpty) ...[
              Text('Your templates', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: templates.length,
                  separatorBuilder:
                      (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder:
                      (ctx, i) => _TemplateChip(
                        template: templates[i],
                        onTap: () => _applyTemplate(templates[i]),
                        onLongPress:
                            () => _showTemplateOptions(templates[i], foods),
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Search bar
            AppGlass.card(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.lgAll,
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 16,
                    color: AppColors.textOnDarkTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search pantry…',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnDarkTertiary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.textOnDarkTertiary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Horizontal food chips
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'No foods match "$_query"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnDarkTertiary,
                  ),
                ),
              )
            else
              SizedBox(
                height: 96 * 2 + AppSpacing.sm,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length,
                  // crossAxisCount here is ROW count, not visual columns —
                  // this grid scrolls sideways, so its "cross axis" is
                  // vertical. It must stay 2 to match the SizedBox height
                  // above (96 * 2 rows + 1 gap); raising it (e.g. to 4)
                  // squeezes each chip's cell far below the fixed 110px
                  // width the chip's internal layout assumes, which is
                  // what caused the RenderFlex overflow errors.
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 96 / 142,
                      ),
                  itemBuilder:
                      (ctx, i) => _QuickAddChip(
                        food: filtered[i],
                        onTap: () => _showQuickAddSheet(filtered[i]),
                      ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Individual food chip in the horizontal scroll
// ---------------------------------------------------------------------------

class _QuickAddChip extends StatelessWidget {
  final PantryFood food;
  final VoidCallback onTap;

  const _QuickAddChip({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppGlass.card(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppRadius.lgAll,
        child: SizedBox(
          width: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top: icon + add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.15),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: const Icon(
                      Icons.set_meal_outlined,
                      size: 14,
                      color: AppColors.terracotta,
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.terracotta,
                    ),
                  ),
                ],
              ),
              // Bottom: name + kcal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${food.calories.toInt()} kcal',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.terracotta,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Saved meal template chip — tap to re-log, long-press for edit/delete.
// Reuses _QuickAddChip's visual language rather than SelectableChip.
// ---------------------------------------------------------------------------

class _TemplateChip extends StatelessWidget {
  final MealTemplateWithItems template;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TemplateChip({
    required this.template,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = template.items.length;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AppGlass.card(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppRadius.lgAll,
        child: SizedBox(
          width: 140,
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.15),
                  borderRadius: AppRadius.smAll,
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  size: 14,
                  color: AppColors.terracotta,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      template.template.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.terracotta,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit template sheet — rename a template and remove items from it. There's
// no add-item flow here; a template's items are only ever seeded by
// "Save as template" on a real meal (see nutrition_screen.dart).
// ---------------------------------------------------------------------------

class _EditTemplateSheet extends ConsumerStatefulWidget {
  final MealTemplateWithItems template;
  final Map<String, PantryFood> pantryFoodsById;

  const _EditTemplateSheet({
    required this.template,
    required this.pantryFoodsById,
  });

  @override
  ConsumerState<_EditTemplateSheet> createState() =>
      _EditTemplateSheetState();
}

class _EditTemplateSheetState extends ConsumerState<_EditTemplateSheet> {
  late final TextEditingController _nameController;
  late final List<MealTemplateItem> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.template.template.name,
    );
    _items = List.of(widget.template.items);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _itemName(MealTemplateItem item) {
    if (item.pantryFoodId != null) {
      return widget.pantryFoodsById[item.pantryFoodId]?.name ??
          'Deleted food';
    }
    return item.name ?? 'Food';
  }

  String _itemSubtitle(MealTemplateItem item) {
    if (item.pantryFoodId != null) {
      final servings = item.servings;
      final label =
          servings == servings.roundToDouble()
              ? servings.toStringAsFixed(0)
              : servings.toStringAsFixed(1);
      return '$label ${servings == 1 ? 'serving' : 'servings'}';
    }
    return '${(item.calories ?? 0).round()} cal';
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _items.isEmpty || _saving) return;
    setState(() => _saving = true);

    await ref
        .read(mealTemplatesNotifierProvider.notifier)
        .updateTemplate(
          templateId: widget.template.template.id,
          name: name,
          items: [
            for (final item in _items) MealTemplateItemInput.fromRow(item),
          ],
        );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppDragHandle(),
          Text('Edit template', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Template name'),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'No items left — delete the template instead of saving it empty.',
                style: AppTextStyles.bodyMedium,
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_itemName(item)),
                    subtitle: Text(_itemSubtitle(item)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _items.removeAt(i)),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _items.isEmpty || _saving ? null : _save,
              child:
                  _saving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick add bottom sheet
// ---------------------------------------------------------------------------

class _QuickAddSheet extends ConsumerStatefulWidget {
  final PantryFood food;
  const _QuickAddSheet({required this.food});

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  double _servings = 1.0;
  String? _selectedMealId; // null = auto (create/find the resolved meal)
  bool _adding = false;

  // Computed once per sheet-open (not per rebuild) so the label doesn't
  // change under the user if the sheet stays open across a window boundary.
  late final String _resolvedMealName = resolveMealNameForTime(DateTime.now());

  double get _cal => widget.food.calories * _servings;
  double get _pro => widget.food.protein * _servings;
  double get _carb => widget.food.carbs * _servings;
  double get _fat => widget.food.fat * _servings;
  double get _sugar => widget.food.sugar * _servings;
  double get _fiber => widget.food.fiber * _servings;
  double get _sodium => widget.food.sodium * _servings;
  double get _cholesterol => widget.food.cholesterol * _servings;
  double get _potassium => widget.food.potassium * _servings;
  double get _calcium => widget.food.calcium * _servings;
  double get _iron => widget.food.iron * _servings;
  double get _vitaminA => widget.food.vitaminA * _servings;
  double get _vitaminC => widget.food.vitaminC * _servings;

  Future<void> _add() async {
    setState(() => _adding = true);

    final nutrition = ref.read(nutritionNotifierProvider);
    final notifier = ref.read(nutritionNotifierProvider.notifier);

    // Resolve which meal to add to
    String mealId;
    if (_selectedMealId != null) {
      mealId = _selectedMealId!;
    } else {
      // Look for an existing meal matching the resolved time-of-day name
      final existing =
          nutrition.value?.meals
              .where((m) => m.meal.name == _resolvedMealName)
              .firstOrNull;
      if (existing != null) {
        mealId = existing.meal.id;
      } else {
        mealId = await notifier.addMeal(_resolvedMealName);
      }
    }

    await notifier.addFoodEntry(
      mealId: mealId,
      name: widget.food.name,
      calories: _cal,
      protein: _pro,
      carbs: _carb,
      fat: _fat,
      sugar: _sugar,
      fiber: _fiber,
      sodium: _sodium,
      cholesterol: _cholesterol,
      potassium: _potassium,
      calcium: _calcium,
      iron: _iron,
      vitaminA: _vitaminA,
      vitaminC: _vitaminC,
      pantryFoodId: widget.food.id,
      servings: _servings,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final nutritionAsync = ref.watch(nutritionNotifierProvider);
    // Exclude the resolved-name meal from the tail of the row — it's already
    // represented by the auto chip at index 0, so it would otherwise show twice.
    final meals =
        (nutritionAsync.value?.meals ?? [])
            .where((m) => m.meal.name != _resolvedMealName)
            .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        top: AppSpacing.lg - 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppDragHandle(),

          // Food name + serving label
          Text(widget.food.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.food.servingLabel, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xs),

          // Serving counter + live macro row
          Row(
            children: [
              // Counter
              _ServingCounter(
                value: _servings,
                onChanged: (v) => setState(() => _servings = v),
              ),
              const SizedBox(width: AppSpacing.md),
              // Live macros
              Expanded(
                child: AppGlass.card(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  borderRadius: AppRadius.mdAll,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MacroLabel(
                        value: _cal.toInt(),
                        unit: 'kcal',
                        color: AppColors.terracotta,
                      ),
                      _MacroLabel(
                        value: _pro.toInt(),
                        unit: 'P',
                        color: AppColors.proteinColor,
                      ),
                      _MacroLabel(
                        value: _carb.toInt(),
                        unit: 'C',
                        color: AppColors.carbColor,
                      ),
                      _MacroLabel(
                        value: _fat.toInt(),
                        unit: 'F',
                        color: AppColors.fatColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Meal selector (only shown when meals exist today)
          if (meals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Add to meal', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: meals.length + 1, // +1 for the auto-resolved option
                separatorBuilder:
                    (_, _) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (ctx, i) {
                  // First chip is always the time-of-day-resolved meal (auto)
                  if (i == 0) {
                    final selected = _selectedMealId == null;
                    return SelectableChip(
                      label: _resolvedMealName,
                      selected: selected,
                      onTap: () => setState(() => _selectedMealId = null),
                    );
                  }
                  final meal = meals[i - 1];
                  final selected = _selectedMealId == meal.meal.id;
                  return SelectableChip(
                    label: meal.meal.name,
                    selected: selected,
                    onTap: () => setState(() => _selectedMealId = meal.meal.id),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          FilledButton(
            onPressed: _adding ? null : _add,
            child:
                _adding
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Add to Today'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Serving counter
// ---------------------------------------------------------------------------

class _ServingCounter extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _ServingCounter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppGlass.card(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      borderRadius: AppRadius.mdAll,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStepButton(
            icon: Icons.remove,
            enabled: value > 0.5,
            onTap: () => onChanged((value - 0.5).clamp(0.5, 99)),
          ),
          SizedBox(
            width: 44,
            child: Center(
              child: Text(
                value == value.truncateToDouble()
                    ? value.toInt().toString()
                    : value.toStringAsFixed(1),
                style: AppTextStyles.titleLarge,
              ),
            ),
          ),
          AppStepButton(
            icon: Icons.add,
            enabled: value < 99,
            onTap: () => onChanged((value + 0.5).clamp(0.5, 99)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Macro label inside the live preview card
// ---------------------------------------------------------------------------

class _MacroLabel extends StatelessWidget {
  final int value;
  final String unit;
  final Color color;

  const _MacroLabel({
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: AppTextStyles.titleMedium.copyWith(color: color)),
        Text(unit, style: AppTextStyles.labelSmall.copyWith(color: color)),
      ],
    );
  }
}

//------------------------------------------------------------------------------------------
// quick show widget of Todays foods
//------------------------------------------------------------------------------------------

class _ShowFoodsToday extends ConsumerWidget {
  const _ShowFoodsToday();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(nutritionNotifierProvider);

    return nutritionAsync.when(
      loading: () => const SizedBox.shrink(),
      error:
          (e, _) => Text(
            "Couldn't load nutrition data.",
            style: AppTextStyles.bodyMedium,
          ),
      data: (nutrition) {
        final foods = nutrition.meals.expand((m) => m.entries).toList();
        if (foods.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader('Eaten Today', trailing: '${foods.length} items'),
            AppGlass.card(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children:
                    foods.map((food) {
                      return GestureDetector(
                        onTap: () => showFoodNutritionDialog(context, food),
                        onLongPress:
                            () => confirmDeleteFoodEntry(context, ref, food),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  food.name,
                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                              Text(
                                '${food.calories.toInt()} kcal',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.terracotta,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.textOnDarkTertiary,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

}

//------------------------------------------------------------------------------------------
// show habits completed today
//------------------------------------------------------------------------------------------
class _HabitsCompletedToday extends ConsumerWidget {
  const _HabitsCompletedToday();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return habitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error:
          (e, _) => Text(
            "Couldn't load today's habits.",
            style: AppTextStyles.bodyMedium,
          ),
      data: (habits) {
        final completedToday = habits.where((h) => h.completedToday).toList();
        if (completedToday.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              'Done Today',
              trailing: '${completedToday.length} completed',
            ),
            AppGlass.card(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children:
                    completedToday
                        .map(
                          (h) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: AppColors.eucalyptus,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    h.habit.name,
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                ),
                                StreakBadge(h.streak),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _IncompleteHabitsListForDay — "Remaining Today" reactive habit list
// ---------------------------------------------------------------------------
//
// Watches habitsNotifierProvider so the list instantly reflects any toggle.
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │  FILTER LOGIC — "show this habit if…"                               │
// │                                                                      │
// │  !completedToday  — not done yet today (hides it once toggled)      │
// │  && !isDone       — goal for this period not yet fully met           │
// │                                                                      │
// │  Combined effect:                                                    │
// │  DAILY habit, not done today          → shown ✓                     │
// │  DAILY habit, done today              → hidden (completedToday)     │
// │                                                                      │
// │  WEEKLY habit, 0/3, not done today    → shown ✓                     │
// │  WEEKLY habit, 1/3, done today        → hidden until tomorrow       │
// │  WEEKLY habit, 2/3, done today        → hidden until tomorrow       │
// │  WEEKLY habit, 3/3 (target met)       → hidden all week (isDone)    │
// │                                                                      │
// │  The "come back tomorrow" behaviour is automatic: completedToday     │
// │  resets to false at local midnight, so the habit reappears tomorrow  │
// │  if the weekly target still hasn't been reached.                     │
// │                                                                      │
// │  To change what appears here, edit the `remaining` filter below.    │
// └──────────────────────────────────────────────────────────────────────┘

class _IncompleteHabitsListForDay extends ConsumerWidget {
  const _IncompleteHabitsListForDay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(habitsNotifierProvider)
        .when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (habits) {
            final remaining =
                habits.where((h) => !h.completedToday && !h.isDone).toList();
            if (remaining.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader('To Do', trailing: '${remaining.length} left'),
                const SizedBox(height: AppSpacing.sm),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: remaining.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisExtent: 150,
                      ),
                  itemBuilder:
                      (context, i) => _HabitTodayChip(h: remaining[i]),
                ),
              ],
            );
          },
        );
  }
}

// Tappable row for one remaining habit.
// Shows habit name + weekly progress subtitle for weekly habits.
// Tap  → quick-complete sheet.
// Long press → edit this week's day completions (weekly habits only).
class _HabitTodayChip extends StatelessWidget {
  final HabitWithStatus h;
  const _HabitTodayChip({required this.h});

  @override
  Widget build(BuildContext context) {
    final isWeekly = h.habit.frequencyType == 'weekly';
    return Semantics(
      button: true,
      label:
          isWeekly
              ? 'Mark ${h.habit.name} done for today. Double tap and hold to edit this week\'s completions.'
              : 'Mark ${h.habit.name} done for today.',
      child: GestureDetector(
        onTap:
            () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => _QuickCompleteHabitForDay(habit: h.habit),
            ),
        onLongPress:
            isWeekly
                ? () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _EditWeekCompletionsSheet(h: h),
                )
                : null,
        child: ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: Stack(
            children: [
              AppGlass.card(
                padding: EdgeInsets.only(
                  left: h.streak > 0 ? AppSpacing.sm + 6 : AppSpacing.sm,
                  right: AppSpacing.sm,
                  top: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                ),
                borderRadius: AppRadius.lgAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (h.streak > 0) ...[
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: StreakBadge(h.streak),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        const Icon(
                          Icons.radio_button_unchecked,
                          size: 16,
                          color: AppColors.textOnDarkTertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      h.habit.name,
                      style: AppTextStyles.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isWeekly)
                      Text(
                        '${h.completionsThisWeek}/${h.habit.targetDaysPerWeek}× this week',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.khaki,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (h.streak > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    color: StreakBadge.color(h.streak),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _EditWeekCompletionsSheet — long-press sheet to edit weekly day completions
// ---------------------------------------------------------------------------
//
// Shows Mon–Sun as toggleable day pills. Tapping a past/today pill calls
// toggleCompletionForDate so the user can backfill or remove completions.
// Future days are shown disabled.

class _EditWeekCompletionsSheet extends ConsumerStatefulWidget {
  final HabitWithStatus h;
  const _EditWeekCompletionsSheet({required this.h});

  @override
  ConsumerState<_EditWeekCompletionsSheet> createState() =>
      _EditWeekCompletionsSheetState();
}

class _EditWeekCompletionsSheetState
    extends ConsumerState<_EditWeekCompletionsSheet> {
  Set<DateTime> _completedDates = {};
  bool _loading = true;

  DateTime get _weekStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Monday = weekday 1
    return today.subtract(Duration(days: today.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = await ref
        .read(habitsNotifierProvider.notifier)
        .getCompletionDatesForWeek(widget.h.habit.id, _weekStart);
    if (mounted) {
      setState(() {
        _completedDates = dates;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(DateTime day) async {
    await ref
        .read(habitsNotifierProvider.notifier)
        .toggleCompletionForDate(widget.h.habit.id, day);
    // Optimistically update local set so the UI reacts immediately.
    setState(() {
      if (_completedDates.contains(day)) {
        _completedDates = {..._completedDates}..remove(day);
      } else {
        _completedDates = {..._completedDates, day};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final count = _completedDates.length;
    final target = widget.h.habit.targetDaysPerWeek;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppDragHandle(bottomMargin: AppSpacing.lg),

          Text(widget.h.habit.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$count / $target days this week',
            style: AppTextStyles.bodyMedium.copyWith(
              color: count >= target ? AppColors.eucalyptus : AppColors.khaki,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = days[i];
                final isFuture = day.isAfter(today);
                final done = _completedDates.contains(day);
                return GestureDetector(
                  onTap: isFuture ? null : () => _toggle(day),
                  child: Column(
                    children: [
                      Text(
                        labels[i],
                        style: AppTextStyles.labelSmall.copyWith(
                          color:
                              isFuture
                                  ? AppColors.textOnDarkTertiary
                                  : AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              done
                                  ? AppColors.terracotta
                                  : isFuture
                                  ? Colors.transparent
                                  : AppColors.glassBg,
                          border: Border.all(
                            color:
                                done
                                    ? AppColors.terracotta
                                    : isFuture
                                    ? AppColors.glassBorder.withValues(
                                      alpha: 0.3,
                                    )
                                    : AppColors.glassBorder,
                          ),
                        ),
                        child:
                            done
                                ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${day.day}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color:
                              isFuture
                                  ? AppColors.textOnDarkTertiary
                                  : AppColors.textOnDark,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// Bottom sheet: confirm completion of a single habit for today.
// Calls toggleCompletion which is idempotent (safe to call twice → undo).
class _QuickCompleteHabitForDay extends ConsumerStatefulWidget {
  final Habit habit;
  const _QuickCompleteHabitForDay({required this.habit});

  @override
  ConsumerState<_QuickCompleteHabitForDay> createState() =>
      _QuickCompleteHabitForDayState();
}

class _QuickCompleteHabitForDayState
    extends ConsumerState<_QuickCompleteHabitForDay> {
  bool _completing = false;

  Future<void> _complete() async {
    setState(() => _completing = true);
    final notifier = ref.read(habitsNotifierProvider.notifier);
    await notifier.toggleCompletion(widget.habit.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppDragHandle(bottomMargin: AppSpacing.lg),
          Text(widget.habit.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _completing ? null : _complete,
            child:
                _completing
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }
}

