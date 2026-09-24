// tracking_screen.dart — Tracking tab for unwanted habits (alcohol,
// nicotine, etc.): a list of user-defined substances with a running
// today/week count against an optional limit, and quick-log chips.
//
// Reached from settings_screen.dart's "Tracking" section (not the bottom
// nav — this is an optional, personal-use feature like Community/Admin).
//
// Shows:
//   • One card per tracked substance: today's total (vs. daily limit if
//     set), this week's total (vs. weekly limit if set), and quick +1 /
//     custom-amount chips to log an occurrence — same interaction shape as
//     nutrition_screen.dart's water quick-add chips
//   • Tap a card to edit name/unit/limits; long-press to delete
//   • FAB to add a new substance
//
// Connections:
//   tracking_notifier.dart — trackingNotifierProvider drives the list;
//                             addSubstance, updateSubstance, deleteSubstance,
//                             logEntry
//   app_theme.dart          — AppGlass, AppColors, AppTextStyles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets.dart';
import '../../database/db.dart';
import 'tracking_notifier.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(trackingNotifierProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Tracking')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showSubstanceFormSheet(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
        body: itemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timeline_outlined,
                      size: 64,
                      color: AppColors.glassBorder,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Nothing tracked yet', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        'Track things you\'re cutting back on — alcohol, '
                        'nicotine, anything with a count. Tap + to add one.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: AppPaddings.all,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _SubstanceCard(item: items[i]),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _SubstanceCard
// ---------------------------------------------------------------------------

class _SubstanceCard extends ConsumerWidget {
  const _SubstanceCard({required this.item});
  final TrackedSubstanceWithStats item;

  String _fmt(double n) => n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final substance = item.substance;
    final notifier = ref.read(trackingNotifierProvider.notifier);
    final dailyLimit = substance.dailyLimit;
    final weeklyLimit = substance.weeklyLimit;
    final dailyProgress =
        dailyLimit != null && dailyLimit > 0
            ? (item.todayTotal / dailyLimit).clamp(0.0, 1.0)
            : null;

    return GestureDetector(
      onTap: () => _showSubstanceFormSheet(context, ref, existing: substance),
      onLongPress: () => _confirmDelete(context, ref, substance),
      child: AppGlass.card(
        padding: AppPaddings.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(substance.name, style: AppTextStyles.titleMedium),
                ),
                Text(
                  '${_fmt(item.todayTotal)} ${substance.unitLabel}${item.todayTotal == 1 ? '' : 's'} today',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        item.isOverDailyLimit
                            ? AppColors.overLimit
                            : AppColors.textOnDarkSecondary,
                    fontWeight:
                        item.isOverDailyLimit ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (dailyProgress != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: dailyProgress,
                  minHeight: 6,
                  color:
                      item.isOverDailyLimit
                          ? AppColors.overLimit
                          : AppColors.eucalyptus,
                  backgroundColor: AppColors.eucalyptus.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'limit ${_fmt(dailyLimit!)}/day',
                style: AppTextStyles.labelSmall,
              ),
            ],
            if (weeklyLimit != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${_fmt(item.weekTotal)} of ${_fmt(weeklyLimit)} this week'
                '${item.isOverWeeklyLimit ? ' — over' : ''}',
                style: AppTextStyles.labelSmall.copyWith(
                  color:
                      item.isOverWeeklyLimit
                          ? AppColors.overLimit
                          : AppColors.textOnDarkSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _LogChip(
                  label: '+1',
                  onTap: () => notifier.logEntry(substance.id),
                ),
                const SizedBox(width: AppSpacing.sm),
                _LogChip(
                  label: 'Custom',
                  onTap: () => _showCustomAmountDialog(context, notifier, substance),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TrackedSubstance substance,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete "${substance.name}"?', style: AppTextStyles.titleMedium),
            content: Text(
              'This removes it and everything logged for it.',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.overLimit),
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(trackingNotifierProvider.notifier).deleteSubstance(substance.id);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showCustomAmountDialog(
    BuildContext context,
    TrackingNotifier notifier,
    TrackedSubstance substance,
  ) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Log ${substance.name}'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(labelText: 'Amount (${substance.unitLabel}s)'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final amount = double.tryParse(ctrl.text);
                  if (amount != null && amount > 0) {
                    notifier.logEntry(substance.id, amount: amount);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Log'),
              ),
            ],
          ),
    );
  }
}

class _LogChip extends StatelessWidget {
  const _LogChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.eucalyptus.withValues(alpha: 0.15),
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: AppColors.eucalyptus.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.eucalyptus,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / edit sheet
// ---------------------------------------------------------------------------

void _showSubstanceFormSheet(
  BuildContext context,
  WidgetRef ref, {
  TrackedSubstance? existing,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _SubstanceFormSheet(existing: existing),
  );
}

class _SubstanceFormSheet extends ConsumerStatefulWidget {
  const _SubstanceFormSheet({this.existing});
  final TrackedSubstance? existing;

  @override
  ConsumerState<_SubstanceFormSheet> createState() => _SubstanceFormSheetState();
}

class _SubstanceFormSheetState extends ConsumerState<_SubstanceFormSheet> {
  late final _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
  late final _unitCtrl =
      TextEditingController(text: widget.existing?.unitLabel ?? 'drink');
  late final _dailyLimitCtrl = TextEditingController(
    text: widget.existing?.dailyLimit?.toString() ?? '',
  );
  late final _weeklyLimitCtrl = TextEditingController(
    text: widget.existing?.weeklyLimit?.toString() ?? '',
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _dailyLimitCtrl.dispose();
    _weeklyLimitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: AppDragHandle()),
          const SizedBox(height: AppSpacing.md),
          Text(
            isEditing ? 'Edit Tracker' : 'New Tracker',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameCtrl,
            autofocus: !isEditing,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Alcohol, Cigarettes',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _unitCtrl,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Unit',
              hintText: 'e.g. drink, cigarette',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dailyLimitCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Daily limit (optional)'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _weeklyLimitCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(labelText: 'Weekly limit (optional)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final name = _nameCtrl.text.trim();
                if (name.isEmpty) return;
                final unit = _unitCtrl.text.trim().isEmpty
                    ? 'drink'
                    : _unitCtrl.text.trim();
                final dailyLimit = double.tryParse(_dailyLimitCtrl.text.trim());
                final weeklyLimit = double.tryParse(_weeklyLimitCtrl.text.trim());
                final notifier = ref.read(trackingNotifierProvider.notifier);
                if (isEditing) {
                  notifier.updateSubstance(
                    id: widget.existing!.id,
                    name: name,
                    unitLabel: unit,
                    dailyLimit: dailyLimit,
                    weeklyLimit: weeklyLimit,
                  );
                } else {
                  notifier.addSubstance(
                    name: name,
                    unitLabel: unit,
                    dailyLimit: dailyLimit,
                    weeklyLimit: weeklyLimit,
                  );
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ),
        ],
      ),
    );
  }
}
