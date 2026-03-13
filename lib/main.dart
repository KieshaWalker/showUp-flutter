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
import 'src/features/pantry/pantry_notifier.dart';
import 'src/features/pantry/pantry_screen.dart';
import 'src/features/presentation/presentation_screen.dart';
import 'src/features/readiness/readiness_notifier.dart';
import 'src/features/readiness/readiness_screen.dart';
import 'src/features/settings/settings_screen.dart';
import 'src/features/features_ui/calendar/calendar_screen.dart';

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
//   Renders the bottom nav bar and swaps between the 7 main screens.
//   On first mount it calls syncFromRemote() on all three notifiers so the
//   app catches up with any data added on other devices.
//
// Connections:
//   env.dart              — provides SUPABASE_URL and SUPABASE_ANON_KEY
//   auth_provider.dart    — authStateProvider drives the auth gate
//   auth_screen.dart      — shown when logged out
//   presentation_screen   — Overview tab (index 0)
//   calendar_screen       — Calendar tab (index 1)
//   nutrition_screen      — Nutrition tab (index 2)
//   pantry_screen         — Pantry tab (index 3)
//   habits_screen         — Habits tab (index 4)
//   readiness_screen      — Readiness tab (index 5)
//   settings_screen       — Settings tab (index 6)

/// Entry point for the Show Up application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

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
      loading: () => const AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => const AuthScreen(),
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
  // 0=Overview, 1=Readiness, 2=Nutrition, 3=Pantry, 4=Habits, 5=Calendar, 6=Settings
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Pull latest data from Supabase on every login / app launch.
    // Each call is fire-and-forget (errors are swallowed in the notifiers).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitsNotifierProvider.notifier).syncFromRemote();
      ref.read(nutritionNotifierProvider.notifier).syncFromRemote();
      ref.read(pantryNotifierProvider.notifier).syncFromRemote();
      ref.read(userSubstancesProvider.notifier).seedDefaultsIfEmpty();
    });
  }

  static const _screens = [
    PresentationScreen(),
    ReadinessScreen(),
    NutritionScreen(),
    PantryScreen(),
    HabitsScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MenuSheet(
        onSelect: (index) {
          setState(() => _currentIndex = index);
        },
        currentIndex: _currentIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _screens[_currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex < 2 ? _currentIndex : 2,
          onDestinationSelected: (i) {
            if (i == 2) {
              _openMenu();
            } else {
              setState(() => _currentIndex = i);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.bolt_outlined),
              selectedIcon: Icon(Icons.bolt),
              label: 'Readiness',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu),
              selectedIcon: Icon(Icons.menu),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSheet extends StatelessWidget {
  final void Function(int) onSelect;
  final int currentIndex;

  const _MenuSheet({required this.onSelect, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      (index: 4, icon: Icons.check_circle_outline, label: 'Habits'),
      (index: 2, icon: Icons.restaurant_menu_outlined, label: 'Nutrition'),
      (index: 3, icon: Icons.kitchen_outlined, label: 'Pantry'),
      (index: 5, icon: Icons.calendar_month_outlined, label: 'Calendar'),
      (index: 6, icon: Icons.settings_outlined, label: 'Settings'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.glassModal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ...items.map(
            (item) => ListTile(
              leading: Icon(item.icon,
                  color: currentIndex == item.index
                      ? AppColors.terracotta
                      : AppColors.khaki),
              title: Text(
                item.label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: currentIndex == item.index
                      ? AppColors.terracotta
                      : AppColors.textOnDark,
                  fontWeight: currentIndex == item.index
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onSelect(item.index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
