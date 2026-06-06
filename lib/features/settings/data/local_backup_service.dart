import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_state.dart';
import '../../../data/database/app_database.dart';

const currentBackupFormatVersion = 1;

final localBackupServiceProvider = Provider<LocalBackupService>((ref) {
  return LocalBackupService(ref.watch(appDatabaseProvider));
});

class LocalBackupService {
  const LocalBackupService(this._db);

  final AppDatabase _db;

  Future<Uint8List> exportBackupBytes() async {
    final preferences = await SharedPreferences.getInstance();
    final backup = <String, Object?>{
      'format': 'crid-local-backup',
      'version': currentBackupFormatVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'database': {
        'semesters': [
          for (final row in await _db.select(_db.semesters).get()) row.toJson(),
        ],
        'timetablePlans': [
          for (final row in await _db.select(_db.timetablePlans).get())
            row.toJson(),
        ],
        'importBatches': [
          for (final row in await _db.select(_db.importBatches).get())
            row.toJson(),
        ],
        'sourceRecords': [
          for (final row in await _db.select(_db.sourceRecords).get())
            row.toJson(),
        ],
        'courses': [
          for (final row in await _db.select(_db.courses).get()) row.toJson(),
        ],
        'classSessions': [
          for (final row in await _db.select(_db.classSessions).get())
            row.toJson(),
        ],
        'mergeConflicts': [
          for (final row in await _db.select(_db.mergeConflicts).get())
            row.toJson(),
        ],
        'reminderRules': [
          for (final row in await _db.select(_db.reminderRules).get())
            row.toJson(),
        ],
        'examSchedules': [
          for (final row in await _db.select(_db.examSchedules).get())
            row.toJson(),
        ],
      },
      'preferences': await _exportPreferences(preferences),
    };
    return Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(backup)),
    );
  }

  Future<void> restoreBackupBytes(Uint8List bytes) async {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, Object?> ||
        decoded['format'] != 'crid-local-backup') {
      throw const FormatException('Not a Crid local backup file.');
    }
    final database = decoded['database'];
    if (database is! Map<String, Object?>) {
      throw const FormatException('Backup database section is missing.');
    }
    await _db.transaction(() async {
      await _deleteAllRows();
      await _insertAllRows(database);
    });
    final preferences = await SharedPreferences.getInstance();
    await _restorePreferences(
      preferences,
      decoded['preferences'] as Map<String, Object?>? ?? const {},
    );
  }

  Future<Map<String, Object?>> _exportPreferences(
    SharedPreferences preferences,
  ) async {
    return {
      for (final key in preferences.getKeys())
        key: {
          'type': _preferenceType(preferences.get(key)),
          'value': preferences.get(key),
        },
    };
  }

  String _preferenceType(Object? value) {
    return switch (value) {
      bool() => 'bool',
      int() => 'int',
      double() => 'double',
      String() => 'string',
      List<String>() => 'stringList',
      _ => 'unknown',
    };
  }

  Future<void> _restorePreferences(
    SharedPreferences preferences,
    Map<String, Object?> values,
  ) async {
    await preferences.clear();
    for (final entry in values.entries) {
      final encoded = entry.value;
      if (encoded is! Map<String, Object?>) {
        continue;
      }
      final value = encoded['value'];
      switch (encoded['type']) {
        case 'bool':
          if (value is bool) {
            await preferences.setBool(entry.key, value);
          }
        case 'int':
          if (value is int) {
            await preferences.setInt(entry.key, value);
          }
        case 'double':
          if (value is num) {
            await preferences.setDouble(entry.key, value.toDouble());
          }
        case 'string':
          if (value is String) {
            await preferences.setString(entry.key, value);
          }
        case 'stringList':
          if (value is List) {
            await preferences.setStringList(
              entry.key,
              value.whereType<String>().toList(),
            );
          }
      }
    }
  }

  Future<void> _deleteAllRows() async {
    await _db.delete(_db.examSchedules).go();
    await _db.delete(_db.mergeConflicts).go();
    await _db.delete(_db.classSessions).go();
    await _db.delete(_db.reminderRules).go();
    await _db.delete(_db.courses).go();
    await _db.delete(_db.sourceRecords).go();
    await _db.delete(_db.importBatches).go();
    await _db.delete(_db.timetablePlans).go();
    await _db.delete(_db.semesters).go();
  }

  Future<void> _insertAllRows(Map<String, Object?> database) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.semesters,
        _rows(
          database,
          'semesters',
        ).map((row) => Semester.fromJson(row).toCompanion(false)),
      );
      batch.insertAll(
        _db.timetablePlans,
        _rows(
          database,
          'timetablePlans',
        ).map((row) => TimetablePlan.fromJson(row).toCompanion(false)),
      );
      batch.insertAll(
        _db.importBatches,
        _rows(
          database,
          'importBatches',
        ).map((row) => ImportBatche.fromJson(row).toCompanion(false)),
      );
      batch.insertAll(
        _db.sourceRecords,
        _rows(
          database,
          'sourceRecords',
        ).map((row) => SourceRecord.fromJson(row).toCompanion(false)),
      );
      batch.insertAll(
        _db.courses,
        _rows(
          database,
          'courses',
        ).map((row) => Course.fromJson(row).toCompanion(false)),
      );
      batch.insertAll(
        _db.classSessions,
        _rows(
          database,
          'classSessions',
        ).map((row) => ClassSession.fromJson(row).toCompanion(false)),
      );
      batch.insertAll(
        _db.mergeConflicts,
        _rows(
          database,
          'mergeConflicts',
        ).map((row) => MergeConflict.fromJson(row).toCompanion(false)),
      );
      batch.insertAll(
        _db.reminderRules,
        _rows(
          database,
          'reminderRules',
        ).map((row) => ReminderRule.fromJson(row).toCompanion(false)),
      );
      batch.insertAll(
        _db.examSchedules,
        _rows(
          database,
          'examSchedules',
        ).map((row) => ExamSchedule.fromJson(row).toCompanion(false)),
      );
    });
  }

  Iterable<Map<String, dynamic>> _rows(
    Map<String, Object?> database,
    String key,
  ) sync* {
    final rows = database[key];
    if (rows is! List) {
      return;
    }
    for (final row in rows) {
      if (row is Map) {
        yield Map<String, dynamic>.from(row);
      }
    }
  }
}
