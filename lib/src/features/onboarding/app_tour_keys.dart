// app_tour_keys.dart — GlobalKeys shared between main.dart (bottom nav) and
// presentation_screen.dart (Overview widgets) so both files can wrap their
// own widgets in Showcase() without importing each other's internals.
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

/// Order the tour visits these keys in. Every step is on a widget that's
/// already visible on the Overview tab (the screen a user lands on right
/// after login) — no tab-switching needed mid-tour.
final appTourSteps = [
  heroCardKey,
  quickAddKey,
  navNutritionKey,
  navPantryKey,
  navHabitsKey,
  navCalendarKey,
  settingsIconKey,
];
