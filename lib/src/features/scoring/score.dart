// score.dart — shared scoring math for the Overview hero ring (daily) and
// the Calendar week ring (weekly). Single source of truth so the two rings
// can't drift into different formulas the way they had before this file
// existed (the Hero ring used calories only; the Calendar ring used macros
// only, with no overconsumption penalty in either).
//
// Formula shape (both daily and weekly):
//   score = clamp(0, 100, (habitPct + nutritionPct) / 2 * 100
//                          - overconsumptionPenalty + waterBonus)
//
// Daily-specific: nutritionPct is calorie progress paced against a waking
// window (see paceCalPct) so being at the expected pace reads as "on
// track" (100%) instead of a literal, discouraging raw percentage — e.g.
// 30% of the calorie goal at 30% through the day is exactly on pace.
// Weekly-specific: nutritionPct is calorie progress against the week's
// elapsed-day-prorated goal — no time-of-day pacing needed, the goal
// itself is already prorated to how much of the week has passed.
//
// Overconsumption / water bonus use the same shape for both windows: each
// tracked nutrient contributes up to a fixed point value, ramping linearly
// from the goal to 2x the goal, then holding at the cap. The "over is bad"
// nutrient set (fat, sugar, sodium, cholesterol, carbs) mirrors
// NutritionMacroPill's flagWhenOver set in nutrition_screen.dart — keep
// both in sync if that set ever changes.

import 'dart:math' as math;

import '../habits/habits_notifier.dart' show HabitWithStatus;

/// Point cap for a single over-goal nutrient category's deduction.
const double kMaxPenaltyPerCategory = 5.0;

/// Point cap for the water-over-goal bonus.
const double kMaxWaterBonus = 5.0;

/// Waking-hours window used to pace the daily calorie score. Eating doesn't
/// spread across midnight-to-midnight, so pacing against a 7am-10pm window
/// avoids reading "ahead of pace" purely because it's 3am.
const int kWakeHour = 7;
const int kSleepHour = 22;

/// Floor on the elapsed-window fraction so the pace ratio doesn't spike or
/// divide by (near) zero in the first few minutes of the waking window.
const double kMinPaceFraction = 0.05;

// ---------------------------------------------------------------------------
// Habits
// ---------------------------------------------------------------------------

/// Per-habit credit toward the habits sub-score, for "today".
///
/// Daily-frequency habits are binary — there's no notion of "still
/// achievable later this week" for something due every day, so it's just
/// [HabitWithStatus.completedToday].
///
/// Weekly-frequency habits use a feasibility rule instead of a straight
/// completions/target ratio: a habit that isn't done yet but could still
/// hit its target by the end of the week (Mon-Sun) shouldn't drag the score
/// down just for not being done *yet* — only once the target is
/// mathematically out of reach does its real ratio count against the day.
double habitDailyCredit(HabitWithStatus h, {required int weekday}) {
  if (h.habit.frequencyType != 'weekly') {
    return h.completedToday ? 1.0 : 0.0;
  }
  final target = h.habit.targetDaysPerWeek;
  if (target <= 0) return 1.0;

  final effective = h.completionsThisWeek + h.skipsThisWeek;
  if (effective >= target) return 1.0;

  final remainingDays = 8 - weekday; // weekday: Mon=1..Sun=7, incl. today
  final needed = target - effective;
  if (needed <= remainingDays) return 1.0; // still achievable this week
  return (effective / target).clamp(0.0, 1.0); // target is out of reach
}

/// Averages per-habit daily credit across all of today's habits. Returns
/// null when there are no habits at all — callers should treat that as "no
/// data" (excluded from the score), not a 0.
double? habitPctForDay(List<HabitWithStatus> habits, {DateTime? now}) {
  if (habits.isEmpty) return null;
  final weekday = (now ?? DateTime.now()).weekday;
  final total = habits.fold<double>(
    0,
    (s, h) => s + habitDailyCredit(h, weekday: weekday),
  );
  return total / habits.length;
}

