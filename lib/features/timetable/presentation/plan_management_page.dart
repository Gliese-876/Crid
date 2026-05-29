import 'package:crid/app/app_state.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _pendingDeletionKeys = <String>{};

class PlanManagementPage extends ConsumerWidget {
  const PlanManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(timetableControllerProvider);
    return snapshot.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text(context.l10n.failedToLoadPlans(error))),
      data: (data) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final semesterPanel = _SemesterPanel(snapshot: data);
            final planColumn = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PlanPanel(snapshot: data),
                const SizedBox(height: 16),
                _HiddenCoursePanel(snapshot: data),
              ],
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: semesterPanel),
                        const SizedBox(width: 16),
                        Expanded(child: planColumn),
                      ],
                    )
                  : Column(
                      children: [
                        semesterPanel,
                        const SizedBox(height: 16),
                        planColumn,
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

class _SemesterPanel extends ConsumerWidget {
  const _SemesterPanel({required this.snapshot});

  final TimetableSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              icon: Icons.school_outlined,
              title: context.l10n.semesters,
              actionLabel: context.l10n.add,
              onPressed: () =>
                  _showSemesterDialog(context, ref, snapshot: snapshot),
            ),
            const SizedBox(height: 12),
            for (final semester in snapshot.semesters)
              _SemesterTile(
                semester: semester,
                active: semester.id == snapshot.activeSemester.id,
                onTap: semester.id == snapshot.activeSemester.id
                    ? null
                    : () => ref
                          .read(timetableControllerProvider.notifier)
                          .setActiveSemester(semester.id),
                onEdit: () => _showSemesterDialog(
                  context,
                  ref,
                  snapshot: snapshot,
                  semester: semester,
                ),
                onDelete: () => _confirmDeleteSemester(
                  context,
                  ref,
                  semester: semester,
                  semesterCount: snapshot.semesters.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlanPanel extends ConsumerWidget {
  const _PlanPanel({required this.snapshot});

  final TimetableSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = snapshot.plans
        .where((plan) => plan.semesterId == snapshot.activeSemester.id)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              icon: Icons.view_week_outlined,
              title: context.l10n.timetablePlans,
            ),
            const SizedBox(height: 12),
            for (final plan in plans)
              _PlanTile(
                plan: plan,
                onTap: plan.isActive
                    ? null
                    : () => ref
                          .read(timetableControllerProvider.notifier)
                          .setActivePlan(plan.id),
                onEdit: () => _showPlanDialog(
                  context,
                  ref,
                  semesterId: snapshot.activeSemester.id,
                  plan: plan,
                  initialName: plan.name,
                ),
                onDelete: () => _confirmDeletePlan(
                  context,
                  ref,
                  plan: plan,
                  planCount: plans.length,
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _showPlanDialog(
                  context,
                  ref,
                  semesterId: snapshot.activeSemester.id,
                  initialName: context.l10n.planName(plans.length + 1),
                ),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.newPlan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HiddenCoursePanel extends ConsumerWidget {
  const _HiddenCoursePanel({required this.snapshot});

  final TimetableSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiddenCourses = snapshot.hiddenCourses;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              icon: Icons.visibility_outlined,
              title: context.l10n.hiddenCourses,
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.hiddenCoursesSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (hiddenCourses.isEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.visibility_off_outlined),
                title: Text(context.l10n.noHiddenCourses),
              )
            else
              for (final course in hiddenCourses)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(course.name),
                  subtitle: Text(
                    course.teacher.isEmpty
                        ? context.l10n.sessionCount(course.sessionCount)
                        : '${course.teacher} · '
                              '${context.l10n.sessionCount(course.sessionCount)}',
                  ),
                  trailing: TextButton.icon(
                    onPressed: () async {
                      await ref
                          .read(timetableControllerProvider.notifier)
                          .restoreHiddenCourse(course.id);
                      if (context.mounted) {
                        _showSnackBar(context, context.l10n.courseRestored);
                      }
                    },
                    icon: const Icon(Icons.restore_outlined),
                    label: Text(context.l10n.restore),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (actionLabel != null)
          OutlinedButton(onPressed: onPressed, child: Text(actionLabel!)),
      ],
    );
  }
}

class _SemesterTile extends StatelessWidget {
  const _SemesterTile({
    required this.semester,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.active = false,
  });

  final SemesterSummary semester;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final subtitles = [
      context.l10n.firstMonday(_formatDate(semester.firstWeekMonday)),
      if (semester.endDate != null)
        context.l10n.semesterEndDate(_formatDate(semester.endDate!)),
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(active ? Icons.check_circle : Icons.calendar_month),
      title: Text(semester.name),
      subtitle: Text(subtitles.join('\n')),
      isThreeLine: semester.endDate != null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active) _PlanBadge(label: context.l10n.current, active: true),
          _TileMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final PlanSummary plan;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = plan.isActive
        ? context.l10n.activeForRemindersAndExport
        : context.l10n.tapToMakeActive;
    final badge = plan.isActive ? context.l10n.active : context.l10n.selectPlan;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(plan.name),
            subtitle: Text(subtitle),
            onTap: onTap,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PlanBadge(label: badge, active: plan.isActive),
                _TileMenu(onEdit: onEdit, onDelete: onDelete),
              ],
            ),
          ),
          LinearProgressIndicator(value: plan.isActive ? 1 : .55),
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = active
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = active
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    return Chip(
      backgroundColor: backgroundColor,
      side: BorderSide(color: foregroundColor.withValues(alpha: .16)),
      labelStyle: TextStyle(color: foregroundColor),
      label: Text(label),
    );
  }
}

