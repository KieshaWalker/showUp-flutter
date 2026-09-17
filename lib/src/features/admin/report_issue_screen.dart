// report_issue_screen.dart — "Report an Issue": a form to submit a
// functionality issue, plus a list of the user's own past reports and
// their status.
//
// Reached from settings_screen.dart's "Report an Issue" row — available to
// every user (including admins, who might spot something themselves).
// Reports submitted here are visible to admins via admin_screen.dart.
//
// On a successful submit, pops back to Settings with `true` so Settings can
// show the "Submitted successfully" confirmation banner.
//
// Connections:
//   issue_reports_notifier.dart — myReportsProvider (list + submitReport())
//   issue_report.dart           — IssueStatus for the status chip

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import 'issue_report.dart';
import 'issue_reports_notifier.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    if (title.isEmpty || description.isEmpty) {
      setState(() => _error = 'Please fill in both fields.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref
          .read(myReportsProvider.notifier)
          .submitReport(title: title, description: description);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = "Couldn't submit — try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myReports = ref.watch(myReportsProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Report an Issue')),
        body: ListView(
          padding: AppPaddings.all,
          children: [
            Text(
              'Ran into a bug or something that doesn\'t work right? '
              'Describe it below — administrators can see and work on '
              'every report submitted here.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppGlass.card(
              padding: AppPaddings.card,
              borderRadius: AppRadius.lgAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    style: AppTextStyles.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Summary',
                      hintText: 'e.g. Water total resets after logging a meal',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _descriptionCtrl,
                    style: AppTextStyles.bodyLarge,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'What happened?',
                      hintText:
                          'Steps to reproduce, what you expected, what '
                          'happened instead…',
                      alignLabelWithHint: true,
                    ),
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
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit Report'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Your Reports', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            myReports.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Text(
                "Couldn't load your reports.",
                style: AppTextStyles.bodyMedium,
              ),
              data: (reports) {
                if (reports.isEmpty) {
                  return Text(
                    'Reports you submit will show up here.',
                    style: AppTextStyles.bodyMedium,
                  );
                }
                return Column(
                  children: [
                    for (final r in reports) ...[
                      _MyReportRow(report: r),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MyReportRow extends StatelessWidget {
  final IssueReport report;
  const _MyReportRow({required this.report});

  @override
  Widget build(BuildContext context) {
    return AppGlass.card(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppRadius.mdAll,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: AppTextStyles.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDate(report.createdAt),
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StatusChip(report.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IssueStatus status;
  const _StatusChip(this.status);

  Color get _color => switch (status) {
    IssueStatus.open => AppColors.ochre,
    IssueStatus.inProgress => AppColors.waterColor,
    IssueStatus.resolved => AppColors.eucalyptus,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall.copyWith(color: _color),
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