// ---------------------------------------------------------------------------
// Calorie pacing (daily only)
// ---------------------------------------------------------------------------

/// Paces a raw 0.0-1.0 calorie ratio against how far "now" is through the
/// waking window, capped at 1.0 once at or ahead of pace. Being at 30% of
/// the goal at 30% through the day reads as fully on-track (1.0), not a
/// discouraging 30%.
double paceCalPct(double rawCalPct, {DateTime? now}) {
  final t = now ?? DateTime.now();
  final minutesIntoWindow = (t.hour * 60 + t.minute) - kWakeHour * 60;
  final windowMinutes = (kSleepHour - kWakeHour) * 60;
  final elapsedFraction = (minutesIntoWindow / windowMinutes).clamp(0.0, 1.0);
  final flooredFraction = math.max(elapsedFraction, kMinPaceFraction);
  return (rawCalPct / flooredFraction).clamp(0.0, 1.0);
}

// ---------------------------------------------------------------------------
// Overconsumption penalty + water bonus (shared by daily and weekly)
// ---------------------------------------------------------------------------

/// One over-goal nutrient's point deduction: 0 at or under the goal,
/// ramping linearly to [kMaxPenaltyPerCategory] at 2x the goal, then
/// holding at the cap beyond that — so one badly-blown-out nutrient can't
/// wipe out the whole score by itself.
double categoryPenalty(double actual, double? goal) {
  if (goal == null || goal <= 0 || actual <= goal) return 0.0;
  final overFraction = (actual - goal) / goal;
  return math.min(1.0, overFraction) * kMaxPenaltyPerCategory;
}

/// Water's over-goal bonus: 0 up to the goal, ramping linearly to
/// [kMaxWaterBonus] at 2x the goal, then holding at the cap.
double waterBonus(double actualMl, double? goalMl) {
  if (goalMl == null || goalMl <= 0 || actualMl <= goalMl) return 0.0;
  final overFraction = (actualMl - goalMl) / goalMl;
  return math.min(1.0, overFraction) * kMaxWaterBonus;
}

/// Sums per-category penalties for the standard "over is bad" nutrient set:
/// fat, sugar, sodium, cholesterol, carbs. Any goal left null contributes
/// nothing (e.g. sugar has no per-user goal column — pass NutritionRDA.sugar
/// as its fallback goal at the call site, same as the rest of the app).
double overconsumptionPenalty({
  required double fat,
  double? fatGoal,
  required double sugar,
  double? sugarGoal,
  required double sodium,
  double? sodiumGoal,
  required double cholesterol,
  double? cholesterolGoal,
  required double carbs,
  double? carbsGoal,
}) {
  return categoryPenalty(fat, fatGoal) +
      categoryPenalty(sugar, sugarGoal) +
      categoryPenalty(sodium, sodiumGoal) +
      categoryPenalty(cholesterol, cholesterolGoal) +
      categoryPenalty(carbs, carbsGoal);
}

// ---------------------------------------------------------------------------
// Combining
// ---------------------------------------------------------------------------

/// Combines a habits sub-score and a nutrition sub-score (each already
/// 0.0-1.0) into a final 0-100 score, applying the shared overconsumption
/// penalty and water bonus on top. Either sub-score may be null when
/// there's nothing to measure for it (no habits configured, no nutrition
/// data); if both are null there's nothing to score at all, and this
/// returns null so the caller can show "—" instead of a misleading 0%.
double? combineScore({
  required double? habitPct,
  required double? nutritionPct,
  double overconsumptionPts = 0.0,
  double waterBonusPts = 0.0,
}) {
  final parts = [habitPct, nutritionPct].whereType<double>().toList();
  if (parts.isEmpty) return null;
  final base = parts.reduce((a, b) => a + b) / parts.length;
  return (base * 100 - overconsumptionPts + waterBonusPts).clamp(0.0, 100.0);
}
