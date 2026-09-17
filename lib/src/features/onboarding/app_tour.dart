// app_tour.dart — Skippable coach-mark tour over the app's real chrome
// (Overview's hero card + quick-add, then the bottom nav tabs, then the
// settings icon), shown once right after the welcome setup sheet.
//
// Built on package:showcaseview (v5 controller API — no ancestor widget
// needed; ShowcaseView.register()/get()/unregister() work off a global
// registry keyed by `scope`).
//
// Connections:
//   main.dart               — registerAppTour()/unregisterAppTour() in
//                              AppShell's init/dispose; maybeStartAppTour()
//                              chained after maybeShowWelcomeSetup()
//   app_tour_keys.dart       — the GlobalKeys + step order this file drives
//   presentation_screen.dart — wraps its own widgets with appTourTarget()

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import 'app_tour_keys.dart';

Future<void> _markTourSeen([GlobalKey? _]) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('app_tour_seen_$userId', true);
}

/// Call once from the widget that owns every Showcase-wrapped target
/// (AppShell) — pairs with [unregisterAppTour] in that widget's dispose().
void registerAppTour() {
  ShowcaseView.register(
    onFinish: _markTourSeen,
    onDismiss: _markTourSeen,
    blurValue: 1,
    globalTooltipActionConfig: const TooltipActionConfig(
      position: TooltipActionPosition.inside,
      alignment: MainAxisAlignment.spaceBetween,
    ),
    globalTooltipActions: [
      TooltipActionButton(
        type: TooltipDefaultActionType.previous,
        hideActionWidgetForShowcase: [appTourSteps.first],
        textStyle: const TextStyle(color: AppColors.textOnDarkSecondary),
      ),
      TooltipActionButton(
        type: TooltipDefaultActionType.skip,
        textStyle: const TextStyle(color: AppColors.textOnDarkSecondary),
      ),
      TooltipActionButton(
        type: TooltipDefaultActionType.next,
        hideActionWidgetForShowcase: [appTourSteps.last],
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
