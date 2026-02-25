import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/core/app_theme.dart';
import 'src/features/auth/auth_provider.dart';
import 'src/features/auth/auth_screen.dart';
import 'src/features/habits/habits_screen.dart';
import 'src/features/nutrition/nutrition_screen.dart';
import 'src/features/presentation/presentation_screen.dart';
import 'src/features/settings/settings_screen.dart';
import 'src/features/features_ui/calendar/calendar_screen.dart';
/// Entry point for the Show Up application.
/// Initializes Supabase for backend services and wraps the app with ProviderScope (Riverpod dependency injection).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

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
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

/// Root navigation gate that determines whether to show AuthScreen or AppShell.
/// Listens to authStateProvider (Riverpod) to watch authentication status in real-time.
/// - Shows loading spinner while checking auth
/// - Routes to AuthScreen if not logged in
/// - Routes to AppShell (main app) if logged in with valid session
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const AuthScreen(),
      data: (state) {
        if (state.session != null) {
          return const AppShell();
        }
        return const AuthScreen();
      },
    );
  }
}

/// Main application shell with 3-tab bottom navigation.
/// Displays one of three main screens based on selected tab:
/// 1. NutritionScreen - Track daily meals, macros, and water intake
/// 2. HabitsScreen - Manage daily/weekly habits and streaks
/// 3. PresentationScreen - View progress analytics/dashboard
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

/// State management for tab switching in the main app shell.
/// Maintains _currentIndex to track which screen is being displayed.
class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    PresentationScreen(),
    CalendarScreen(),
    NutritionScreen(),
    HabitsScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
              NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Presentation',
          ),
           NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
      
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
         
        ],
      ),
    );
  }
}
