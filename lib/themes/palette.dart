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

  // Gold accent constants
  static const gold = Color(0xFFE5B842);
  static const goldGlow = Color(0xFFF59E0B);
  static const goldLight = Color(0xFFFDF4D4);
  static const obsidianBlack = Color(0xFF000000);
}

class AppThemePalette {
  final String id;
  final String displayName;
  final bool isDark;
  final List<Color> scaffoldGradient;
  final Color cardFill;
  final Color cardBorder;
  final Color cardShadow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentGlow;
  final Color accentSecondary;
  final Color navBackground;
  final Color navBorder;
  final Color navUnselected;
  final Color divider;

  const AppThemePalette({
    required this.id,
    required this.displayName,
    required this.isDark,
    required this.scaffoldGradient,
    required this.cardFill,
    required this.cardBorder,
    required this.cardShadow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentGlow,
    required this.accentSecondary,
    required this.navBackground,
    required this.navBorder,
    required this.navUnselected,
    required this.divider,
  });

  static const emeraldMint = AppThemePalette(
    id: 'emerald_mint',
    displayName: 'Emerald Mint',
    isDark: false,
    scaffoldGradient: [
      Color(0xFFE1F7EF),
      Color(0xFFF8FBF4),
      Color(0xFFF2F6DD),
    ],
    cardFill: Color(0xAEFFFFFF), // Colors.white.withValues(alpha: 0.68)
    cardBorder: Color(0xA3FFFFFF), // Colors.white.withValues(alpha: 0.64)
    cardShadow: Color(0x0F53751F),
    textPrimary: Color(0xFF101413),
    textSecondary: Color(0xFF6F7C78),
    textMuted: Color(0xFF9EABA6),
    accent: Color(0xFF7EAA31),
    accentGlow: Color(0xFFA9C34A),
    accentSecondary: Color(0xFF58AFCB),
    navBackground: Colors.white,
    navBorder: Color(0xFFFFFFFF),
    navUnselected: Color(0xFF6F7C78),
    divider: Color(0x66FFFFFF),
  );

  static const obsidianGold = AppThemePalette(
    id: 'obsidian_gold',
    displayName: 'Obsidian Gold',
    isDark: true,
    scaffoldGradient: [
      Color(0xFF000000),
      Color(0xFF0D0B07),
      Color(0xFF000000),
    ],
    cardFill: Color(0xD415120C), // Smoked obsidian glass
    cardBorder: Color(0x40E5B842), // 25% gold border
    cardShadow: Color(0x1AE5B842), // Subtle gold halo
    textPrimary: Color(0xFFFBF9F2),
    textSecondary: Color(0xFFB8AE98),
    textMuted: Color(0xFF756D5B),
    accent: Color(0xFFE5B842), // Champagne gold
    accentGlow: Color(0xFFF59E0B),
    accentSecondary: Color(0xFFFBBF24),
    navBackground: Color(0xFF0E0B07),
    navBorder: Color(0x38E5B842),
    navUnselected: Color(0xFF7A725F),
    divider: Color(0x28E5B842),
  );

  static AppThemePalette of(String themeId) {
    if (themeId == 'obsidian_gold') return obsidianGold;
    return emeraldMint;
  }
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

