import 'package:flutter/material.dart';

class AppPalette {
  static const mint = Color(0xFFE5F7EF);
  static const mintStrong = Color(0xFFA9C34A);
  static const green = Color(0xFF7EAA31);
  static const greenDark = Color(0xFF53751F);
  static const yellow = Color(0xFFE0B84B);
  static const orange = Color(0xFFE89A49);
  static const red = Color(0xFFE76666);
  static const purple = Color(0xFF8E67DF);
  static const blue = Color(0xFF58AFCB);
  static const ink = Color(0xFF101413);
  static const slate = Color(0xFF6F7C78);
  static const soft = Color(0xFFF8FBF4);
  static const glassLine = Color(0xFFFFFFFF);
  // Dark theme palette
  static const darkBg = Color(0xFF1A2421);
  static const darkCard = Color(0xFF222E2A);
  static const darkCardBorder = Color(0xFF2D3B36);
  static const darkText = Color(0xFFE8EDE9);
  static const darkSubtext = Color(0xFF8A9C95);
  static const darkGreen = Color(0xFF5CB85C);
}

class IconChoice {
  const IconChoice(this.icon, this.color, this.selected);
  final IconData icon;
  final Color color;
  final bool selected;
}

class AttendXData {
  static const iconChoices = [
    IconChoice(Icons.code_rounded, AppPalette.green, false),
    IconChoice(Icons.storage_rounded, AppPalette.blue, false),
    IconChoice(Icons.desktop_mac_rounded, AppPalette.purple, false),
    IconChoice(Icons.public_rounded, AppPalette.yellow, true),
    IconChoice(Icons.construction_rounded, AppPalette.red, false),
    IconChoice(Icons.functions_rounded, AppPalette.green, false),
  ];
}

