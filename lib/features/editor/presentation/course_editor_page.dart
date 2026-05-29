import 'package:crid/app/app_state.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/core/theme/course_colors.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/features/timetable/presentation/course_slot_model.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CourseEditorPage extends ConsumerStatefulWidget {
  const CourseEditorPage({super.key, this.slotId, this.returnPath});

  final String? slotId;
  final String? returnPath;

  @override
  ConsumerState<CourseEditorPage> createState() => _CourseEditorPageState();
}

class _CourseEditorPageState extends ConsumerState<CourseEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _locationController = TextEditingController();
  final _startWeekController = TextEditingController(text: '1');
  final _endWeekController = TextEditingController(text: '16');
  final _notesController = TextEditingController();

  int _weekday = 1;
  int _startPeriod = 1;
  int _endPeriod = 2;
  WeekParity _parity = WeekParity.all;
  bool _hidden = false;
  int? _courseId;
  int? _sessionId;
  Color _color = courseColorForIndex(0);
  var _hydrated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    _startWeekController.dispose();
    _endWeekController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editingSlotId = widget.slotId;
    if (editingSlotId != null && !_hydrated) {
      final snapshot = ref.watch(timetableControllerProvider);
      if (snapshot.isLoading && !snapshot.hasValue) {
        return const Center(child: CircularProgressIndicator());
      }
      final slot = snapshot.asData?.value.courses
          .where((course) => course.id == editingSlotId)
          .firstOrNull;
      if (slot == null) {
        return Center(child: Text(context.l10n.courseSessionNotFound));
      }
      _loadSlot(slot);
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _sessionId == null
                        ? context.l10n.newCourse
                        : context.l10n.editCourse,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 760;
                      return isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildDetailsColumn()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildScheduleColumn()),
                              ],
                            )
                          : Column(
                              children: [
                                _buildDetailsColumn(),
                                const SizedBox(height: 16),
                                _buildScheduleColumn(),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _hidden,
                    onChanged: (value) => setState(() => _hidden = value),
                    title: Text(context.l10n.hideThisSession),
                    subtitle: Text(context.l10n.hideThisSessionSubtitle),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_sessionId != null)
                          OutlinedButton.icon(
                            onPressed: _delete,
                            icon: const Icon(Icons.delete_outline),
                            label: Text(context.l10n.deleteSession),
                          ),
                        FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(context.l10n.saveCourse),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsColumn() {
    return Column(
      children: [
        _labeledField(
          label: context.l10n.courseName,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.menu_book_outlined),
            ),
            validator: _required,
          ),
        ),
        const SizedBox(height: 14),
        _labeledField(
          label: context.l10n.teacher,
          child: TextFormField(
            controller: _teacherController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _labeledField(
          label: context.l10n.location,
          child: TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.place_outlined),
            ),
            validator: _required,
          ),
        ),
        const SizedBox(height: 14),
        _labeledField(
          label: context.l10n.notes,
          child: TextFormField(
            controller: _notesController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleColumn() {
    return Column(
      children: [
        _labeledField(
          label: context.l10n.weekday,
          child: DropdownButtonFormField<int>(
            initialValue: _weekday,
            dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: appMenuPanelBorderRadius,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_view_week_outlined),
            ),
            items: _weekdayItems(context),
            onChanged: (value) => setState(() => _weekday = value ?? _weekday),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _labeledField(
                label: context.l10n.startPeriod,
                child: DropdownButtonFormField<int>(
                  initialValue: _startPeriod,
                  dropdownColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHigh,
                  borderRadius: appMenuPanelBorderRadius,
                  decoration: const InputDecoration(),
                  items: _periodItems,
                  onChanged: (value) {
                    setState(() {
                      _startPeriod = value ?? _startPeriod;
                      if (_endPeriod < _startPeriod) {
                        _endPeriod = _startPeriod;
                      }
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _labeledField(
                label: context.l10n.endPeriod,
                child: DropdownButtonFormField<int>(
                  initialValue: _endPeriod,
                  dropdownColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHigh,
                  borderRadius: appMenuPanelBorderRadius,
                  decoration: const InputDecoration(),
                  items: _periodItems,
                  onChanged: (value) {
                    setState(() {
                      _endPeriod = value ?? _endPeriod;
                      if (_startPeriod > _endPeriod) {
                        _startPeriod = _endPeriod;
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _labeledField(
                label: context.l10n.startWeek,
                child: TextFormField(
                  controller: _startWeekController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(),
                  validator: _weekNumber,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _labeledField(
                label: context.l10n.endWeek,
                child: TextFormField(
                  controller: _endWeekController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(),
                  validator: _weekNumber,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<WeekParity>(
            segments: [
              ButtonSegment(
                value: WeekParity.all,
                label: Text(context.l10n.allWeeks),
              ),
              ButtonSegment(
                value: WeekParity.odd,
                label: Text(context.l10n.oddWeeks),
              ),
              ButtonSegment(
                value: WeekParity.even,
                label: Text(context.l10n.evenWeeks),
              ),
            ],
            selected: {_parity},
            onSelectionChanged: (selection) {
              setState(() => _parity = selection.single);
            },
          ),
        ),
      ],
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? context.l10n.requiredField
        : null;
  }

  String? _weekNumber(String? value) {
    final week = int.tryParse(value ?? '');
    if (week == null || week < 1 || week > 30) {
      return context.l10n.weekNumberValidation;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(timetableControllerProvider.notifier)
        .saveCourse(
          CourseSlotDraft(
            courseId: _courseId,
            sessionId: _sessionId,
            name: _nameController.text.trim(),
            teacher: _teacherController.text.trim(),
            location: _locationController.text.trim(),
            weekday: _weekday,
            startPeriod: _startPeriod,
            endPeriod: _endPeriod,
            startWeek: int.parse(_startWeekController.text),
            endWeek: int.parse(_endWeekController.text),
            parity: _parity,
            color: _color,
            notes: _notesController.text.trim(),
            hidden: _hidden,
          ),
        );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.courseSaved(
            _nameController.text.trim(),
            _weekday,
            _startPeriod,
            _endPeriod,
          ),
        ),
      ),
    );
    _returnToOrigin();
  }

  Future<void> _delete() async {
    final courseId = _courseId;
    final sessionId = _sessionId;
    if (courseId == null || sessionId == null) {
      return;
    }
    final controller = ref.read(timetableControllerProvider.notifier);
    final restoreDraft = CourseSlotDraft(
      name: _nameController.text.trim(),
      teacher: _teacherController.text.trim(),
      location: _locationController.text.trim(),
      weekday: _weekday,
      startPeriod: _startPeriod,
      endPeriod: _endPeriod,
      startWeek: int.tryParse(_startWeekController.text) ?? 1,
      endWeek: int.tryParse(_endWeekController.text) ?? 1,
      parity: _parity,
      color: _color,
      notes: _notesController.text.trim(),
      hidden: false,
    );
    await controller.deleteSession(courseId: courseId, sessionId: sessionId);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.courseSessionDeleted),
        action: SnackBarAction(
          label: context.l10n.restore,
          onPressed: () {
            controller.saveCourse(restoreDraft);
          },
        ),
      ),
    );
    _returnToOrigin();
  }

  void _returnToOrigin() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final returnPath = widget.returnPath;
    if (returnPath != null && returnPath.isNotEmpty) {
      context.pushReplacement(returnPath);
      return;
    }
    context.pushReplacement('/timetable');
  }

  void _loadSlot(CourseSlot slot) {
    _courseId = slot.courseId;
    _sessionId = slot.sessionId;
    _nameController.text = slot.name;
    _teacherController.text = slot.teacher;
    _locationController.text = slot.location;
    _startWeekController.text = '${slot.startWeek}';
    _endWeekController.text = '${slot.endWeek}';
    _notesController.text = slot.notes;
    _weekday = slot.weekday;
    _startPeriod = slot.startPeriod;
    _endPeriod = slot.endPeriod;
    _parity = slot.parity;
    _color = slot.color;
    _hydrated = true;
  }
}

const _periodItems = [
  DropdownMenuItem(value: 1, child: Text('1')),
  DropdownMenuItem(value: 2, child: Text('2')),
  DropdownMenuItem(value: 3, child: Text('3')),
  DropdownMenuItem(value: 4, child: Text('4')),
  DropdownMenuItem(value: 5, child: Text('5')),
  DropdownMenuItem(value: 6, child: Text('6')),
  DropdownMenuItem(value: 7, child: Text('7')),
  DropdownMenuItem(value: 8, child: Text('8')),
  DropdownMenuItem(value: 9, child: Text('9')),
  DropdownMenuItem(value: 10, child: Text('10')),
  DropdownMenuItem(value: 11, child: Text('11')),
  DropdownMenuItem(value: 12, child: Text('12')),
];

List<DropdownMenuItem<int>> _weekdayItems(BuildContext context) {
  final l10n = context.l10n;
  final labels = [
    l10n.dayMon,
    l10n.dayTue,
    l10n.dayWed,
    l10n.dayThu,
    l10n.dayFri,
    l10n.daySat,
    l10n.daySun,
  ];
  return [
    for (var index = 0; index < labels.length; index++)
      DropdownMenuItem(value: index + 1, child: Text(labels[index])),
  ];
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
