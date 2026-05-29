import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_state.dart';
import '../../timetable/data/timetable_repository.dart';
import '../data/timetable_parser.dart';
import '../domain/merge_engine.dart';
import '../domain/parsed_timetable.dart';

class ImportPreviewState {
  const ImportPreviewState({
    this.parsed,
    this.mergeResult,
    this.commitSummary,
    this.committed = false,
  });

  final ParsedTimetable? parsed;
  final MergeResult? mergeResult;
  final ImportCommitSummary? commitSummary;
  final bool committed;

  bool get hasPreview => parsed != null;
}

class ImportPreviewController extends AsyncNotifier<ImportPreviewState> {
  final _parser = TimetableImportParser();

  @override
  FutureOr<ImportPreviewState> build() => const ImportPreviewState();

  Future<void> chooseFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xls', 'ics', 'html'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final file = result.files.single;
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();
      return _buildPreview(sourceName: file.name, bytes: bytes);
    });
  }

  Future<void> markCommitted() async {
    final current = state.asData?.value;
    if (current == null || !current.hasPreview) {
      return;
    }
    final parsed = current.parsed!;
    final summary = await ref
        .read(timetableControllerProvider.notifier)
        .commitImport(parsed);
    state = AsyncData(
      ImportPreviewState(
        parsed: parsed,
        mergeResult: current.mergeResult,
        commitSummary: summary,
        committed: true,
      ),
    );
  }

  Future<ImportPreviewState> _buildPreview({
    required String sourceName,
    required List<int> bytes,
  }) async {
    final repository = ref.read(timetableRepositoryProvider);
    final snapshot = await repository.loadSnapshot();
    final parsed = await _parser.parse(
      sourceName: sourceName,
      bytes: bytes,
      semesterFirstWeekMonday: snapshot.activeSemester.firstWeekMonday,
    );
    final mergeResult = await repository.previewImport(parsed);
    return ImportPreviewState(parsed: parsed, mergeResult: mergeResult);
  }
}

final importPreviewControllerProvider =
    AsyncNotifierProvider<ImportPreviewController, ImportPreviewState>(
      ImportPreviewController.new,
    );
