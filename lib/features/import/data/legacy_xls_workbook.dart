import 'dart:typed_data';

class LegacyXlsWorkbook {
  const LegacyXlsWorkbook({required this.sheets});

  final List<LegacyXlsSheet> sheets;
}

class LegacyXlsSheet {
  const LegacyXlsSheet({required this.name, required this.cells});

  final String name;
  final Map<int, Map<int, String>> cells;

  String? valueAt(int row, int column) => cells[row]?[column];
}

class LegacyXlsWorkbookDecoder {
  const LegacyXlsWorkbookDecoder();

  LegacyXlsWorkbook decode(List<int> bytes) {
    final reader = _CompoundFileReader(Uint8List.fromList(bytes));
    final workbookBytes =
        reader.readStream('Workbook') ?? reader.readStream('Book');
    if (workbookBytes == null) {
      throw const FormatException('BIFF workbook stream was not found.');
    }
    return _BiffWorkbookReader(workbookBytes).read();
  }
}

class _BiffWorkbookReader {
  _BiffWorkbookReader(this.bytes);

  final Uint8List bytes;

  LegacyXlsWorkbook read() {
    final records = _recordsFrom(0).toList(growable: false);
    final sharedStrings = _readSharedStrings(records);
    final boundsheets = _readBoundsheets(records);
    final sheets = <LegacyXlsSheet>[];

    if (boundsheets.isEmpty) {
      sheets.add(_readSheet('Sheet1', 0, sharedStrings));
    } else {
      for (final sheet in boundsheets) {
        sheets.add(_readSheet(sheet.name, sheet.offset, sharedStrings));
      }
    }

    return LegacyXlsWorkbook(sheets: List.unmodifiable(sheets));
  }

  List<String> _readSharedStrings(List<_BiffRecord> records) {
    final buffers = <int>[];
    var collecting = false;
    for (final record in records) {
      if (record.sid == 0x00FC) {
        collecting = true;
        buffers.addAll(record.data);
      } else if (collecting && record.sid == 0x003C) {
        buffers.addAll(record.data);
      } else if (collecting) {
        break;
      }
    }
    if (buffers.length < 8) {
      return const [];
    }

    final data = Uint8List.fromList(buffers);
    final view = ByteData.sublistView(data);
    final uniqueCount = view.getUint32(4, Endian.little);
    var offset = 8;
    final strings = <String>[];
    for (var index = 0; index < uniqueCount && offset < data.length; index++) {
      final parsed = _readUnicodeString(data, offset);
      strings.add(parsed.value);
      offset = parsed.nextOffset;
    }
    return strings;
  }

  List<_BoundSheet> _readBoundsheets(List<_BiffRecord> records) {
    final sheets = <_BoundSheet>[];
    for (final record in records.where((record) => record.sid == 0x0085)) {
      if (record.data.length < 8) {
        continue;
      }
      final view = ByteData.sublistView(record.data);
      final offset = view.getUint32(0, Endian.little);
      final nameLength = record.data[6];
      final flags = record.data[7];
      final isUtf16 = flags & 0x01 != 0;
      final byteLength = nameLength * (isUtf16 ? 2 : 1);
      if (8 + byteLength > record.data.length) {
        continue;
      }
      final raw = record.data.sublist(8, 8 + byteLength);
      sheets.add(
        _BoundSheet(
          offset: offset,
          name: _decodeText(raw, isUtf16: isUtf16),
        ),
      );
    }
    return sheets;
  }

  LegacyXlsSheet _readSheet(
    String name,
    int offset,
    List<String> sharedStrings,
  ) {
    final cells = <int, Map<int, String>>{};
    for (final record in _recordsFrom(offset)) {
      if (record.sid == 0x000A) {
        break;
      }
      switch (record.sid) {
        case 0x00FD:
          _readLabelSst(record, sharedStrings, cells);
        case 0x0204:
          _readLabel(record, cells);
        case 0x0203:
          _readNumber(record, cells);
        case 0x027E:
          _readRk(record, cells);
        case 0x00BD:
          _readMulRk(record, cells);
      }
    }
    return LegacyXlsSheet(name: name, cells: cells);
  }

