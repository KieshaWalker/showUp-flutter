import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import '../profile/profile_notifier.dart';
import '../profile/profile_screen.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings'),
        titleTextStyle: AppTextStyles.displayLarge,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
     
      body: SingleChildScrollView(
        padding: AppPaddings.section,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              _ProfileHeader(),
              const SizedBox(height: AppSpacing.lg - 4) ]
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log out?', style: AppTextStyles.titleMedium),
        content: Text(
          'You will be returned to the login screen.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.terracotta,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await Supabase.instance.client.auth.signOut();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
class _ProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final name = profile?.displayName ?? '';
    final username = profile?.username;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
      child: AppGlass.card(
        padding: AppPaddings.section,
        borderRadius: AppRadius.lgAll,
        child: Row(
          children: [
            ProfileAvatar(size: 52),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Your Profile',
                    style: AppTextStyles.titleMedium,
                  ),
                  if (username != null && username.isNotEmpty)
                    Text(
                      '@$username',
                      style: AppTextStyles.bodyMedium,
                    ),
                  if (name.isEmpty && (username == null || username.isEmpty))
                    Text(
                      'Tap to set up your profile',
                      style: AppTextStyles.bodyMedium,
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.khaki,
            ),
          ],
        ),
      ),
    );
  }
}

// --------