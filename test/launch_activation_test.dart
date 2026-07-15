import 'package:crid/app/launch_activation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Windows launch activation recognizes supported import files', () {
    expect(
      launchImportFilePath([
        'notification-activation',
        r'"C:\Course Files\spring schedule.ICS"',
      ]),
      r'C:\Course Files\spring schedule.ICS',
    );
    expect(launchImportFilePath([r'C:\Course Files\schedule.docx']), isNull);
  });

  test('Windows and in-app imports share the same extension set', () {
    expect(supportedImportFileExtensions, {
      '.ics',
      '.xls',
      '.mht',
      '.mhtml',
      '.pdf',
      '.txt',
    });
  });
}