  Iterable<_BiffRecord> _recordsFrom(int offset) sync* {
    var cursor = offset;
    while (cursor + 4 <= bytes.length) {
      final sid = _uint16(cursor);
      final length = _uint16(cursor + 2);
      final dataStart = cursor + 4;
      final dataEnd = dataStart + length;
      if (dataEnd > bytes.length) {
        break;
      }
      yield _BiffRecord(sid, bytes.sublist(dataStart, dataEnd));
      cursor = dataEnd;
    }
  }

  void _readLabelSst(
    _BiffRecord record,
    List<String> sharedStrings,
    Map<int, Map<int, String>> cells,
  ) {
    if (record.data.length < 10) {
      return;
    }
    final view = ByteData.sublistView(record.data);
    final row = view.getUint16(0, Endian.little);
    final column = view.getUint16(2, Endian.little);
    final index = view.getUint32(6, Endian.little);
    if (index < sharedStrings.length) {
      _setCell(cells, row, column, sharedStrings[index]);
    }
  }

  void _readLabel(_BiffRecord record, Map<int, Map<int, String>> cells) {
    if (record.data.length < 8) {
      return;
    }
    final view = ByteData.sublistView(record.data);
    final row = view.getUint16(0, Endian.little);
    final column = view.getUint16(2, Endian.little);
    final parsed = _readUnicodeString(record.data, 6);
    _setCell(cells, row, column, parsed.value);
  }

  void _readNumber(_BiffRecord record, Map<int, Map<int, String>> cells) {
    if (record.data.length < 14) {
      return;
    }
    final view = ByteData.sublistView(record.data);
    final row = view.getUint16(0, Endian.little);
    final column = view.getUint16(2, Endian.little);
    final value = view.getFloat64(6, Endian.little);
    _setCell(cells, row, column, _formatNumber(value));
  }

  void _readRk(_BiffRecord record, Map<int, Map<int, String>> cells) {
    if (record.data.length < 10) {
      return;
    }
    final view = ByteData.sublistView(record.data);
    final row = view.getUint16(0, Endian.little);
    final column = view.getUint16(2, Endian.little);
    _setCell(
      cells,
      row,
      column,
      _formatNumber(_decodeRk(view.getUint32(6, Endian.little))),
    );
  }

  void _readMulRk(_BiffRecord record, Map<int, Map<int, String>> cells) {
    if (record.data.length < 10) {
      return;
    }
    final view = ByteData.sublistView(record.data);
    final row = view.getUint16(0, Endian.little);
    final firstColumn = view.getUint16(2, Endian.little);
    final lastColumn = view.getUint16(record.data.length - 2, Endian.little);
    var offset = 4;
    for (var column = firstColumn; column <= lastColumn; column++) {
      if (offset + 6 > record.data.length - 2) {
        break;
      }
      final rk = view.getUint32(offset + 2, Endian.little);
      _setCell(cells, row, column, _formatNumber(_decodeRk(rk)));
      offset += 6;
    }
  }

  int _uint16(int offset) {
    return ByteData.sublistView(bytes).getUint16(offset, Endian.little);
  }
}

class _CompoundFileReader {
  _CompoundFileReader(this.bytes) {
    _readHeader();
    _readFat();
    _readDirectory();
  }

  static const _freeSect = 0xFFFFFFFF;
  static const _endOfChain = 0xFFFFFFFE;
  static const _difSect = 0xFFFFFFFC;

  final Uint8List bytes;
  late final int _sectorSize;
  late final int _miniSectorSize;
  late final int _firstDirectorySector;
  late final int _miniStreamCutoffSize;
  late final int _firstMiniFatSector;
  late final int _miniFatSectorCount;
  late final List<int> _difat;
  final _fat = <int>[];
  final _miniFat = <int>[];
  final _entries = <_DirectoryEntry>[];
  _DirectoryEntry? _rootEntry;
  Uint8List? _miniStream;

  Uint8List? readStream(String name) {
    final entry = _entries.cast<_DirectoryEntry?>().firstWhere(
      (entry) => entry?.name == name,
      orElse: () => null,
    );
    if (entry == null || entry.type != 2) {
      return null;
    }
    if (entry.size < _miniStreamCutoffSize) {
      return _readMiniStream(entry.startSector, entry.size);
    }
    return _readRegularStream(entry.startSector, entry.size);
  }