enum _TileAction { edit, delete }

class _TileMenu extends StatelessWidget {
  const _TileMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_TileAction>(
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      shape: appMenuPanelShape,
      clipBehavior: Clip.antiAlias,
      popUpAnimationStyle: appMenuAnimationStyle,
      onSelected: (action) {
        switch (action) {
          case _TileAction.edit:
            onEdit();
          case _TileAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _TileAction.edit,
          child: _MenuItem(icon: Icons.edit_outlined, label: context.l10n.edit),
        ),
        PopupMenuItem(
          value: _TileAction.delete,
          child: _MenuItem(
            icon: Icons.delete_outline,
            label: context.l10n.delete,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon), const SizedBox(width: 12), Text(label)]);
  }
}

Future<void> _showSemesterDialog(
  BuildContext context,
  WidgetRef ref, {
  required TimetableSnapshot snapshot,
  SemesterSummary? semester,
}) async {
  final l10n = context.l10n;
  final initialStartDate =
      semester?.firstWeekMonday ??
      snapshot.activeSemester.firstWeekMonday.add(const Duration(days: 7 * 20));
  String generatedNameFor(DateTime date) =>
      l10n.semesterName(date.year, date.month.toString().padLeft(2, '0'));
  final nameController = TextEditingController(
    text: semester?.name ?? generatedNameFor(initialStartDate),
  );
  final formKey = GlobalKey<FormState>();
  var startDate = initialStartDate;
  var endDate = semester?.endDate;
  var nameManuallyEdited = semester?.nameManuallyEdited ?? false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text(
              semester == null ? l10n.addSemester : l10n.editSemester,
            ),
            content: SizedBox(
              width: 420,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: l10n.semesterNameLabel,
                      ),
                      onChanged: (value) {
                        nameManuallyEdited =
                            value.trim() != generatedNameFor(startDate);
                      },
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.requiredField
                          : null,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: Text(l10n.semesterStartDate),
                      subtitle: Text(_formatDate(startDate)),
                      onTap: () async {
                        final picked = await _pickSemesterDate(
                          dialogContext,
                          initialDate: startDate,
                          helpText: l10n.chooseSemesterStartDate,
                          mondayOnly: true,
                        );
                        if (picked == null) {
                          return;
                        }
                        setState(() {
                          startDate = picked;
                          if (endDate != null && endDate!.isBefore(startDate)) {
                            endDate = null;
                          }
                          if (!nameManuallyEdited) {
                            nameController.text = generatedNameFor(startDate);
                          }
                        });
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_available_outlined),
                      title: Text(l10n.semesterEndDateOptional),
                      subtitle: Text(
                        endDate == null
                            ? l10n.noSemesterEndDate
                            : _formatDate(endDate!),
                      ),
                      trailing: endDate == null
                          ? null
                          : IconButton(
                              tooltip: l10n.clear,
                              onPressed: () => setState(() => endDate = null),
                              icon: const Icon(Icons.close),
                            ),
                      onTap: () async {
                        final picked = await _pickSemesterDate(
                          dialogContext,
                          initialDate:
                              endDate ??
                              startDate.add(const Duration(days: 120)),
                          firstDate: startDate,
                          helpText: l10n.chooseSemesterEndDate,
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  final controller = ref.read(
                    timetableControllerProvider.notifier,
                  );
                  final name = nameController.text.trim();
                  final manuallyEdited = name != generatedNameFor(startDate);
                  if (semester == null) {
                    await controller.createSemester(
                      name: name,
                      firstWeekMonday: startDate,
                      endDate: endDate,
                      nameManuallyEdited: manuallyEdited,
                    );
                  } else {
                    await controller.updateSemester(
                      semesterId: semester.id,
                      name: name,
                      firstWeekMonday: startDate,
                      endDate: endDate,
                      nameManuallyEdited: manuallyEdited,
                    );
                  }
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      );
    },
  );
  nameController.dispose();
}

