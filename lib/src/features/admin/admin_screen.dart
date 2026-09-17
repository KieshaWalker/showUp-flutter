// admin_screen.dart — Admin dashboard: invite codes + the issue queue.
//
// Reached from settings_screen.dart's "Admin" section, shown only when
// roleProvider is true. Two jobs:
//   • Invite Codes — generate a new one-time admin invite code to hand out,
//     and see which past codes have been redeemed.
//   • Issue Reports — every report submitted app-wide (report_issue_screen.dart),
//     filterable by status, with actions to move a report through
//     open → in_progress → resolved (or reopen a resolved one).
//
// Connections:
//   role_provider.dart           — inviteCodesProvider (generate + list)
//   issue_reports_notifier.dart  — adminReportsProvider (list + updateReport())
//   issue_report.dart            — IssueReport, IssueStatus

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets.dart' show AppDragHandle;
import 'issue_report.dart';
import 'issue_reports_notifier.dart';
import 'role_provider.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  IssueStatus? _filter = IssueStatus.open;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Admin')),
        body: ListView(
          padding: AppPaddings.all,
          children: [
            Text('Invite Codes', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            const _InviteCodesSection(),
            const SizedBox(height: AppSpacing.xl),

            Text('Issue Reports', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            _StatusFilterRow(
              selected: _filter,
              onSelected: (s) => setState(() => _filter = s),
            ),
            const SizedBox(height: AppSpacing.sm),
            reportsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Text(
                "Couldn't load reports.",
                style: AppTextStyles.bodyMedium,
              ),
              data: (reports) {
                final filtered = _filter == null
                    ? reports
                    : reports.where((r) => r.status == _filter).toList();
                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Text(
                      'Nothing here.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final r in filtered) ...[
                      _ReportRow(report: r),
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

// ---------------------------------------------------------------------------
// Invite codes
// ---------------------------------------------------------------------------

class _InviteCodesSection extends ConsumerWidget {
  const _InviteCodesSection();

  Future<void> _generate(BuildContext context, WidgetRef ref) async {
    final code = await ref.read(inviteCodesProvider.notifier).generate();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New invite code', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share this with the person you want to make an admin. It '
              'works once, at sign-up or from their Settings.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            SelectableText(
              code,
              style: AppTextStyles.titleLarge.copyWith(
                letterSpacing: 2,
                color: AppColors.terracotta,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(ctx);
            },
            child: const Text('Copy & Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codesAsync = ref.watch(inviteCodesProvider);

    return AppGlass.card(
      padding: AppPaddings.card,
      borderRadius: AppRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _generate(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Generate Invite Code'),
          ),
          const SizedBox(height: AppSpacing.md),
          codesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(
              "Couldn't load invite codes.",
              style: AppTextStyles.bodyMedium,
            ),
            data: (codes) {
              if (codes.isEmpty) {
                return Text(
                  'No codes generated yet.',
                  style: AppTextStyles.bodyMedium,
                );
              }
              return Column(
                children: [
                  for (final c in codes)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.code,
                              style: AppTextStyles.bodyLarge.copyWith(
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Text(
                            c.isUsed ? 'Used' : 'Unused',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: c.isUsed
                                  ? AppColors.textOnDarkTertiary
                                  : AppColors.eucalyptus,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status filter chips
// ---------------------------------------------------------------------------

class _StatusFilterRow extends StatelessWidget {
  final IssueStatus? selected;
  final ValueChanged<IssueStatus?> onSelected;

  const _StatusFilterRow({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(label: 'All', selected: selected == null, onTap: () => onSelected(null)),
          const SizedBox(width: AppSpacing.sm),
          for (final s in IssueStatus.values) ...[
            _FilterChip(
              label: s.label,
              selected: selected == s,
              onTap: () => onSelected(s),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.terracotta : AppColors.glassBg,
          borderRadius: AppRadius.fullAll,
          border: Border.all(
            color: selected ? AppColors.terracotta : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? Colors.white : AppColors.textOnDark,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// A single report row → tap to open the management sheet
// ---------------------------------------------------------------------------

class _ReportRow extends StatelessWidget {
  final IssueReport report;
  const _ReportRow({required this.report});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ReportDetailSheet(report: report),
      ),
      child: AppGlass.card(
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
                    '${report.reporterName ?? 'Unknown user'} · ${_formatDate(report.createdAt)}',
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.khaki),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Report detail sheet — full description, notes, status actions
// ---------------------------------------------------------------------------

class _ReportDetailSheet extends ConsumerStatefulWidget {
  final IssueReport report;
  const _ReportDetailSheet({required this.report});

  @override
  ConsumerState<_ReportDetailSheet> createState() =>
      _ReportDetailSheetState();
}

class _ReportDetailSheetState extends ConsumerState<_ReportDetailSheet> {
  late final _notesCtrl = TextEditingController(text: widget.report.adminNotes);
  bool _saving = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _setStatus(IssueStatus status) async {
    setState(() => _saving = true);
    await ref.read(adminReportsProvider.notifier).updateReport(
          widget.report.id,
          status: status,
          adminNotes: _notesCtrl.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg - 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppDragHandle(),
            Text(report.title, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${report.reporterName ?? 'Unknown user'} · ${_formatDate(report.createdAt)}',
              style: AppTextStyles.labelSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(report.description, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _notesCtrl,
              style: AppTextStyles.bodyLarge,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Admin notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_saving)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (report.status != IssueStatus.inProgress)
                    OutlinedButton(
                      onPressed: () => _setStatus(IssueStatus.inProgress),
                      child: const Text('Start Working'),
                    ),
                  if (report.status != IssueStatus.resolved)
                    FilledButton(
                      onPressed: () => _setStatus(IssueStatus.resolved),
                      child: const Text('Mark Resolved'),
                    ),
                  if (report.status != IssueStatus.open)
                    TextButton(
                      onPressed: () => _setStatus(IssueStatus.open),
                      child: const Text('Reopen'),
                    ),
                ],
              ),
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