  void _readHeader() {
    if (bytes.length < 512 ||
        !_startsWith(bytes, const [
          0xD0,
          0xCF,
          0x11,
          0xE0,
          0xA1,
          0xB1,
          0x1A,
          0xE1,
        ])) {
      throw const FormatException('Not an OLE compound file.');
    }
    final view = ByteData.sublistView(bytes);
    _sectorSize = 1 << view.getUint16(30, Endian.little);
    _miniSectorSize = 1 << view.getUint16(32, Endian.little);
    final fatSectorCount = view.getUint32(44, Endian.little);
    _firstDirectorySector = view.getUint32(48, Endian.little);
    _miniStreamCutoffSize = view.getUint32(56, Endian.little);
    _firstMiniFatSector = view.getUint32(60, Endian.little);
    _miniFatSectorCount = view.getUint32(64, Endian.little);
    final firstDifatSector = view.getUint32(68, Endian.little);
    final difatSectorCount = view.getUint32(72, Endian.little);

    final difat = <int>[];
    for (var i = 0; i < 109; i++) {
      final sector = view.getUint32(76 + i * 4, Endian.little);
      if (sector != _freeSect) {
        difat.add(sector);
      }
    }

    var nextDifat = firstDifatSector;
    for (var i = 0; i < difatSectorCount && nextDifat != _endOfChain; i++) {
      final data = _sector(nextDifat);
      final sectorView = ByteData.sublistView(data);
      final entries = _sectorSize ~/ 4 - 1;
      for (var j = 0; j < entries; j++) {
        final sector = sectorView.getUint32(j * 4, Endian.little);
        if (sector != _freeSect && sector != _difSect) {
          difat.add(sector);
        }
      }
      nextDifat = sectorView.getUint32(_sectorSize - 4, Endian.little);
    }

    _difat = difat.take(fatSectorCount).toList(growable: false);
  }

  void _readFat() {
    for (final fatSector in _difat) {
      final data = _sector(fatSector);
      final view = ByteData.sublistView(data);
      for (var offset = 0; offset < data.length; offset += 4) {
        _fat.add(view.getUint32(offset, Endian.little));
      }
    }

    if (_firstMiniFatSector != _endOfChain && _miniFatSectorCount > 0) {
      final miniFatBytes = <int>[];
      for (final sector in _sectorChain(
        _firstMiniFatSector,
      ).take(_miniFatSectorCount)) {
        miniFatBytes.addAll(_sector(sector));
      }
      final view = ByteData.sublistView(Uint8List.fromList(miniFatBytes));
      for (var offset = 0; offset + 4 <= miniFatBytes.length; offset += 4) {
        _miniFat.add(view.getUint32(offset, Endian.little));
      }
    }
  }

  void _readDirectory() {
    final directory = _readRegularStream(_firstDirectorySector, 1 << 30);
    for (var offset = 0; offset + 128 <= directory.length; offset += 128) {
      final entryBytes = directory.sublist(offset, offset + 128);
      final view = ByteData.sublistView(entryBytes);
      final nameLength = view.getUint16(64, Endian.little);
      final type = entryBytes[66];
      if (type == 0 || nameLength < 2) {
        continue;
      }
      final nameBytes = entryBytes.sublist(0, nameLength - 2);
      final startSector = view.getUint32(116, Endian.little);
      final sizeLow = view.getUint32(120, Endian.little);
      final sizeHigh = view.getUint32(124, Endian.little);
      final entry = _DirectoryEntry(
        name: _decodeText(nameBytes, isUtf16: true),
        type: type,
        startSector: startSector,
        size: sizeLow + (sizeHigh << 32),
      );
      _entries.add(entry);
      if (type == 5) {
        _rootEntry = entry;
      }
    }
  }

  Uint8List _readRegularStream(int startSector, int size) {
    final output = BytesBuilder(copy: false);
    for (final sector in _sectorChain(startSector)) {
      output.add(_sector(sector));
      if (output.length >= size) {
        break;
      }
    }
    final data = output.takeBytes();
    return data.length > size ? data.sublist(0, size) : data;
  }

