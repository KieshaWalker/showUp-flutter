import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/core/app_theme.dart';
import 'src/core/env.dart';
import 'src/features/auth/auth_provider.dart';
import 'src/features/auth/auth_screen.dart';
import 'src/features/habits/habits_notifier.dart';
import 'src/features/habits/habits_screen.dart';
import 'src/features/nutrition/nutrition_notifier.dart';
import 'src/features/nutrition/nutrition_screen.dart';
import 'src/features/onboarding/app_tour.dart';
import 'src/features/onboarding/app_tour_keys.dart';
import 'src/features/onboarding/welcome_setup_sheet.dart';
import 'src/features/pantry/pantry_notifier.dart';
import 'src/features/pantry/pantry_screen.dart';
import 'src/features/presentation/presentation_screen.dart';
import 'src/features/calendar/calendar_screen.dart';
import 'src/features/recipes/recipes_notifier.dart';
import 'src/features/tracking/tracking_notifier.dart';

// main.dart — App entry point and top-level routing.
//
// Startup sequence:
//   1. main() initializes Supabase with the URL + key from env.dart
//   2. ShowUpApp builds the MaterialApp with our glass theme (app_theme.dart)
//   3. _AuthGate watches authStateProvider (auth_provider.dart) to decide:
//        • session exists  → show AppShell (the main tabbed UI)
//        • no session      → show AuthScreen (login / sign-up)
//
// AppShell:
//   Renders the bottom nav bar (Overview, Nutrition, Pantry, Habits,
//   Calendar) and swaps between the 5 main screens. Settings isn't a tab —
//   every screen has a settings icon in its AppBar's top-right corner
//   (openSettingsScreen(), settings_screen.dart) that pushes SettingsScreen
//   as a modal route instead.
//   On first mount it calls syncFromRemote() on every feature's notifier so
//   the app catches up with any data added on other devices, then (once) shows
//   the one-time welcome setup sheet for brand-new users (see
//   welcome_setup_sheet.dart).
//
// Connections:
//   env.dart                  — provides SUPABASE_URL and SUPABASE_ANON_KEY
//   auth_provider.dart        — authStateProvider drives the auth gate
//   auth_screen.dart          — shown when logged out
//   welcome_setup_sheet.dart  — one-time post-login habit/goal setup prompt
//   presentation_screen       — Overview tab (screen index 0)
//   nutrition_screen          — Nutrition tab (screen index 1)
//   pantry_screen             — Pantry tab (screen index 2)
//   habits_screen             — Habits tab (screen index 3)
//   calendar_screen           — Calendar tab (screen index 4)
//   settings_screen           — Settings (reached via each screen's AppBar,
//                                not a tab)

/// Entry point for the Show Up application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: ShowUpApp()));
}

class ShowUpApp extends StatelessWidget {
  const ShowUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Show Up',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.glass,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading:
          () => const AppBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
      // A transient error on the auth stream (e.g. a network blip during
      // token refresh) shouldn't log the user out if a session is still
      // cached locally — only fall back to AuthScreen if it really is gone.
      error:
          (_, _) =>
              Supabase.instance.client.auth.currentSession != null
                  ? const AppShell()
                  : const AuthScreen(),
      data: (state) {
        if (state.session != null) return const AppShell();
        return const AuthScreen();
      },
    );
  }
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // 0=Overview, 1=Nutrition, 2=Pantry, 3=Habits, 4=Calendar
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Push any local writes that failed to sync earlier (e.g. made while
    // offline), then pull latest data from Supabase, on every login / app
    // launch. Each call is fire-and-forget (errors are swallowed in the
    // notifiers). Push runs first so pending local writes reach Supabase
    // before being compared against a pull.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(habitsNotifierProvider.notifier).pushUnsyncedChanges();
      await ref.read(nutritionNotifierProvider.notifier).pushUnsyncedChanges();
      await ref.read(pantryNotifierProvider.notifier).pushUnsyncedChanges();
      await ref
          .read(mealTemplatesNotifierProvider.notifier)
          .pushUnsyncedChanges();
      await ref.read(recipesNotifierProvider.notifier).pushUnsyncedChanges();
      await ref.read(trackingNotifierProvider.notifier).pushUnsyncedChanges();

      ref.read(habitsNotifierProvider.notifier).syncFromRemote();
      ref.read(nutritionNotifierProvider.notifier).syncFromRemote();
      ref.read(pantryNotifierProvider.notifier).syncFromRemote();
      ref.read(mealTemplatesNotifierProvider.notifier).syncFromRemote();
      ref.read(recipesNotifierProvider.notifier).syncFromRemote();
      ref.read(trackingNotifierProvider.notifier).syncFromRemote();

      if (mounted) await maybeShowWelcomeSetup(context, ref);
      if (mounted) await maybeStartAppTour(context);
    });
    registerAppTour(onSwitchToTab: (i) => setState(() => _currentIndex = i));
  }

  @override
  void dispose() {
    unregisterAppTour();
    super.dispose();
  }

  static const _screens = [
    PresentationScreen(),
    NutritionScreen(),
    PantryScreen(),
    HabitsScreen(),
    CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: appTourTarget(
                key: navNutritionKey,
                title: 'Nutrition',
                description: 'Log meals, water, and nutrients here.',
                child: const Icon(Icons.restaurant_menu_outlined),
              ),
              selectedIcon: const Icon(Icons.restaurant_menu),
              label: 'Nutrition',
            ),
            NavigationDestination(
              icon: appTourTarget(
                key: navPantryKey,
                title: 'Pantry',
                description: 'Save your own foods for faster logging.',
                child: const Icon(Icons.kitchen_outlined),
              ),
              selectedIcon: const Icon(Icons.kitchen),
              label: 'Pantry',
            ),
            NavigationDestination(
              icon: appTourTarget(
                key: navHabitsKey,
                title: 'Habits',
                description: 'Add, edit, and track your habit streaks.',
                child: const Icon(Icons.check_circle_outline),
              ),
              selectedIcon: const Icon(Icons.check_circle),
              label: 'Habits',
            ),
            NavigationDestination(
              icon: appTourTarget(
                key: navCalendarKey,
                title: 'Calendar',
                description: 'See your history and trends over time.',
                child: const Icon(Icons.calendar_month_outlined),
              ),
              selectedIcon: const Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
          ],
        ),
      ),
    );
  }
}
