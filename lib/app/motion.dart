import 'package:flutter/material.dart';

const appMicroMotionDuration = Duration(milliseconds: 220);
const appMicroMotionCurve = Easing.standardDecelerate;
const appMicroMotionReverseCurve = Easing.standardAccelerate;

const appCoreDestinationMotionDuration = Durations.medium4;
const appCoreDestinationMotionCurve = Easing.standard;
const appPageTransitionDuration = Duration(milliseconds: 500);
const appPageReverseTransitionDuration = Duration(milliseconds: 500);

const appMenuPanelBorderRadius = BorderRadius.all(Radius.circular(28));
const appMenuItemBorderRadius = BorderRadius.all(Radius.circular(18));
const appMenuPanelShape = RoundedSuperellipseBorder(
  borderRadius: appMenuPanelBorderRadius,
);

const appMenuAnimationStyle = AnimationStyle(
  curve: Easing.standardDecelerate,
  reverseCurve: Easing.standardAccelerate,
);
