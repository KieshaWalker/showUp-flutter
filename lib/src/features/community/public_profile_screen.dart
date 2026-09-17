// public_profile_screen.dart — Read-only view of another user's profile.
//
// Deliberately a separate screen from profile_screen.dart's ProfileScreen,
// not a reused "view mode" of it: ProfileScreen's save()/uploadAvatar()
// always act on profileProvider (i.e. the CURRENT logged-in user)
// regardless of which profile was passed in, so reusing it here would
// silently edit the viewer's own profile instead of showing the tapped
// user's — this screen has no edit affordances at all.
//
// Reached by tapping a row in community_screen.dart.
//
// Connections:
//   profile_notifier.dart — UserProfile model (passed in directly; no
//                            fetch here, community_screen.dart already has it)

import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../profile/profile_notifier.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  String get _initials {
    final name = profile.displayName;
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(name.isNotEmpty ? name : 'Profile')),
        body: ListView(
          padding: AppPaddings.all,
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.terracotta.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.terracotta.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: profile.avatarUrl != null
                      ? Image.network(
                          profile.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _InitialsText(_initials),
                        )
                      : _InitialsText(_initials),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppGlass.card(
              padding: AppPaddings.section,
              borderRadius: AppRadius.lgAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name', style: AppTextStyles.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    name.isNotEmpty ? name : 'Not set',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Username', style: AppTextStyles.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    profile.username != null && profile.username!.isNotEmpty
                        ? '@${profile.username}'
                        : 'Not set',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialsText extends StatelessWidget {
  final String initials;
  const _InitialsText(this.initials);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.terracotta,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