  Uint8List _readMiniStream(int startSector, int size) {
    final root = _rootEntry;
    if (root == null) {
      return Uint8List(0);
    }
    _miniStream ??= _readRegularStream(root.startSector, root.size);
    final output = BytesBuilder(copy: false);
    var sector = startSector;
    final seen = <int>{};
    while (sector != _endOfChain &&
        sector != _freeSect &&
        sector < _miniFat.length &&
        seen.add(sector)) {
      final start = sector * _miniSectorSize;
      final end = start + _miniSectorSize;
      if (end > _miniStream!.length) {
        break;
      }
      output.add(_miniStream!.sublist(start, end));
      if (output.length >= size) {
        break;
      }
      sector = _miniFat[sector];
    }
    final data = output.takeBytes();
    return data.length > size ? data.sublist(0, size) : data;
  }

  Iterable<int> _sectorChain(int startSector) sync* {
    var sector = startSector;
    final seen = <int>{};
    while (sector != _endOfChain &&
        sector != _freeSect &&
        sector < _fat.length &&
        seen.add(sector)) {
      yield sector;
      sector = _fat[sector];
    }
  }

  Uint8List _sector(int sectorId) {
    final start = (sectorId + 1) * _sectorSize;
    final end = start + _sectorSize;
    if (sectorId < 0 || end > bytes.length) {
      throw const FormatException('OLE sector points outside file bounds.');
    }
    return bytes.sublist(start, end);
  }
}

class _BiffRecord {
  const _BiffRecord(this.sid, this.data);

  final int sid;
  final Uint8List data;
}

class _BoundSheet {
  const _BoundSheet({required this.offset, required this.name});

  final int offset;
  final String name;
}

class _DirectoryEntry {
  const _DirectoryEntry({
    required this.name,
    required this.type,
    required this.startSector,
    required this.size,
  });

  final String name;
  final int type;
  final int startSector;
  final int size;
}

({String value, int nextOffset}) _readUnicodeString(
  Uint8List data,
  int offset,
) {
  if (offset + 3 > data.length) {
    return (value: '', nextOffset: data.length);
  }
  final view = ByteData.sublistView(data);
  final charCount = view.getUint16(offset, Endian.little);
  var cursor = offset + 2;
  final flags = data[cursor++];
  final isUtf16 = flags & 0x01 != 0;
  final hasExtended = flags & 0x04 != 0;
  final hasRichText = flags & 0x08 != 0;
  final richRunCount = hasRichText ? view.getUint16(cursor, Endian.little) : 0;
  if (hasRichText) {
    cursor += 2;
  }
  final extendedLength = hasExtended
      ? view.getUint32(cursor, Endian.little)
      : 0;
  if (hasExtended) {
    cursor += 4;
  }
  final byteLength = charCount * (isUtf16 ? 2 : 1);
  final end = (cursor + byteLength).clamp(0, data.length);
  final raw = data.sublist(cursor, end);
  cursor = end + richRunCount * 4 + extendedLength;
  return (
    value: _decodeText(raw, isUtf16: isUtf16),
    nextOffset: cursor.clamp(0, data.length),
  );
}

String _decodeText(List<int> raw, {required bool isUtf16}) {
  if (isUtf16) {
    final units = <int>[];
    for (var i = 0; i + 1 < raw.length; i += 2) {
      units.add(raw[i] | (raw[i + 1] << 8));
    }
    return String.fromCharCodes(units);
  }
  return String.fromCharCodes(raw);
}

double _decodeRk(int value) {
  final isInteger = value & 0x02 != 0;
  final isDividedBy100 = value & 0x01 != 0;
  double decoded;
  if (isInteger) {
    decoded = (value >> 2).toSigned(30).toDouble();
  } else {
    final raw = (value & 0xFFFFFFFC) << 32;
    final bytes = ByteData(8)..setUint64(0, raw, Endian.little);
    decoded = bytes.getFloat64(0, Endian.little);
  }
  return isDividedBy100 ? decoded / 100 : decoded;
}

String _formatNumber(double value) {
  if (value.isFinite && value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toString();
}

void _setCell(
  Map<int, Map<int, String>> cells,
  int row,
  int column,
  String value,
) {
  cells.putIfAbsent(row, () => <int, String>{})[column] = value.trim();
}

bool _startsWith(List<int> bytes, List<int> signature) {
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
