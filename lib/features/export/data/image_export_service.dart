import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

abstract interface class TimetableImageExportService {
  Future<TimetableImageExportResult> exportPng({
    required GlobalKey repaintBoundaryKey,
    required String outputPath,
    double pixelRatio,
  });
}

class TimetableImageExportResult {
  const TimetableImageExportResult({required this.path, required this.bytes});

  final String path;
  final int bytes;
}

class RepaintBoundaryImageExportService implements TimetableImageExportService {
  const RepaintBoundaryImageExportService();

  @override
  Future<TimetableImageExportResult> exportPng({
    required GlobalKey repaintBoundaryKey,
    required String outputPath,
    double pixelRatio = 3,
  }) async {
    final context = repaintBoundaryKey.currentContext;
    if (context == null) {
      throw StateError('The repaint boundary is not mounted.');
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError('The key does not point to a RepaintBoundary.');
    }

    final image = await renderObject.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode the timetable image as PNG.');
    }

    final bytes = byteData.buffer.asUint8List();
    final file = File(outputPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    return TimetableImageExportResult(path: outputPath, bytes: bytes.length);
  }
}
