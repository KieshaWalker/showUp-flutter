// presentation_screen.dart — The Overview (home) dashboard tab.
//
// This is the first screen the user sees after logging in. It brings together
// data from habits and nutrition into a single at-a-glance summary.
//
// Shows:
//   • Today's habit completion ring / count
//   • Nutrition calorie + macro summary for today
//   • Habits completed today (cards)
//   • AI assistant chat panel (uses agentProvider from agent_notifier.dart)
//
// Reused nutrition widgets (defined here, imported by nutrition_screen.dart):
//   NutritionCalorieSummary — calorie ring summary card
//   NutritionMacroRow       — row of macro badges
//   NutritionMacroPill      — single macro badge (e.g. "32g Protein")
//
// Connections:
//   habits_notifier.dart    — habitsNotifierProvider for today's habit status
//   nutrition_notifier.dart — nutritionNotifierProvider for today's calorie/macro totals
//   agent_notifier.dart     — agentProvider for the AI assistant chat
//   nutrition_screen.dart   — imports NutritionCalorieSummary, NutritionMacroRow,
//                             NutritionMacroPill for reuse in the nutrition tab
//   app_theme.dart          — AppGlass, AppColors, AppTextStyles

import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import '../../shared/widgets.dart' show AppLogoTitle, AppDragHandle, StreakBadge;
import '../agent/agent_notifier.dart';
import '../habits/habits_notifier.dart';
import '../nutrition/nutrition_notifier.dart';
import '../nutrition/nutrition_screen.dart';
import '../pantry/pantry_notifier.dart';
import '../profile/profile_notifier.dart';
import '../readiness/readiness_notifier.dart';

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
      final prevList = prev?.value ?? [];
      final nextList = next.value ?? [];
      if (nextList.isEmpty) return;
      final prevAllDone = prevList.isNotEmpty && prevList.every((h) => h.isDone);
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
              const _HeroCard(),
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
              const _QuickAddSection(),
              const SizedBox(height: AppSpacing.lg),
              const _ShowFoodsToday(),
              const SizedBox(height: AppSpacing.lg),
              const _HabitsCompletedToday(),
              const SizedBox(height: AppSpacing.lg),
              const _AgentSection(),
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
// Score helpers (mirrored from readiness_screen — same semantics)
// ---------------------------------------------------------------------------

Color _heroScoreColor(double score) {
  if (score >= 80) return AppColors.eucalyptus;
  if (score >= 60) return AppColors.ochre;
  if (score >= 40) return AppColors.terracotta;
  return AppColors.mahogany;
}

String _heroScoreLabel(double score) {
  if (score >= 80) return 'Peak';
  if (score >= 65) return 'Good';
  if (score >= 50) return 'Moderate';
  if (score >= 35) return 'Low';
  return 'Depleted';
}

String _heroScoreSubtitle(double score) {
  if (score >= 80) return "You're firing on all cylinders today.";
  if (score >= 65) return "Solid baseline. Good day to push.";
  if (score >= 50) return "You've got enough — pace yourself.";
  if (score >= 35) return "Take it easy. Recovery is progress.";
  return "Rest is the move today.";
}

// ---------------------------------------------------------------------------
// _TripleDial — three concentric arcs: readiness / habits / nutrition
// ---------------------------------------------------------------------------
//
// Outer arc  → readiness score (0–100), color tracks score state
// Middle arc → habit completion (done / total)
// Inner arc  → calorie goal progress (logged / goal)
//
// All three arcs animate from 0 → target over 1400 ms on first paint.
// Arc geometry: 270° sweep starting at −135° (bottom-left to bottom-right).

class _TripleDial extends CustomPainter {
  static const double _stroke = 10.0;
  static const double _gap    = 12.0;
  static const double _start  = -pi * 0.75;   // −135°
  static const double _sweep  = pi * 1.5;      // 270°

  final double readinessPct;
  final double habitsPct;
  final double nutritionPct;
  final double animValue;
  final Color readinessColor;

