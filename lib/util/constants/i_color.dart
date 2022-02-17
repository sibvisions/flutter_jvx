import 'package:flutter/material.dart';

/// Class defining various colors.
abstract class IColorConstants {
  static const Color COMPONENT_DISABLED = Color(0xFFBDBDBD);

  static const Color ICONTROL_BACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_ALTERNATEBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_FOREGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_ACTIVESELECTIONBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_ACTIVESELECTIONFOREGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_INACTIVESELECTIONBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_INACTIVESELECTIONFOREGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_MANDATORYBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_READONLYBACKGROUND = Color(0xFFFFFFFF);
  static const Color ICONTROL_INVALIDEDITORBACKGROUND = Color(0xFFFFFFFF);

  static const Map<String, Color> SERVER_COLORS = {
    "icontrol_background": ICONTROL_BACKGROUND,
    "icontrol_alternateBackground": ICONTROL_ALTERNATEBACKGROUND,
    "icontrol_foreground": ICONTROL_FOREGROUND,
    "icontrol_activeSelectionBackground": ICONTROL_ACTIVESELECTIONBACKGROUND,
    "icontrol_activeSelectionForeground": ICONTROL_ACTIVESELECTIONFOREGROUND,
    "icontrol_inactiveSelectionBackground": ICONTROL_INACTIVESELECTIONBACKGROUND,
    "icontrol_inactiveSelectionForeground": ICONTROL_INACTIVESELECTIONFOREGROUND,
    "icontrol_mandatoryBackground": ICONTROL_MANDATORYBACKGROUND,
    "icontrol_readOnlyBackground": ICONTROL_READONLYBACKGROUND,
    "icontrol_invalidEditorBackground": ICONTROL_INVALIDEDITORBACKGROUND
  };
}
