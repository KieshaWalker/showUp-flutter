// settings_screen.dart — The Settings tab: profile, account, legal, support,
// and (for admins) an admin dashboard.
//
// Shows:
//   • Profile header with avatar (ProfileAvatar), display name, and username
//     — tap opens ProfileScreen to edit
//   • Account section:
//     - Email (read-only, from the Supabase auth session)
//     - Change Password — updates the account password via Supabase auth
//     - Delete Account — calls the `delete-account` Edge Function, which
//       permanently removes the account and all Show Up data server-side
//   • Legal section:
//     - Terms & Agreement — view the current terms; shows the acceptance
//       date if on file, or an "Accept" action for accounts that predate
//       this flow (see terms_screen.dart's allowAccept)
//   • Support section:
//     - Give Me a Tour — replays the full onboarding coach-mark tour from
//       the beginning (see app_tour.dart's restartAppTour), regardless of
//       whether this account has already seen it
//     - Report an Issue — opens report_issue_screen.dart; visible to
//       everyone (admins can spot bugs too)
//     - Redeem Admin Invite Code — visible only while !isAdmin; the same
//       invite-code mechanism sign-up offers, for turning an existing
//       account into an admin without creating a new one
//   • Tracking section:
//     - Habit Tracker — opens tracking_screen.dart, for logging quantities
//       of things being cut back on (alcohol, nicotine, etc.) against an
//       optional daily/weekly limit; not a bottom-nav tab since it's an
//       opt-in, personal-use feature (same reasoning as Community/Admin)
//   • Admin section (only rendered when roleProvider is true):
//     - Admin Dashboard — opens admin_screen.dart (invite-code generation +
//       the issue queue)
//   • Log Out button (AppBar) — calls supabase.auth.signOut(), which
//     triggers authStateProvider to emit a null session → _AuthGate routes
//     back to AuthScreen
//
// Note: "Browse Community" used to live here but moved to an AppBar icon on
// presentation_screen.dart (Overview) on 2026-09-18, for a one-tap reach
// from the screen users land on.
//
// Connections:
//   profile_notifier.dart / profile_screen.dart — ProfileAvatar, edit profile,
//                                                  acceptTerms()
//   app_tour.dart                                 — restartAppTour() for
//                                                    "Give Me a Tour"
//   terms_screen.dart / terms_content.dart       — Terms & Agreement
//   role_provider.dart                           — roleProvider (isAdmin),
//                                                  redeemInviteCode()
//   admin_screen.dart / report_issue_screen.dart — Admin dashboard, issue reports
//   auth_provider.dart                           — sign-out clears session
//   main.dart (_AuthGate)                        — responds to sign-out by
//                                                  showing AuthScreen
//   supabase/functions/delete-account            — server-side account deletion
//   app_theme.dart                               — AppGlass, AppColors, AppTextStyles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/widgets.dart';
import '../../core/app_theme.dart';
import '../admin/admin_screen.dart';
import '../admin/report_issue_screen.dart';
import '../admin/role_provider.dart';
import '../onboarding/app_tour.dart';
import '../legal/terms_screen.dart';
import '../profile/profile_notifier.dart';
import '../profile/profile_screen.dart';
import '../tracking/tracking_screen.dart';

/// Pushes SettingsScreen as a modal route. Every tab's AppBar has a settings
/// icon in its top-right action slot that calls this, so Settings is reached
/// the same way from anywhere in the app instead of living in the bottom nav.
void openSettingsScreen(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final email = Supabase.instance.client.auth.currentUser?.email;
    final isAdmin = ref.watch(roleProvider).value ?? false;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const AppLogoTitle(),
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
              const _ProfileHeader(),
              const SizedBox(height: AppSpacing.lg),

              Text('Account', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              _SettingsSection(
                rows: [
                  _SettingsRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    trailingText: email ?? '—',
                  ),
                  _SettingsRow(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  _SettingsRow(
                    icon: Icons.delete_outline,
                    label: 'Delete Account',
                    color: AppColors.terracotta,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Legal', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              _SettingsSection(
                rows: [
                  _SettingsRow(
                    icon: Icons.description_outlined,
                    label: 'Terms & Agreement',
                    trailingText:
                        profile?.termsAcceptedAt != null ? 'Accepted' : null,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => TermsScreen(
                                  acceptedAt: profile?.termsAcceptedAt,
                                  allowAccept: true,
                                ),
                          ),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Support', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              _SettingsSection(
                rows: [
                  _SettingsRow(
                    icon: Icons.explore_outlined,
                    label: 'Give Me a Tour',
                    onTap: () => restartAppTour(context),
                  ),
                  _SettingsRow(
                    icon: Icons.flag_outlined,
                    label: 'Report an Issue',
                    onTap: () async {
                      final submitted = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportIssueScreen(),
                        ),
                      );
                      if (submitted == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text(
                              'Submitted successfully',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  if (!isAdmin)
                    _SettingsRow(
                      icon: Icons.key_outlined,
                      label: 'Redeem Admin Invite Code',
                      onTap: () => _showRedeemInviteDialog(context),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Tracking', style: AppTextStyles.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              _SettingsSection(
                rows: [
                  _SettingsRow(
                    icon: Icons.timeline_outlined,
                    label: 'Habit Tracker',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TrackingScreen(),
                          ),
                        ),
                  ),
                ],
              ),

              if (isAdmin) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Admin', style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                _SettingsSection(
                  rows: [
                    _SettingsRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Admin Dashboard',
                      color: AppColors.eucalyptus,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminScreen(),
                            ),
                          ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.lg - 4),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _ChangePasswordDialog());
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _DeleteAccountDialog());
  }

  void _showRedeemInviteDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _RedeemInviteDialog());
  }
}

