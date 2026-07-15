import 'dart:io';

import 'package:crid/data/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('partially applied Windows migration can resume safely', () async {
    final directory = await Directory.systemTemp.createTemp(
      'crid-migration-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}crid.sqlite');

    final initial = AppDatabase(NativeDatabase(file));
    await initial.customSelect('SELECT 1').get();
    await initial.customStatement('PRAGMA user_version = 5');
    await initial.close();

    final migrated = AppDatabase(NativeDatabase(file));
    addTearDown(migrated.close);
    final columns = await migrated
        .customSelect('PRAGMA table_info("exam_schedules")')
        .get();
    final schemaVersion = await migrated
        .customSelect('PRAGMA user_version')
        .getSingle();

    expect(
      columns.where((row) => row.read<String>('name') == 'is_hidden'),
      hasLength(1),
    );
    expect(schemaVersion.read<int>('user_version'), 6);
  });
}
