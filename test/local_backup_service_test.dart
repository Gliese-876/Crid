import 'dart:convert';

import 'package:crid/core/file/import_file_type_detector.dart';
import 'package:crid/core/time/period.dart';
import 'package:crid/data/database/app_database.dart';
import 'package:crid/features/import/domain/parsed_exam_schedule.dart';
import 'package:crid/features/settings/data/china_holiday_service.dart';
import 'package:crid/features/settings/data/local_backup_service.dart';
import 'package:crid/features/timetable/data/timetable_repository.dart';
import 'package:crid/features/timetable/presentation/course_slot_model.dart'
    as timetable;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('exports and restores local database rows and preferences', () async {
    SharedPreferences.setMockInitialValues({
      'localeMode': 'english',
      'darkMode': true,
      'recentImports': ['a.xls', 'b.pdf'],
      'holiday_course_display_mode': HolidayCourseDisplayMode.hidden.name,
      'holiday_exam_display_mode': HolidayCourseDisplayMode.muted.name,
    });
    final sourceDb = AppDatabase(NativeDatabase.memory());
    var sourceDbOpen = true;
    addTearDown(() async {
      if (sourceDbOpen) {
        await sourceDb.close();
      }
    });
    final sourceRepository = TimetableRepository(sourceDb);
    final sourceSnapshot = await sourceRepository.loadSnapshot();

    await sourceRepository.saveCourse(
      CourseSlotDraft(
        name: 'Backup Systems',
        teacher: 'Ada',
        location: 'A101',
        weekday: DateTime.monday,
        timeRange: CourseTimeRange.fromPeriods(1, 2),
        startWeek: 1,
        endWeek: 16,
        parity: timetable.WeekParity.all,
        color: const Color(0xFF3366CC),
      ),
    );
    await sourceRepository.updateReminderSettings(
      const ReminderSettings(
        enabled: true,
        reminderOffsets: [5, 30],
        ignoreDoNotDisturb: true,
        vibrateOnly: true,
      ),
    );
    await sourceRepository.commitExamImport(
      ParsedExamSchedule(
        sourceName: 'exam.txt',
        fileType: ImportFileType.plainText,
        exams: [
          ParsedExam(
            examRound: '期末考试（16-18周）轮次',
            courseCode: 'MAT11002',
            courseName: '数学分析Ⅱ',
            credits: 6,
            category: '专业课程/专业核心课',
            assessmentMethod: '考试',
            startAt: DateTime(2026, 6, 15, 10, 20),
            endAt: DateTime(2026, 6, 15, 12, 20),
            semesterWeek: 16,
            weekday: DateTime.monday,
            location: '励耘楼 励耘楼A302',
            seatNumber: '78',
            rawText: 'raw exam row',
          ),
        ],
      ),
    );

    final backupBytes = await LocalBackupService(sourceDb).exportBackupBytes();
    await sourceDb.close();
    sourceDbOpen = false;
    final backupJson =
        jsonDecode(utf8.decode(backupBytes)) as Map<String, Object?>;
    expect(backupJson['format'], 'crid-local-backup');

    SharedPreferences.setMockInitialValues({});
    final targetDb = AppDatabase(NativeDatabase.memory());
    addTearDown(targetDb.close);
    await LocalBackupService(targetDb).restoreBackupBytes(backupBytes);

    final targetRepository = TimetableRepository(targetDb);
    final restoredSnapshot = await targetRepository.loadSnapshot();
    expect(
      restoredSnapshot.activeSemester.id,
      sourceSnapshot.activeSemester.id,
    );
    expect(
      restoredSnapshot.courses.map((course) => course.name),
      contains('Backup Systems'),
    );
    final reminderSettings = await targetRepository.loadReminderSettings();
    expect(reminderSettings.enabled, isTrue);
    expect(reminderSettings.reminderOffsets, [5, 30]);
    expect(reminderSettings.ignoreDoNotDisturb, isTrue);
    expect(reminderSettings.vibrateOnly, isTrue);

    final exams = await targetRepository.loadExamSchedules();
    expect(exams, hasLength(1));
    expect(exams.single.courseCode, 'MAT11002');
    expect(exams.single.seatNumber, '78');
    expect(exams.single.isHidden, isFalse);

    final restoredPreferences = await SharedPreferences.getInstance();
    expect(restoredPreferences.getString('localeMode'), 'english');
    expect(restoredPreferences.getBool('darkMode'), isTrue);
    expect(restoredPreferences.getStringList('recentImports'), [
      'a.xls',
      'b.pdf',
    ]);
    expect(
      restoredPreferences.getString('holiday_course_display_mode'),
      HolidayCourseDisplayMode.hidden.name,
    );
    expect(
      restoredPreferences.getString('holiday_exam_display_mode'),
      HolidayCourseDisplayMode.muted.name,
    );
  });
}
