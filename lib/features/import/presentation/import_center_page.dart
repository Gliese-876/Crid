import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../l10n/l10n.dart';
import '../domain/parsed_timetable.dart';
import 'import_preview_controller.dart';

class ImportCenterPage extends ConsumerWidget {
  const ImportCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(importPreviewControllerProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _ImportSourceCard(preview: preview),
        const SizedBox(height: 16),
        _PreviewCard(preview: preview),
        const SizedBox(height: 16),
        const _ImportHistoryCard(),
      ],
    );
  }
}

class _ImportSourceCard extends ConsumerWidget {
  const _ImportSourceCard({required this.preview});

  final AsyncValue<ImportPreviewState> preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(importPreviewControllerProvider.notifier);
    final snapshot = ref.watch(timetableControllerProvider).asData?.value;
    final firstWeekMonday = snapshot?.activeSemester.firstWeekMonday;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.importCenter,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.importCenterSubtitle),
            if (firstWeekMonday != null) ...[
              const SizedBox(height: 8),
              InputChip(
                backgroundColor: colorScheme.tertiaryContainer,
                side: BorderSide(
                  color: colorScheme.tertiary.withValues(alpha: .20),
                ),
                labelStyle: TextStyle(color: colorScheme.onTertiaryContainer),
                label: _CenteredIconLabel(
                  icon: Icons.event_outlined,
                  label: context.l10n.firstMonday(
                    firstWeekMonday.toIso8601String().split('T').first,
                  ),
                  color: colorScheme.onTertiaryContainer,
                ),
                onPressed: () =>
                    _pickFirstWeekMonday(context, ref, firstWeekMonday),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: preview.isLoading ? null : controller.chooseFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(context.l10n.chooseFile),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    Uri(
                      path: '/import/conflicts',
                      queryParameters: {
                        'from': GoRouterState.of(context).uri.toString(),
                      },
                    ).toString(),
                  ),
                  icon: const Icon(Icons.rule_folder_outlined),
                  label: Text(context.l10n.openDiff),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFirstWeekMonday(
    BuildContext context,
    WidgetRef ref,
    DateTime initialDate,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      selectableDayPredicate: (date) => date.weekday == DateTime.monday,
    );
    if (date == null) {
      return;
    }
    await ref
        .read(timetableControllerProvider.notifier)
        .updateActiveSemesterFirstWeekMonday(date);
  }
}

class _PreviewCard extends ConsumerWidget {
  const _PreviewCard({required this.preview});

  final AsyncValue<ImportPreviewState> preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = preview.asData?.value ?? const ImportPreviewState();
    final parsed = state.parsed;
    final courses = parsed?.courses ?? const [];
    final warnings = parsed?.warnings ?? const [];
    final merge = state.mergeResult;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    parsed == null
                        ? context.l10n.stagingPreview
                        : parsed.sourceName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(
                  label: state.committed
                      ? context.l10n.merged
                      : parsed == null
                      ? context.l10n.waiting
                      : context.l10n.notCommitted,
                  backgroundColor: state.committed
                      ? colorScheme.primaryContainer
                      : parsed == null
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.tertiaryContainer,
                  foregroundColor: state.committed
                      ? colorScheme.onPrimaryContainer
                      : parsed == null
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onTertiaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (preview.isLoading)
              const LinearProgressIndicator()
            else if (preview.hasError)
              _ErrorText(error: preview.error!)
            else
              _PreviewStats(
                parsedCount: courses.length,
                addedCount: merge?.added.length ?? 0,
                changedCount: merge?.diffs.length ?? 0,
                conflictCount: merge?.conflicts.length ?? 0,
              ),
            const SizedBox(height: 12),
            if (courses.isEmpty)
              const _EmptyPreview()
            else
              _CoursePreviewTable(courses: courses.take(24).toList()),
            const SizedBox(height: 12),
            for (final warning in warnings.take(5))
              _WarningLine(text: _parseWarningText(context, warning)),
            if (state.commitSummary != null)
              _WarningLine(
                text: context.l10n.committedSummary(
                  state.commitSummary!.added,
                  state.commitSummary!.diffs,
                  state.commitSummary!.conflicts,
                ),
              ),
            if (parsed != null)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: state.committed
                      ? null
                      : () => ref
                            .read(importPreviewControllerProvider.notifier)
                            .markCommitted(),
                  icon: const Icon(Icons.merge_type_outlined),
                  label: Text(context.l10n.applyStagingMerge),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewStats extends StatelessWidget {
  const _PreviewStats({
    required this.parsedCount,
    required this.addedCount,
    required this.changedCount,
    required this.conflictCount,
  });

  final int parsedCount;
  final int addedCount;
  final int changedCount;
  final int conflictCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(
          label: context.l10n.parsedCount(parsedCount),
          icon: Icons.table_rows_outlined,
        ),
        _StatChip(
          label: context.l10n.newCount(addedCount),
          icon: Icons.add_circle_outline,
        ),
        _StatChip(
          label: context.l10n.changeCount(changedCount),
          icon: Icons.difference_outlined,
        ),
        _StatChip(
          label: context.l10n.conflictCount(conflictCount),
          icon: Icons.warning_amber_outlined,
        ),
      ],
    );
  }
}