Future<void> _showPlanDialog(
  BuildContext context,
  WidgetRef ref, {
  required int semesterId,
  required String initialName,
  PlanSummary? plan,
}) async {
  final l10n = context.l10n;
  final nameController = TextEditingController(text: initialName);
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(plan == null ? l10n.newPlan : l10n.editPlan),
        content: SizedBox(
          width: 360,
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.planNameLabel),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.requiredField
                  : null,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }
              final controller = ref.read(timetableControllerProvider.notifier);
              final name = nameController.text.trim();
              if (plan == null) {
                await controller.createPlan(semesterId: semesterId, name: name);
              } else {
                await controller.updatePlan(planId: plan.id, name: name);
              }
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.save),
          ),
        ],
      );
    },
  );
  nameController.dispose();
}

Future<void> _confirmDeleteSemester(
  BuildContext context,
  WidgetRef ref, {
  required SemesterSummary semester,
  required int semesterCount,
}) async {
  final deleteKey = 'semester:${semester.id}';
  if (!_pendingDeletionKeys.add(deleteKey)) {
    return;
  }
  final l10n = context.l10n;
  try {
    if (semesterCount <= 1) {
      _showSnackBar(context, l10n.cannotDeleteLastSemester);
      return;
    }
    final confirmed = await _confirmDestructive(
      context,
      title: l10n.deleteSemester,
      message: l10n.deleteSemesterConfirmation(semester.name),
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    try {
      final snapshot = await ref
          .read(timetableControllerProvider.notifier)
          .deleteSemesterForUndo(semester.id);
      if (context.mounted) {
        _showSnackBar(
          context,
          l10n.semesterDeleted,
          actionLabel: l10n.restore,
          onActionPressed: () {
            ref
                .read(timetableControllerProvider.notifier)
                .restoreDeletedSemester(snapshot);
          },
        );
      }
    } on StateError {
      if (context.mounted) {
        _showSnackBar(context, l10n.cannotDeleteLastSemester);
      }
    }
  } finally {
    _pendingDeletionKeys.remove(deleteKey);
  }
}

Future<void> _confirmDeletePlan(
  BuildContext context,
  WidgetRef ref, {
  required PlanSummary plan,
  required int planCount,
}) async {
  final deleteKey = 'plan:${plan.id}';
  if (!_pendingDeletionKeys.add(deleteKey)) {
    return;
  }
  final l10n = context.l10n;
  try {
    if (planCount <= 1) {
      _showSnackBar(context, l10n.cannotDeleteLastPlan);
      return;
    }
    final confirmed = await _confirmDestructive(
      context,
      title: l10n.deletePlan,
      message: l10n.deletePlanConfirmation(plan.name),
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    try {
      final snapshot = await ref
          .read(timetableControllerProvider.notifier)
          .deletePlanForUndo(plan.id);
      if (context.mounted) {
        _showSnackBar(
          context,
          l10n.planDeleted,
          actionLabel: l10n.restore,
          onActionPressed: () {
            ref
                .read(timetableControllerProvider.notifier)
                .restoreDeletedPlan(snapshot);
          },
        );
      }
    } on StateError {
      if (context.mounted) {
        _showSnackBar(context, l10n.cannotDeleteLastPlan);
      }
    }
  } finally {
    _pendingDeletionKeys.remove(deleteKey);
  }
}

Future<bool> _confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<DateTime?> _pickSemesterDate(
  BuildContext context, {
  required DateTime initialDate,
  required String helpText,
  DateTime? firstDate,
  bool mondayOnly = false,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate ?? DateTime(2020),
    lastDate: DateTime(2035),
    helpText: helpText,
    selectableDayPredicate: mondayOnly
        ? (date) => date.weekday == DateTime.monday
        : null,
  );
}

void _showSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onActionPressed,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      action: actionLabel == null || onActionPressed == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onActionPressed),
    ),
  );
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
