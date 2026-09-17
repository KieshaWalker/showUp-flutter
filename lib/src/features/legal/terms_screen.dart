// terms_screen.dart — Full-text Terms & Agreement.
//
// Pushed from two places:
//   • auth_screen.dart     — tapping "Terms & Agreement" in the sign-up
//                            checkbox row, before an account exists.
//                            allowAccept is left false there — viewing is
//                            informational, the checkbox itself is what
//                            records acceptance on submit.
//   • settings_screen.dart — Settings > Terms & Agreement, with
//                            allowAccept: true and the profile's stored
//                            acceptedAt. Shows "you accepted on <date>" if
//                            set, or an "Accept" button if not (covers
//                            accounts created before this flow existed).
//
// Connections:
//   terms_content.dart    — kTermsSections / kTermsVersion / kTermsEffectiveDate
//   profile_notifier.dart — acceptTerms() records acceptance to Supabase
//   app_theme.dart        — AppBackground, AppGlass, AppColors, AppTextStyles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../profile/profile_notifier.dart';
import 'terms_content.dart';

class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key, this.acceptedAt, this.allowAccept = false});

  /// When shown from Settings for a user who already accepted, the date
  /// they accepted — displayed under the effective-date line. Null when
  /// shown pre-signup, or for an account that predates this flow.
  final DateTime? acceptedAt;

  /// Whether to offer an "Accept" button when [acceptedAt] is null. Only
  /// true from Settings, where the user is already logged in and there's
  /// a profile row to record acceptance against.
  final bool allowAccept;

  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen> {
  bool _accepting = false;

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      await ref.read(profileProvider.notifier).acceptTerms();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _accepting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save — try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsAccept = widget.allowAccept && widget.acceptedAt == null;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Terms & Agreement')),
        body: ListView(
          padding: AppPaddings.all,
          children: [
            Text(
              'Effective $kTermsEffectiveDate · v$kTermsVersion',
              style: AppTextStyles.labelSmall,
            ),
            if (widget.acceptedAt != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'You accepted these terms on ${_formatDate(widget.acceptedAt!)}.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.eucalyptus,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            for (final section in kTermsSections) ...[
              Text(section.title, style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(section.body, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (needsAccept) ...[
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: _accepting ? null : _accept,
                child: _accepting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Accept Terms & Agreement'),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}
