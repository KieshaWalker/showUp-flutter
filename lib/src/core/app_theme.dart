import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Palette — Warm, earthy, cozy
// ---------------------------------------------------------------------------
class AppColors {
  AppColors._();

  // Primaries
  static const khaki = Color(0xFFC4B49A); // Universal Khaki
  static const mahogany = Color(0xFF7B3F2E); // Warm Mahogany
  static const silhouette = Color(0xFF2E2A27); // Silhouette (near-black)
  static const eucalyptus = Color(0xFF7A8C6E); // Warm Eucalyptus
  static const sage = Color.fromARGB(150, 63, 72, 55); // Soft Sage

  // Accents
  static const terracotta = Color(0xFFBF5C3A); // primary action
  static const ochre = Color(0xFFC48B2F);
  static const olive = Color(0xFF6B7A3E);
  static const plum = Color(0xFF5C3D5E);
  static const mutedRose = Color(0xFFB07070);
  static const persimmon = Color(0xFFE2603A); // vibrant accent

  // Neutrals / backgrounds
  static const cream = Color.fromARGB(255, 125, 118, 107);
  static const warmWhite = Color.fromARGB(255, 211, 191, 156);
  static const surface = Color(0xFFEFE9DE);
  static const cardSurface = Color.fromARGB(255, 149, 139, 234);
  static const divider = Color.fromARGB(255, 116, 191, 235);

  // Semantic
  static const success = eucalyptus;
  static const warning = ochre;
  static const error = terracotta;

  // Macro colors
  static const calColor = terracotta;
  static const proteinColor = Color(0xFF4A7EA5); // muted steel blue
  static const carbColor = ochre;
  static const fatColor = Color(0xFF8B6E3C); // warm tan
  static const waterColor = Color(0xFF5B8FA8); // dusty blue
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------
class AppTextStyles {
  AppTextStyles._();

  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.silhouette,
    letterSpacing: -0.5,
  
  );

  static const headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.silhouette,
    letterSpacing: -0.2,
  );

  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.silhouette,
  );

  static const titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.silhouette,
  );

  static const bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.silhouette,
  );

  static const bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF6B6259),
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xFF9A8F85),
    letterSpacing: 0.5,
  );
}

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      brightness: Brightness.light,
    );

    final scheme = base.copyWith(
      primary: AppColors.terracotta,
      onPrimary: Colors.white,
      secondary: AppColors.mahogany,
      onSecondary: Colors.white,
      tertiary: AppColors.eucalyptus,
      surface: AppColors.warmWhite,
      surfaceContainerHighest: AppColors.surface,
      outline: AppColors.divider,
      onSurface: AppColors.silhouette,
      error: AppColors.terracotta,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.silhouette,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.divider,
        titleTextStyle: AppTextStyles.titleLarge,
        centerTitle: true,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Bottom nav
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.warmWhite,
        indicatorColor: AppColors.terracotta.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.terracotta);
          }
          return const IconThemeData(color: AppColors.khaki);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall
                .copyWith(color: AppColors.terracotta);
          }
          return AppTextStyles.labelSmall;
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.divider,
        elevation: 4,
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.titleMedium
              .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.terracotta,
          side: const BorderSide(color: AppColors.terracotta),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          textStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.terracotta),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mahogany,
          textStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.mahogany),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.warmWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: StadiumBorder(),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
}


// padding widget

class AppPaddings {
  AppPaddings._();

  static const horizontal = EdgeInsets.symmetric(horizontal: 16);
  static const vertical = EdgeInsets.symmetric(vertical: 16);
  static const all = EdgeInsets.all(16);
}
// to use this in the codebase, simply import AppPaddings and use it like this:
// Padding(
//   padding: AppPaddings.horizontal,
//   child: YourWidget(),
// )