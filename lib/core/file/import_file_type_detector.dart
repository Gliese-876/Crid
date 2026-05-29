import 'dart:convert';

enum ImportFileType { htmlXls, biffXls, ics, unknown }

class ImportFileTypeDetector {
  const ImportFileTypeDetector();

  ImportFileType detect({required String fileName, required List<int> bytes}) {
    final extension = _extensionOf(fileName);
    if (_hasOleCompoundSignature(bytes)) {
      return ImportFileType.biffXls;
    }

    final prefix = ascii
        .decode(
          bytes.take(bytes.length < 4096 ? bytes.length : 4096).toList(),
          allowInvalid: true,
        )
        .trimLeft()
        .toLowerCase();

    if (prefix.startsWith('begin:vcalendar') ||
        prefix.contains('\nbegin:vcalendar') ||
        extension == '.ics' && prefix.contains('vcalendar')) {
      return ImportFileType.ics;
    }

    if (prefix.startsWith('<!doctype html') ||
        prefix.startsWith('<html') ||
        prefix.contains('<table')) {
      return ImportFileType.htmlXls;
    }

    if (extension == '.html' || extension == '.htm') {
      return ImportFileType.htmlXls;
    }

    return ImportFileType.unknown;
  }

  bool _hasOleCompoundSignature(List<int> bytes) {
    const signature = [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1];
    if (bytes.length < signature.length) {
      return false;
    }
    for (var i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) {
        return false;
      }
    }
    return true;
  }

  String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0) {
      return '';
    }
    return fileName.substring(dot).toLowerCase();
  }
}
