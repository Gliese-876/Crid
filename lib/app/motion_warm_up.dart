import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void installAppShaderWarmUp() {
  if (kIsWeb) {
    return;
  }
  PaintingBinding.shaderWarmUp = const _AppShaderWarmUp();
}

class _AppShaderWarmUp extends ShaderWarmUp {
  const _AppShaderWarmUp();

  @override
  ui.Size get size => const ui.Size(360, 640);

  @override
  Future<void> warmUpOnCanvas(ui.Canvas canvas) async {
    final paint = ui.Paint()..isAntiAlias = true;
    canvas.drawColor(const ui.Color(0xFFFFFFFF), ui.BlendMode.src);

    final surface = ui.RRect.fromRectAndRadius(
      const ui.Rect.fromLTWH(24, 32, 312, 172),
      const ui.Radius.circular(24),
    );
    final path = ui.Path()..addRRect(surface);
    canvas.drawShadow(path, const ui.Color(0x33000000), 8, true);
    paint.color = const ui.Color(0xFFF5F7FF);
    canvas.drawRRect(surface, paint);

    paint.shader = ui.Gradient.linear(
      const ui.Offset(36, 52),
      const ui.Offset(324, 112),
      const <ui.Color>[ui.Color(0x334D73FF), ui.Color(0x55A7D676)],
    );
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        const ui.Rect.fromLTWH(36, 52, 288, 48),
        const ui.Radius.circular(20),
      ),
      paint,
    );
    paint.shader = null;

    paint.color = const ui.Color(0xFF4D73FF);
    canvas.drawCircle(const ui.Offset(68, 136), 22, paint);
    paint.color = const ui.Color(0xFFA7D676);
    canvas.drawRRect(
      ui.RRect.fromRectAndRadius(
        const ui.Rect.fromLTWH(104, 118, 188, 36),
        const ui.Radius.circular(18),
      ),
      paint,
    );

    for (var row = 0; row < 5; row++) {
      for (var column = 0; column < 4; column++) {
        final left = 24.0 + column * 78;
        final top = 248.0 + row * 62;
        final block = ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(left, top, 66, 48),
          const ui.Radius.circular(8),
        );
        paint.color = ui.Color.lerp(
          const ui.Color(0xFF4D73FF),
          const ui.Color(0xFFE36FAD),
          (row + column) / 8,
        )!;
        canvas.drawRRect(block, paint);
      }
    }

    canvas.save();
    canvas.clipRRect(
      ui.RRect.fromRectAndRadius(
        const ui.Rect.fromLTWH(36, 548, 288, 48),
        const ui.Radius.circular(24),
      ),
    );
    paint.color = const ui.Color(0xFFE8EEFF);
    canvas.drawRect(const ui.Rect.fromLTWH(36, 548, 288, 48), paint);
    paint.color = const ui.Color(0xFF4D73FF);
    canvas.drawCircle(const ui.Offset(76, 572), 18, paint);
    canvas.restore();
  }
}
