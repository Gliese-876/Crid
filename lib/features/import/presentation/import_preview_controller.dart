import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_state.dart';
import '../../../core/file/import_file_type_detector.dart';
import '../data/kingosoft_exam_parser.dart';
import '../../timetable/data/timetable_repository.dart';
import '../data/timetable_parser.dart';
import '../domain/merge_engine.dart';
import '../domain/parsed_exam_schedule.dart';
import '../domain/parsed_timetable.dart';

class ImportPreviewState {
  const ImportPreviewState({
    this.parsed,
    this.parsedExams,
    this.mergeResult,
    this.commitSummary,
    this.examCommitSummary,
    this.committed = false,
  });

  final ParsedTimetable? parsed;
  final ParsedExamSchedule? parsedExams;
  final MergeResult? mergeResult;
  final ImportCommitSummary? commitSummary;
  final ExamImportCommitSummary? examCommitSummary;
  final bool committed;

  bool get hasPreview => parsed != null || parsedExams != null;
  bool get hasExamPreview => parsedExams != null;
}

class ImportPreviewController extends AsyncNotifier<ImportPreviewState> {
  final _detector = const ImportFileTypeDetector();
  final _parser = TimetableImportParser();
  final _examParser = const KingosoftExamParser();

  @override
  FutureOr<ImportPreviewState> build() => const ImportPreviewState();

  Future<void> chooseFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xls', 'ics', 'mht', 'mhtml', 'pdf', 'txt'],
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

  Future<void> pasteExamText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return _buildExamPreview(
        sourceName: 'KINGOSOFT pasted exam schedule',
        bytes: utf8.encode(trimmed),
      );
    });
  }

  Future<void> markCommitted() async {
    final current = state.asData?.value;
    if (current == null || !current.hasPreview) {
      return;
    }
    if (current.parsedExams != null) {
      final parsed = current.parsedExams!;
      final summary = await ref
          .read(timetableControllerProvider.notifier)
          .commitExamImport(parsed);
      state = AsyncData(
        ImportPreviewState(
          parsedExams: parsed,
          examCommitSummary: summary,
          committed: true,
        ),
      );
      return;
    }
    if (current.parsed != null) {
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
  }

  Future<ImportPreviewState> _buildPreview({
    required String sourceName,
    required List<int> bytes,
  }) async {
    final fileType = _detector.detect(fileName: sourceName, bytes: bytes);
    if (fileType == ImportFileType.mhtml ||
        fileType == ImportFileType.pdf ||
        fileType == ImportFileType.plainText) {
      return _buildExamPreview(sourceName: sourceName, bytes: bytes);
    }
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

  Future<ImportPreviewState> _buildExamPreview({
    required String sourceName,
    required List<int> bytes,
  }) async {
    final parsed = await _examParser.parse(
      sourceName: sourceName,
      bytes: bytes,
    );
    return ImportPreviewState(parsedExams: parsed);
  }
}

final importPreviewControllerProvider =
    AsyncNotifierProvider<ImportPreviewController, ImportPreviewState>(
      ImportPreviewController.new,
    );
