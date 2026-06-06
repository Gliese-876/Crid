import 'package:crid/app/app_state.dart';
import 'package:crid/features/import/domain/parsed_timetable.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConflictDiffPage extends ConsumerWidget {
  const ConflictDiffPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflicts = ref.watch(pendingConflictsProvider);
    return conflicts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text(context.l10n.failedToLoadConflicts(error))),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(context.l10n.noPendingConflicts),
            ),
          );
        }
        final changed = items.where((item) => !item.isTimeConflict).length;
        final overlaps = items.length - changed;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: items.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ConflictSummary(
                changed: changed,
                conflicts: overlaps,
                total: items.length,
              );
            }
            return _ConflictCard(entry: items[index - 1]);
          },
        );
      },
    );
  }
}

class _ConflictSummary extends StatelessWidget {
  const _ConflictSummary({
    required this.changed,
    required this.conflicts,
    required this.total,
  });

  final int changed;
  final int conflicts;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.conflictHandling,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.conflictHandlingSubtitle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(
                  label: context.l10n.changedFieldsCount(changed),
                  backgroundColor: colorScheme.tertiaryContainer,
                  foregroundColor: colorScheme.onTertiaryContainer,
                ),
                _SummaryChip(
                  label: context.l10n.timeConflictsCount(conflicts),
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                ),
                _SummaryChip(
                  label: context.l10n.pendingCount(total),
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.entry});

  final ConflictEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final conflictColor = entry.isTimeConflict
        ? colorScheme.errorContainer
        : colorScheme.secondaryContainer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  entry.isTimeConflict ? Icons.warning_amber : Icons.difference,
                  color: entry.isTimeConflict
                      ? colorScheme.error
                      : colorScheme.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.incoming.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  backgroundColor: conflictColor,
                  label: Text(
                    entry.isTimeConflict
                        ? context.l10n.conflict
                        : context.l10n.changed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _entryField(context, entry),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final panels = [
                  _DiffValue(
                    title: context.l10n.currentValue,
                    value: _courseSummary(context, entry.current),
                  ),
                  _DiffValue(
                    title: context.l10n.importedValue,
                    value: _courseSummary(context, entry.incoming),
                  ),
                ];
                return isWide
                    ? Row(
                        children: [
                          Expanded(child: panels[0]),
                          const SizedBox(width: 12),
                          Expanded(child: panels[1]),
                        ],
                      )
                    : Column(
                        children: [
                          panels[0],
                          const SizedBox(height: 12),
                          panels[1],
                        ],
                      );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurface,
                  ),
                  onPressed: () => _resolve(
                    context,
                    ref,
                    ConflictResolutionAction.keepCurrent,
                  ),
                  child: Text(context.l10n.keepCurrent),
                ),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiaryContainer,
                    foregroundColor: colorScheme.onTertiaryContainer,
                  ),
                  onPressed: () => _resolve(
                    context,
                    ref,
                    ConflictResolutionAction.useImported,
                  ),
                  child: Text(context.l10n.useImported),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: entry.isTimeConflict
                        ? colorScheme.error
                        : colorScheme.primary,
                    side: BorderSide(
                      color:
                          (entry.isTimeConflict
                                  ? colorScheme.error
                                  : colorScheme.primary)
                              .withValues(alpha: .36),
                    ),
                  ),
                  onPressed: () =>
                      _resolve(context, ref, ConflictResolutionAction.keepBoth),
                  child: Text(
                    entry.isTimeConflict
                        ? context.l10n.forceMerge
                        : context.l10n.keepBoth,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _resolve(
                    context,
                    ref,
                    ConflictResolutionAction.manualEdit,
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(context.l10n.manualEdit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    ConflictResolutionAction action,
  ) async {
    await ref
        .read(timetableControllerProvider.notifier)
        .resolveConflict(entry.id, action);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.conflictMarked(_actionLabel(context, entry, action)),
        ),
      ),
    );
  }
}

class _DiffValue extends StatelessWidget {
  const _DiffValue({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(value),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: backgroundColor,
      side: BorderSide(color: foregroundColor.withValues(alpha: .16)),
      labelStyle: TextStyle(color: foregroundColor),
      label: Text(label),
    );
  }
}

String _entryField(BuildContext context, ConflictEntry entry) {
  if (entry.isTimeConflict) {
    return context.l10n.timeOverlap;
  }
  return context.l10n.changedFields(entry.type.replaceFirst('diff:', ''));
}

String _courseSummary(BuildContext context, ParsedCourse course) {
  final weeks = course.weeks.weeks.isEmpty
      ? context.l10n.weekUnknown
      : context.l10n.weeksValue(
          course.weeks.weeks.first,
          course.weeks.weeks.last,
        );
  final teacher = course.teacher.isEmpty
      ? context.l10n.teacherTbd
      : course.teacher;
  final location = course.location.isEmpty
      ? context.l10n.locationTbd
      : course.location;
  return context.l10n.courseSummary(
    course.weekday,
    _courseTimeLabel(course),
    weeks,
    teacher,
    location,
  );
}

String _courseTimeLabel(ParsedCourse course) {
  return '${_minuteLabel(course.timeRange.startMinuteOfDay)}-'
      '${_minuteLabel(course.timeRange.endMinuteOfDay)}';
}

String _minuteLabel(int minuteOfDay) {
  final hour = minuteOfDay ~/ 60;
  final minute = minuteOfDay % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}

String _actionLabel(
  BuildContext context,
  ConflictEntry entry,
  ConflictResolutionAction action,
) {
  return switch (action) {
    ConflictResolutionAction.keepCurrent => context.l10n.keepCurrent,
    ConflictResolutionAction.useImported => context.l10n.useImported,
    ConflictResolutionAction.keepBoth =>
      entry.isTimeConflict ? context.l10n.forceMerge : context.l10n.keepBoth,
    ConflictResolutionAction.manualEdit => context.l10n.manualEdit,
  };
}