  const _TripleDial({
    required this.readinessPct,
    required this.habitsPct,
    required this.nutritionPct,
    required this.animValue,
    required this.readinessColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = cx - _stroke / 2;
    final midR   = outerR - _stroke - _gap;
    final innerR = midR   - _stroke - _gap;

    _arc(canvas, cx, cy, outerR,  readinessPct,  readinessColor);
    _arc(canvas, cx, cy, midR,    habitsPct,     AppColors.terracotta);
    _arc(canvas, cx, cy, innerR,  nutritionPct,  AppColors.waterColor);
  }

  void _arc(Canvas canvas, double cx, double cy, double r, double pct, Color color) {
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final track = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep, false, track);

    final progress = (pct * animValue).clamp(0.0, 1.0);
    if (progress > 0.01) {
      canvas.drawArc(rect, _start, _sweep * progress, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_TripleDial o) =>
      o.animValue     != animValue     ||
      o.readinessPct  != readinessPct  ||
      o.habitsPct     != habitsPct     ||
      o.nutritionPct  != nutritionPct;
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
  DailyReadinessData? _readinessRow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final row = await ref.read(readinessProvider.notifier).todaysReadiness();
      if (mounted) {
        setState(() => _readinessRow = row);
        _ctrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits    = ref.watch(habitsNotifierProvider).value ?? [];
    final nutrition = ref.watch(nutritionNotifierProvider).value;

    final total    = habits.length;
    final done     = habits.where((h) => h.isDone).length;
    final habitPct = total == 0 ? 0.0 : done / total;

    final calories = nutrition?.totalCalories ?? 0.0;
    final calGoal  = (nutrition?.goals?.calories ?? 2000.0).clamp(1.0, double.infinity);
    final calPct   = (calories / calGoal).clamp(0.0, 1.0);

    final score      = _readinessRow?.computedScore ?? 70.0;
    final scoreColor = _heroScoreColor(score);

    return AppGlass.card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.xlAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Triple arc dial
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) => CustomPaint(
                  painter: _TripleDial(
                    readinessPct:  score / 100,
                    habitsPct:     habitPct,
                    nutritionPct:  calPct,
                    animValue:     _anim.value,
                    readinessColor: scoreColor,
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
                            color: scoreColor.withValues(alpha: 0.8),
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
              _ArcLegend('Readiness', scoreColor),
              const SizedBox(width: AppSpacing.md),
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
  const _StatPill({required this.label, required this.value, required this.color});
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
    final habits    = ref.watch(habitsNotifierProvider).value ?? [];
    final nutrition = ref.watch(nutritionNotifierProvider).value;

    final done    = habits.where((h) => h.isDone).length;
    final total   = habits.length;
    final calories = nutrition?.totalCalories ?? 0.0;
    final waterMl  = nutrition?.totalWaterMl ?? 0.0;

    return Row(
      children: [
        _StatPill(label: 'habits',  value: '$done / $total',          color: AppColors.terracotta),
        const SizedBox(width: AppSpacing.sm),
        _StatPill(label: 'kcal',    value: calories.toInt().toString(), color: AppColors.ochre),
        const SizedBox(width: AppSpacing.sm),
        _StatPill(label: 'water',   value: '${(waterMl / 1000).toStringAsFixed(1)} L',   color: AppColors.waterColor),
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

  @override
  Widget build(BuildContext context) {
    final pantryAsync = ref.watch(pantryNotifierProvider);

    return pantryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
      data: (foods) {
        if (foods.isEmpty) return const SizedBox.shrink();

        final filtered =
            _query.isEmpty
                ? foods
                : foods
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
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length,
                  separatorBuilder:
                      (_, _) => const SizedBox(width: AppSpacing.sm),
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
  String? _selectedMealId; // null = auto (create/find "Quick Add")
  bool _adding = false;

  double get _cal => widget.food.calories * _servings;
  double get _pro => widget.food.protein * _servings;
  double get _carb => widget.food.carbs * _servings;
  double get _fat => widget.food.fat * _servings;

  Future<void> _add() async {
    setState(() => _adding = true);

    final nutrition = ref.read(nutritionNotifierProvider);
    final notifier = ref.read(nutritionNotifierProvider.notifier);

    // Resolve which meal to add to
    String mealId;
    if (_selectedMealId != null) {
      mealId = _selectedMealId!;
    } else {
      // Look for an existing "Quick Add" meal today
      final existing =
          nutrition.value?.meals
              .where((m) => m.meal.name == 'Quick Add')
              .firstOrNull;
      if (existing != null) {
        mealId = existing.meal.id;
      } else {
        mealId = await notifier.addMeal('Quick Add');
      }
    }

    await notifier.addFoodEntry(
      mealId: mealId,
      name: widget.food.name,
      calories: _cal,
      protein: _pro,
      carbs: _carb,
      fat: _fat,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final nutritionAsync = ref.watch(nutritionNotifierProvider);
    final meals = nutritionAsync.value?.meals ?? [];

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

          // Food name + serving label
          Text(widget.food.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.food.servingLabel, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.lg),

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
                itemCount: meals.length + 1, // +1 for "Quick Add" option
                separatorBuilder:
                    (_, _) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (ctx, i) {
                  // First chip is always "Quick Add" (auto)
                  if (i == 0) {
                    final selected = _selectedMealId == null;
                    return _MealChip(
                      label: 'Quick Add',
                      selected: selected,
                      onTap: () => setState(() => _selectedMealId = null),
                    );
                  }
                  final meal = meals[i - 1];
                  final selected = _selectedMealId == meal.meal.id;
                  return _MealChip(
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
          _StepBtn(
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
          _StepBtn(
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
// Circular +/- button used in the serving counter
// ---------------------------------------------------------------------------
class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  // A circular button with a +/- icon, used in the serving counter
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color:
              enabled
                  ? AppColors.terracotta.withValues(alpha: 0.15)
                  : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                enabled
                    ? AppColors.terracotta.withValues(alpha: 0.4)
                    : AppColors.glassBorder.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.terracotta : AppColors.textOnDarkTertiary,
        ),
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

// ---------------------------------------------------------------------------
// Meal selector chip
// ---------------------------------------------------------------------------

class _MealChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MealChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ), // duration of the color transition
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.terracotta : AppColors.glassBg,
          borderRadius: AppRadius.xlAll,
          border: Border.all(
            color: selected ? AppColors.terracotta : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? Colors.white : AppColors.textOnDark,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
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
      error: (e, _) => Text("Couldn't load nutrition data.", style: AppTextStyles.bodyMedium),
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
                children: foods.map((food) {
                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Food Entry'),
                          content: Text('Remove "${food.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(nutritionNotifierProvider.notifier)
                                    .deleteFoodEntry(food.id);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(food.name, style: AppTextStyles.bodyLarge),
                          ),
                          Text(
                            '${food.calories.toInt()} kcal',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.terracotta,
                            ),
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
      error: (e, _) => Text("Couldn't load today's habits.", style: AppTextStyles.bodyMedium),
      data: (habits) {
        final completedToday =
            habits.where((h) => h.completedToday).toList();
        if (completedToday.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader('Done Today', trailing: '${completedToday.length} completed'),
            AppGlass.card(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: completedToday.map((h) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.eucalyptus,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(h.habit.name, style: AppTextStyles.bodyLarge),
                      ),
                      StreakBadge(h.streak),
                    ],
                  ),
                )).toList(),
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
    return ref.watch(habitsNotifierProvider).when(
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
            ...remaining.map((h) => _HabitTodayChip(h: h)),
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
    return GestureDetector(
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: Stack(
            children: [
              AppGlass.card(
                padding: EdgeInsets.only(
                  left: h.streak > 0 ? AppSpacing.md + 6 : AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                borderRadius: AppRadius.lgAll,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.habit.name, style: AppTextStyles.titleMedium),
                          if (isWeekly)
                            Text(
                              '${h.completionsThisWeek}/${h.habit.targetDaysPerWeek}× this week',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.khaki,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (h.streak > 0) ...[
                          StreakBadge(h.streak),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        const Icon(
                          Icons.radio_button_unchecked,
                          size: 20,
                          color: AppColors.textOnDarkTertiary,
                        ),
                      ],
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
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: const Color.fromARGB(9, 255, 255, 255),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
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

// ---------------------------------------------------------------------------
// _AgentSection — coach chat panel at the bottom of the overview screen
// ---------------------------------------------------------------------------

class _AgentSection extends ConsumerStatefulWidget {
  const _AgentSection();

  @override
  ConsumerState<_AgentSection> createState() => _AgentSectionState();
}

class _AgentSectionState extends ConsumerState<_AgentSection> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(agentProvider.notifier).sendMessage(text);
    // Scroll to bottom after the new messages are rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agentProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 16,
              color: AppColors.terracotta,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('Coach', style: AppTextStyles.titleMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Message history
        if (state.messages.isNotEmpty)
          AppGlass.card(
            padding: AppPaddings.card,
            borderRadius: AppRadius.xlAll,
            child: SizedBox(
              height: 240,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.messages.length,
                itemBuilder:
                    (ctx, i) => _ChatBubble(message: state.messages[i]),
              ),
            ),
          ),

        // Thinking indicator
        if (state.loading)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.terracotta,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Thinking…',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnDarkTertiary,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppSpacing.md),

        // Input row
        AppGlass.card(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.lgAll,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _send(),
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Ask your coach…',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDarkTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    size: 14,
                    color: AppColors.terracotta,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _ChatBubble
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  final AgentMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 12,
                color: AppColors.terracotta,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? AppColors.terracotta.withValues(alpha: 0.2)
                        : AppColors.glassBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isUser ? 12 : 2),
                  bottomRight: Radius.circular(isUser ? 2 : 12),
                ),
                border: Border.all(
                  color:
                      isUser
                          ? AppColors.terracotta.withValues(alpha: 0.3)
                          : AppColors.glassBorder,
                ),
              ),
              child: Text(message.text, style: AppTextStyles.bodyMedium),
            ),
          ),
          if (isUser) const SizedBox(width: AppSpacing.xl),
        ],
      ),
    );
  }
}
