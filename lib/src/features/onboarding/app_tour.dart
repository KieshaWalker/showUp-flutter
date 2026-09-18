// app_tour.dart — Skippable coach-mark tour over the app's real chrome:
// stage one covers Overview's hero card + quick-add, then the bottom nav
// tabs, then the settings icon; stage two switches the bottom nav to the
// Pantry tab and points out the barcode-scan FAB there. Shown once right
// after the welcome setup sheet.
//
// Built on package:showcaseview (v5 controller API — no ancestor widget
// needed; ShowcaseView.register()/get()/unregister() work off a global
// registry keyed by `scope`).
//
// Why two stages instead of one flat step list:
//   [pantryScanFabKey] only exists once PantryScreen is actually built, and
//   showcaseview resolves a step's target at the moment that step starts —
//   there's no built-in way to navigate mid-sequence and have it wait for
//   the new screen to mount. So stage one runs as an ordinary startShowCase
//   over Overview's widgets; its onFinish callback then switches the bottom
//   nav tab, awaits the resulting frame (via endOfFrame) so PantryScreen's
//   Showcase-wrapped FAB is actually in the tree, and only then starts stage
//   two as its own startShowCase call. onFinish fires again when stage two
//   completes, and that's when the tour is finally marked seen. Skipping
//   (onDismiss) at either stage marks it seen immediately, without forcing
//   the user into the next stage.
//
// Connections:
//   main.dart               — registerAppTour()/unregisterAppTour() in
//                              AppShell's init/dispose; maybeStartAppTour()
//                              chained after maybeShowWelcomeSetup()
//   app_tour_keys.dart       — the GlobalKeys + step order this file drives
//   presentation_screen.dart — wraps its own widgets with appTourTarget()
//   pantry_screen.dart       — wraps the Scan Barcode FAB with appTourTarget()

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import 'app_tour_keys.dart';

Future<void> _markTourSeen() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('app_tour_seen_$userId', true);
}

bool _pantryStageStarted = false;
ValueChanged<int>? _switchToTab;

/// Index of the Pantry tab in AppShell's bottom nav — see main.dart's
/// `_screens` list (0=Overview, 1=Nutrition, 2=Pantry, 3=Habits, 4=Calendar).
const _pantryTabIndex = 2;

Future<void> _handleStageFinish() async {
  if (!_pantryStageStarted) {
    _pantryStageStarted = true;
    _switchToTab?.call(_pantryTabIndex);
    await WidgetsBinding.instance.endOfFrame;
    ShowcaseView.get().startShowCase(pantryTourSteps);
    return;
  }
  await _markTourSeen();
}

void _handleDismiss([GlobalKey? _]) => _markTourSeen();

/// Call once from the widget that owns every Showcase-wrapped target
/// (AppShell) — pairs with [unregisterAppTour] in that widget's dispose().
/// [onSwitchToTab] lets stage two switch the bottom nav to Pantry before it
/// starts — pass whatever setState call AppShell uses to change its
/// selected tab index.
void registerAppTour({required ValueChanged<int> onSwitchToTab}) {
  _switchToTab = onSwitchToTab;
  _pantryStageStarted = false;
  ShowcaseView.register(
    onFinish: () => _handleStageFinish(),
    onDismiss: _handleDismiss,
    blurValue: 1,
    globalTooltipActionConfig: const TooltipActionConfig(
      position: TooltipActionPosition.inside,
      alignment: MainAxisAlignment.spaceBetween,
    ),
    globalTooltipActions: [
      TooltipActionButton(
        type: TooltipDefaultActionType.previous,
        // Each stage starts a fresh sequence at index 0, so both stages'
        // first steps need "previous" hidden, not just the tour's overall
        // first step.
        hideActionWidgetForShowcase: [appTourSteps.first, pantryTourSteps.first],
        textStyle: const TextStyle(color: AppColors.textOnDarkSecondary),
      ),
      TooltipActionButton(
        type: TooltipDefaultActionType.skip,
        textStyle: const TextStyle(color: AppColors.textOnDarkSecondary),
      ),
      TooltipActionButton(
        type: TooltipDefaultActionType.next,
        hideActionWidgetForShowcase: [pantryTourSteps.last],
        backgroundColor: AppColors.terracotta,
        textStyle: const TextStyle(color: Colors.white),
      ),
    ],
  );
}

void unregisterAppTour() => ShowcaseView.get().unregister();

/// Starts the tour if this user hasn't seen (or skipped) it before.
/// Safe to call every app launch — it's a no-op once seen.
Future<void> maybeStartAppTour(BuildContext context) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('app_tour_seen_$userId') ?? false) return;

  if (!context.mounted) return;
  ShowcaseView.get().startShowCase(appTourSteps);
}

/// Manually replays the full tour from the beginning, regardless of whether
/// this account has already seen (or skipped) it — used by Settings'
/// "Give Me a Tour" row. [context] may belong to a screen pushed on top of
/// AppShell (Settings usually is), so this pops back to it first and
/// switches to the Overview tab, since stage one's targets only exist there.
void restartAppTour(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
  _switchToTab?.call(0);
  _pantryStageStarted = false;
  WidgetsBinding.instance.endOfFrame.then((_) {
    ShowcaseView.get().startShowCase(appTourSteps);
  });
}

/// Wraps [child] in a Showcase styled to match the app's glass theme.
Widget appTourTarget({
  required GlobalKey key,
  required String title,
  required String description,
  required Widget child,
}) {
  return Showcase(
    key: key,
    title: title,
    description: description,
    titleTextStyle: AppTextStyles.titleMedium.copyWith(
      color: AppColors.terracotta,
      fontWeight: FontWeight.w700,
    ),
    descTextStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnDark),
    tooltipBackgroundColor: AppColors.glassModal,
    targetBorderRadius: AppRadius.mdAll,
    child: child,
  );
}
