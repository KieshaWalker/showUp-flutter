import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Palette
// ---------------------------------------------------------------------------
class AppColors {
  AppColors._();

  static const terracotta = ui.Color.fromARGB(168, 158, 143, 138);
  static const ochre      = ui.Color.fromARGB(155, 191, 121, 0);
  static const eucalyptus = ui.Color.fromARGB(255, 76, 156, 47);
  static const sage       = Color(0xFF6E8260);
  static const khaki      = Color(0xFFAF9878);
  static const mahogany   = Color(0xFF72281A);
  static const silhouette = Color(0xFF1C1814);
  static const olive      = Color(0xFF5A6A30);
  static const plum       = Color(0xFF4E3052);
  static const persimmon  = ui.Color.fromARGB(255, 137, 77, 64);

  // Legacy light-mode surfaces (kept for reference)
  static const cream       = Color(0xFFE8DECA);
  static const warmWhite   = Color(0xFFDDD0BA);
  static const surface     = Color(0xFFD4C4A8);
  static const cardSurface = Color(0xFFD9CCB4);
  static const divider     = Color(0xFFC0AE94);

  static const success = eucalyptus;
  static const warning = ochre;
  static const error   = terracotta;

  // Macro colors
  static const calColor     = terracotta;
  static const proteinColor = Color(0xFF4A9ECC);
  static const carbColor    = ochre;
  static const fatColor     = Color(0xFFBF7800);
  static const waterColor   = Color(0xFF5AAED4);

  // ---------------------------------------------------------------------------
  // Dark glass palette
  // ---------------------------------------------------------------------------
  /// App base — very dark navy
  static const darkBase = Color(0xFF08051A);

  /// Glass card surface — rgba(255,255,255,0.18)
  static const glassBg     = Color(0x2EFFFFFF);
  /// Glass border — rgba(255,255,255,0.15)
  static const glassBorder = Color(0x26FFFFFF);
  /// Heavier glass for modals/sheets — rgba(20,16,50,0.88)
  static const glassModal  = Color(0xE0141032);

  /// White text primary (~78%)
  static const textOnDark          = Color(0xC7FFFFFF);
  /// White text secondary (~65%)
  static const textOnDarkSecondary = Color(0xA6FFFFFF);
  /// White text tertiary / labels (~50%)
  static const textOnDarkTertiary  = Color(0x80FFFFFF);

  // Gradient stop colours — from CSS spec
  static const gradientDeepPurple = Color(0x833900A3);
  static const gradientDuskyRose  = Color(0x9F794949);
  static const gradientNavyBlue   = Color(0x7E1324C4);

  // Activity tints
  static const activityBg       = Color(0x800044FF);
  static const habitsActivityBg  = Color(0x8034C759);

  // Glass button tints — from --btn* CSS vars
  static const btnSmallBg     = Color(0x33FFFFFF);
  static const btnSmallBorder = Color(0x4DFFFFFF);
  static const btnLargeBg     = Color(0x4DFFFFFF);
  static const btnLargeBorder = Color(0x66FFFFFF);
}

// ---------------------------------------------------------------------------
// Typography — white on dark glass
// ---------------------------------------------------------------------------
class AppTextStyles {
  AppTextStyles._();

  static const displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -1.0,
    height: 1.1,
    textBaseline: TextBaseline.alphabetic,
    
  );

  static const headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.4,
    height: 1.2,
  );

  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.1,
    height: 1.3,
  );

  static const bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDark,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDarkSecondary,
    height: 1.4,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDarkTertiary,
    letterSpacing: 0.6,
    height: 1.2,
  );
}

