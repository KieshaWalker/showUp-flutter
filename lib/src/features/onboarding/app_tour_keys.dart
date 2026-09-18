// app_tour_keys.dart — GlobalKeys shared between main.dart (bottom nav),
// presentation_screen.dart (Overview widgets), and pantry_screen.dart (the
// barcode-scan FAB) so each file can wrap its own widgets in Showcase()
// without importing another screen's internals.
//
// See app_tour.dart for how these are used to drive the coach-mark tour.

import 'package:flutter/widgets.dart';

final heroCardKey = GlobalKey();
final quickAddKey = GlobalKey();
final navNutritionKey = GlobalKey();
final navPantryKey = GlobalKey();
final navHabitsKey = GlobalKey();
final navCalendarKey = GlobalKey();
final settingsIconKey = GlobalKey();
final pantryScanFabKey = GlobalKey();

/// Stage one of the tour: every key here is on a widget that's already
/// visible on the Overview tab (the screen a user lands on right after
/// login) — no tab-switching needed for this stage.
final appTourSteps = [
  heroCardKey,
  quickAddKey,
  navNutritionKey,
  navPantryKey,
  navHabitsKey,
  navCalendarKey,
  settingsIconKey,
];

/// Stage two: run separately, after switching the bottom nav to the Pantry
/// tab, since [pantryScanFabKey] only exists once PantryScreen is built. See
/// app_tour.dart's onFinish handling for how the two stages are chained.
final pantryTourSteps = [pantryScanFabKey];