// ---------------------------------------------------------------------------
// Profile header — tap to edit
// ---------------------------------------------------------------------------

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final name = profile?.displayName ?? '';
    final username = profile?.username;

    return GestureDetector(
      onTap:
          () => Navigator.push(
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
                    Text('@$username', style: AppTextStyles.bodyMedium),
                  if (name.isEmpty && (username == null || username.isEmpty))
                    Text(
                      'Tap to set up your profile',
                      style: AppTextStyles.bodyMedium,
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.khaki),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings section — a glass card containing a list of rows with dividers
// ---------------------------------------------------------------------------

class _SettingsSection extends StatelessWidget {
  final List<_SettingsRow> rows;
  const _SettingsSection({required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppGlass.card(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.lgAll,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 52),
            rows[i],
          ],
        ],
      ),
    );
  }
}

// A single tappable (or static, when onTap is null) settings row.
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final Color? color;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailingText,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rowColor = color ?? AppColors.textOnDark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.khaki),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(color: rowColor),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: AppTextStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.khaki),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Change password dialog
// ---------------------------------------------------------------------------

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPassword = _newPasswordCtrl.text;
    if (newPassword.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (newPassword != _confirmPasswordCtrl.text) {
      setState(() => _error = 'Passwords don\'t match.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _saving = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change password', style: AppTextStyles.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _newPasswordCtrl,
            obscureText: true,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(labelText: 'New password'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _confirmPasswordCtrl,
            obscureText: true,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.terracotta,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child:
              _saving
                  ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Delete account dialog
// ---------------------------------------------------------------------------

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _deleting = false;
  String? _error;

  Future<void> _confirmDelete() async {
    setState(() {
      _deleting = true;
      _error = null;
    });

    try {
      await Supabase.instance.client.functions.invoke(
        'delete-account',
        method: HttpMethod.post,
      );
      await Supabase.instance.client.auth.signOut();
      // No further navigation needed — signOut() flips authStateProvider,
      // and main.dart's _AuthGate swaps to AuthScreen on its own. The
      // dialog's context is gone by then along with the rest of this tree.
    } on FunctionException catch (e) {
      final details = e.details;
      final message =
          details is Map && details['error'] is String
              ? details['error'] as String
              : 'Something went wrong. Please try again.';
      if (mounted) {
        setState(() {
          _deleting = false;
          _error = message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _deleting = false;
          _error = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete account?', style: AppTextStyles.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This permanently deletes your account and all your data — '
            'habits, meals, goals, and profile — with no way to recover '
            'it.',
            style: AppTextStyles.bodyMedium,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.terracotta,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.terracotta),
          onPressed: _deleting ? null : _confirmDelete,
          child:
              _deleting
                  ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Delete'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Redeem admin invite code dialog
// ---------------------------------------------------------------------------

class _RedeemInviteDialog extends ConsumerStatefulWidget {
  const _RedeemInviteDialog();

  @override
  ConsumerState<_RedeemInviteDialog> createState() =>
      _RedeemInviteDialogState();
}

class _RedeemInviteDialogState extends ConsumerState<_RedeemInviteDialog> {
  final _codeCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final granted = await ref
          .read(roleProvider.notifier)
          .redeemInviteCode(code);
      if (!mounted) return;
      if (granted) {
        Navigator.pop(context);
      } else {
        setState(() {
          _submitting = false;
          _error = 'Invalid or already-used invite code.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = "Couldn't redeem — try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Redeem invite code', style: AppTextStyles.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _codeCtrl,
            textCapitalization: TextCapitalization.characters,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(labelText: 'Invite code'),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.terracotta,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child:
              _submitting
                  ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Redeem'),
        ),
      ],
    );
  }
}
