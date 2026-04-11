import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/day_schedule_entity.dart';
import '../providers/store_hours_provider.dart';
import '../widgets/copy_hours_sheet.dart';
import '../widgets/day_schedule_tile.dart';
import '../widgets/store_status_banner.dart';
import '../../../../shared/widgets/skeletons/store_hours_skeleton.dart';

class StoreHoursScreen extends ConsumerStatefulWidget {
  const StoreHoursScreen({super.key});

  @override
  ConsumerState<StoreHoursScreen> createState() => _StoreHoursScreenState();
}

class _StoreHoursScreenState extends ConsumerState<StoreHoursScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storeHoursNotifierProvider.notifier).fetchStoreHours();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storeHoursNotifierProvider);
    final notifier = ref.read(storeHoursNotifierProvider.notifier);
    final current = state.current;
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(title: Text(context.l10n.storeHoursTitle)),
      body: current == null || state.isLoading
          ? const StoreHoursSkeleton()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      StoreStatusBanner(
                        isOpen: state.isStoreOpen,
                        message: current.temporaryMessage,
                        onToggle: () async {
                          await notifier.toggleStoreStatus();
                          if (!context.mounted) return;
                          final open = ref.read(storeHoursNotifierProvider).isStoreOpen;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(open ? context.l10n.storeNowOpen : context.l10n.storeNowClosed)),
                          );
                        },
                        onEditMessage: () => _showMessageSheet(context, notifier, current.temporaryMessage),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(child: Text(context.l10n.weeklySchedule, style: Theme.of(context).textTheme.titleMedium)),
                          TextButton(
                            onPressed: () => showCopyHoursSheet(
                              context: context,
                              schedule: current.schedule,
                              onApply: notifier.copyHoursTodays,
                            ),
                            child: Text(context.l10n.copyHoursToAll),
                          ),
                        ],
                      ),
                      Text(context.l10n.weeklyScheduleSubtitle),
                      const SizedBox(height: AppSpacing.md),
                      Text(context.l10n.quickPresets, style: Theme.of(context).textTheme.titleMedium),
                      Text(context.l10n.quickPresetsSubtitle),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: StorePreset.values.map((preset) {
                            return Padding(
                              padding: const EdgeInsets.only(right: AppSpacing.sm),
                              child: ActionChip(
                                label: Text(_presetLabel(context, preset)),
                                onPressed: () {
                                  final text = context.l10n.applyPresetConfirm(_presetLabel(context, preset));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(text),
                                      action: SnackBarAction(
                                        label: context.l10n.applyFilters,
                                        onPressed: () => notifier.applyPreset(preset),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...egyptWeekOrder.map((day) {
                        final schedule = current.schedule.firstWhere((e) => e.day == day);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: DayScheduleTile(
                            schedule: schedule,
                            onToggleDay: () => notifier.toggleDay(day),
                            onToggle24Hours: () => notifier.toggle24Hours(day),
                            onPickOpenTime: (t) => notifier.updateOpenTime(day, t),
                            onPickCloseTime: (t) => notifier.updateCloseTime(day, t),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.hasChanges
                          ? () async {
                              final savedText = context.l10n.workingHoursSaved;
                              final invalidText = context.l10n.invalidHoursError;
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              final ok = await notifier.saveStoreHours();
                              if (!mounted) return;
                              if (ok) {
                                messenger.showSnackBar(SnackBar(content: Text(savedText)));
                                navigator.pop();
                              } else {
                                messenger.showSnackBar(SnackBar(content: Text(invalidText)));
                              }
                            }
                          : null,
                      child: state.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.l10n.saveWorkingHours),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

String _presetLabel(BuildContext context, StorePreset preset) {
  return switch (preset) {
    StorePreset.standard => context.l10n.presetStandard,
    StorePreset.extended => context.l10n.presetExtended,
    StorePreset.morningOnly => context.l10n.presetMorning,
    StorePreset.fullWeek => context.l10n.presetFullWeek,
    StorePreset.weekdaysOnly => context.l10n.presetWeekdays,
    StorePreset.withoutFriday => context.l10n.presetWithoutFriday,
  };
}

Future<void> _showMessageSheet(
  BuildContext context,
  StoreHoursNotifier notifier,
  String? initial,
) async {
  final controller = TextEditingController(text: initial ?? '');
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.closedMessageTitle),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            maxLength: 60,
            decoration: InputDecoration(hintText: context.l10n.closedMessageHint),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    notifier.updateTemporaryMessage('');
                    Navigator.pop(context);
                  },
                  child: Text(context.l10n.clearAllFilters),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    notifier.updateTemporaryMessage(controller.text);
                    Navigator.pop(context);
                  },
                  child: Text(context.l10n.save),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

