import 'package:crid/app/app.dart';
import 'package:crid/app/launch_activation.dart';
import 'package:crid/app/motion_warm_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main(List<String> arguments) {
  installAppShaderWarmUp();
  runApp(
    ProviderScope(
      overrides: [
        launchArgumentsProvider.overrideWithValue(
          List<String>.unmodifiable(arguments),
        ),
      ],
      child: const CridApp(),
    ),
  );
}