class _CoursePreviewTable extends StatelessWidget {
  const _CoursePreviewTable({required this.courses});

  final List<ParsedCourse> courses;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(context.l10n.course)),
          DataColumn(label: Text(context.l10n.teacher)),
          DataColumn(label: Text(context.l10n.time)),
          DataColumn(label: Text(context.l10n.location)),
          DataColumn(label: Text(context.l10n.weeks)),
        ],
        rows: [
          for (final course in courses)
            DataRow(
              cells: [
                DataCell(Text(course.name)),
                DataCell(Text(course.teacher.isEmpty ? '-' : course.teacher)),
                DataCell(
                  Text(
                    '${context.l10n.dayNumber(course.weekday)} '
                    '${course.period.normalizedKey}',
                  ),
                ),
                DataCell(Text(course.location.isEmpty ? '-' : course.location)),
                DataCell(Text(course.weeks.normalizedKey)),
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: _EmptyPreviewText(),
    );
  }
}

class _EmptyPreviewText extends StatelessWidget {
  const _EmptyPreviewText();

  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.emptyPreview);
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.importFailed(error),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    );
  }
}

String _parseWarningText(BuildContext context, ParseWarning warning) {
  final l10n = context.l10n;
  return switch (warning.code) {
    ParseWarningCode.unsupportedFileType =>
      l10n.importWarningUnsupportedFileType,
    ParseWarningCode.workbookReadFailed => l10n.importWarningWorkbookReadFailed,
    ParseWarningCode.noCompleteXlsRows => l10n.importWarningNoCompleteXlsRows,
    ParseWarningCode.xlsParsedSessions => l10n.importWarningXlsParsedSessions(
      warning.count ?? 0,
    ),
    ParseWarningCode.noCoursesFromHtml => l10n.importWarningNoCoursesFromHtml,
    ParseWarningCode.decodedWithFallback =>
      l10n.importWarningDecodedWithFallback,
    ParseWarningCode.fragmentMissingName =>
      l10n.importWarningFragmentMissingName,
    ParseWarningCode.missingWeekday => l10n.importWarningMissingWeekday,
    ParseWarningCode.missingPeriod => l10n.importWarningMissingPeriod,
    ParseWarningCode.missingWeeks => l10n.importWarningMissingWeeks,
    ParseWarningCode.noCompleteEntries => l10n.importWarningNoCompleteEntries,
    ParseWarningCode.icsParseFailed => l10n.importWarningIcsParseFailed,
    ParseWarningCode.skippedIcsEvent => l10n.importWarningSkippedIcsEvent,
    ParseWarningCode.icsRuleFallback => l10n.importWarningIcsRuleFallback,
    ParseWarningCode.generic => switch (warning.severity) {
      ParseWarningSeverity.error => l10n.importWarningGenericError,
      ParseWarningSeverity.info => l10n.importWarningGenericInfo,
      ParseWarningSeverity.warning => l10n.importWarningGenericWarning,
    },
  };
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = switch (icon) {
      Icons.add_circle_outline => colorScheme.primaryContainer,
      Icons.difference_outlined => colorScheme.tertiaryContainer,
      Icons.warning_amber_outlined => colorScheme.errorContainer,
      _ => colorScheme.surfaceContainerHighest,
    };
    final foregroundColor = switch (icon) {
      Icons.add_circle_outline => colorScheme.onPrimaryContainer,
      Icons.difference_outlined => colorScheme.onTertiaryContainer,
      Icons.warning_amber_outlined => colorScheme.onErrorContainer,
      _ => colorScheme.onSurfaceVariant,
    };
    return _StatusChip(
      label: label,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: backgroundColor,
      side: BorderSide(color: foregroundColor.withValues(alpha: .16)),
      labelStyle: TextStyle(color: foregroundColor),
      label: icon == null
          ? Text(label)
          : _CenteredIconLabel(
              icon: icon!,
              label: label,
              color: foregroundColor,
            ),
    );
  }
}

class _CenteredIconLabel extends StatelessWidget {
  const _CenteredIconLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class _WarningLine extends StatelessWidget {
  const _WarningLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ImportHistoryCard extends ConsumerWidget {
  const _ImportHistoryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(importHistoryProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: history.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Text(context.l10n.failedToLoadHistory(error)),
          data: (items) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.recentBatches),
              const SizedBox(height: 8),
              if (items.isEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history_outlined),
                  title: Text(context.l10n.noImportBatchesYet),
                  subtitle: Text(context.l10n.committedImportsAppearHere),
                )
              else
                for (final item in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      item.fileType == 'ics'
                          ? Icons.event_note_outlined
                          : Icons.description_outlined,
                    ),
                    title: Text(item.sourceName),
                    subtitle: Text(
                      context.l10n.batchSubtitle(
                        item.fileType,
                        item.summary,
                        item.importedAt
                            .toLocal()
                            .toIso8601String()
                            .split('T')
                            .first,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
