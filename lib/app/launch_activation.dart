import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

const supportedImportFileExtensions = <String>{
  '.ics',
  '.xls',
  '.mht',
  '.mhtml',
  '.pdf',
  '.txt',
};

final launchArgumentsProvider = Provider<List<String>>(
  (ref) => const <String>[],
);

String? launchImportFilePath(Iterable<String> arguments) {
  for (final argument in arguments) {
    final candidate = _unquote(argument.trim());
    if (candidate.isEmpty || candidate.startsWith('-')) {
      continue;
    }
    if (supportedImportFileExtensions.contains(
      p.extension(candidate).toLowerCase(),
    )) {
      return candidate;
    }
  }
  return null;
}

String _unquote(String value) {
  if (value.length >= 2 &&
      ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'")))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}
