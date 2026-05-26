// shared/widgets.dart — App-wide reusable widgets.
//
// Widgets here are used across multiple feature screens.
// Import this file instead of repeating the widget in each feature.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_theme.dart';

// The logo AppBar title — identical across all main screens.
class AppLogoTitle extends StatelessWidget {
  const AppLogoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 0, right: 20.0, bottom: 20.0),
      child: SvgPicture.asset(
        'assets/images/logo.svg',
        height: 100,
        width: 150,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

// The drag handle shown at the top of bottom sheets.
class AppDragHandle extends StatelessWidget {
  const AppDragHandle({super.key, this.bottomMargin = AppSpacing.md});
  final double bottomMargin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: EdgeInsets.only(bottom: bottomMargin),
        decoration: BoxDecoration(
          color: AppColors.glassBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// Streak display — large colored number. Renders nothing when streak == 0.
// Color escalates with streak length so users feel momentum building.
// Use StreakBadge.color(n) to get the same color for accent bars / borders.
class StreakBadge extends StatelessWidget {
  const StreakBadge(this.streak, {super.key});
  final int streak;

  static Color color(int n) {
    if (n >= 30) return const Color(0xFFFFB347); // gold
    if (n >= 14) return const Color(0xFF4ECDC4); // teal
    if (n >= 7)  return const Color(0xFF6BCB77); // green
    return const Color(0xFF82C4A0);              // mint
  }

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();
    return Text(
      '$streak',
      style: AppTextStyles.titleLarge.copyWith(
        color: color(streak),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// A selectable chip used in meal pickers and similar selectors.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.terracotta : AppColors.glassBg,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: selected ? AppColors.terracotta : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: selected ? Colors.white : AppColors.textOnDark,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