// ---------------------------------------------------------------------------
// Theme — dark glass
// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._();

  static ThemeData get glass {
    const scheme = ColorScheme.dark(
      primary: AppColors.terracotta,
      onPrimary: Colors.white,
      secondary: AppColors.ochre,
      onSecondary: Colors.white,
      tertiary: AppColors.eucalyptus,
      surface: AppColors.glassBg,
      onSurface: Colors.white,
      outline: AppColors.glassBorder,
      error: Color(0xFFFF5252),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0x1AFFFFFF),
        indicatorColor: const Color(0x33D04820),
        indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.terracotta, size: 22);
          }
          return const IconThemeData(color: AppColors.textOnDarkTertiary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta);
          }
          return AppTextStyles.labelSmall;
        }),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        height: 68,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.terracotta,
          side: const BorderSide(color: AppColors.terracotta, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x1AFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnDarkTertiary),
        floatingLabelStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.terracotta),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        elevation: 2,
        focusElevation: 4,
        shape: StadiumBorder(),
        extendedTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 0.75,
        space: 0,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.glassModal,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        titleTextStyle: AppTextStyles.titleLarge,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.glassModal,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
        showDragHandle: false,
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.terracotta,
        inactiveTrackColor: AppColors.glassBorder,
        thumbColor: AppColors.terracotta,
        overlayColor: Color(0x1FD04820),
        valueIndicatorColor: AppColors.terracotta,
        valueIndicatorTextStyle: AppTextStyles.labelSmall,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassBg,
        selectedColor: const Color(0x33D04820),
        labelStyle: AppTextStyles.labelSmall,
        side: const BorderSide(color: AppColors.glassBorder, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spacing constants
// ---------------------------------------------------------------------------
class AppPaddings {
  AppPaddings._();

  static const horizontal = EdgeInsets.symmetric(horizontal: 16);
  static const vertical   = EdgeInsets.symmetric(vertical: 16);
  static const all        = EdgeInsets.all(16);
  static const card       = EdgeInsets.all(20);
  static const section    = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}

// ---------------------------------------------------------------------------
// Spacing scale
// ---------------------------------------------------------------------------
class AppSpacing {
  AppSpacing._();

  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 60;
}

// ---------------------------------------------------------------------------
// Border radius scale
// ---------------------------------------------------------------------------
class AppRadius {
  AppRadius._();

  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double full = 9999;

  static BorderRadius circular(double r) => BorderRadius.circular(r);

  static const smAll   = BorderRadius.all(Radius.circular(sm));
  static const mdAll   = BorderRadius.all(Radius.circular(md));
  static const lgAll   = BorderRadius.all(Radius.circular(lg));
  static const xlAll   = BorderRadius.all(Radius.circular(xl));
  static const fullAll = BorderRadius.all(Radius.circular(full));
}

// ---------------------------------------------------------------------------
// Shadow scale
// ---------------------------------------------------------------------------
class AppShadows {
  AppShadows._();

  static const sm = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const md = [
    BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 4)),
  ];
  static const lg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10)),
  ];
  static const xl = [
    BoxShadow(color: Color(0x26000000), blurRadius: 25, offset: Offset(0, 20)),
  ];
  static const cool = [
    BoxShadow(color: Color(0x227CF4FF), blurRadius: 30, offset: Offset(0, 10)),
  ];
  static const glass = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 32, offset: Offset(0, 8)),
  ];
}

// ---------------------------------------------------------------------------
// Glass helpers
// ---------------------------------------------------------------------------
class AppGlass {
  AppGlass._();

  /// BoxDecoration for glass surfaces.
  static BoxDecoration decoration({
    BorderRadius borderRadius = AppRadius.lgAll,
    Color bg = AppColors.glassBg,
    Color border = AppColors.glassBorder,
  }) =>
      BoxDecoration(
        color: bg,
        borderRadius: borderRadius,
        border: Border.all(color: border, width: 1),
        boxShadow: AppShadows.glass,
      );

  /// Widget: blurred glass card. Wrap any content in this.
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    BorderRadius borderRadius = AppRadius.lgAll,
    Color? bg,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: decoration(
            borderRadius: borderRadius,
            bg: bg ?? AppColors.glassBg,
          ),
          child: child,
        ),
      ),
    );
  }

  /// Modal-style heavier glass.
  static BoxDecoration modal({BorderRadius borderRadius = AppRadius.xlAll}) =>
      BoxDecoration(
        color: AppColors.glassModal,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: AppShadows.xl,
      );
}

// ---------------------------------------------------------------------------
// Gradient helpers
// ---------------------------------------------------------------------------
class AppGradients {
  AppGradients._();

  /// Radial background — matches CSS --backgroundgradial
  static const background = RadialGradient(
    center: Alignment.center,
    radius: 2.0,
    colors: [
      ui.Color.fromARGB(105, 38, 132, 240),
      ui.Color.fromARGB(255, 123, 84, 196),
      ui.Color.fromARGB(245, 208, 110, 110),
    ],
  );

  /// Linear accent gradient — matches CSS --backgroundgradialtwo
  static const accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.glassBg, AppColors.glassBorder],
  );
}

// ---------------------------------------------------------------------------
// Background widget — dark base + radial gradient overlay
// ---------------------------------------------------------------------------
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.darkBase),
        Container(
          decoration: const BoxDecoration(gradient: AppGradients.background),
        ),
        child,
      ],
    );
  }
}
