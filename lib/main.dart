import 'package:crid/app/app.dart';
import 'package:crid/app/motion_warm_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  installAppShaderWarmUp();
  runApp(const ProviderScope(child: CridApp()));
}
