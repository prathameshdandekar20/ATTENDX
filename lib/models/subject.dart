import 'package:flutter/material.dart';
import '../themes/palette.dart';

class Subject {
  const Subject({
    required this.name,
    required this.code,
    required this.faculty,
    required this.icon,
    required this.color,
    required this.present,
    required this.total,
    this.isLab = false,
    this.styleIndex = 0,
  });

  final String name;
  final String code;
  final String faculty;
  final IconData icon;
  final Color color;
  final int present;
  final int total;
  final bool isLab;
  final int styleIndex;

  factory Subject.blank(
    String name,
    int index, {
    String code = '',
    String faculty = '',
    bool isLab = false,
  }) {
    final icons = [
      Icons.code_rounded,
      Icons.storage_rounded,
      Icons.desktop_mac_rounded,
      Icons.public_rounded,
      Icons.calculate_rounded,
      Icons.science_rounded,
      Icons.menu_book_rounded,
      Icons.functions_rounded,
    ];
    final colors = [
      AppPalette.green,
      AppPalette.blue,
      AppPalette.purple,
      AppPalette.orange,
      AppPalette.yellow,
      AppPalette.mintStrong,
      AppPalette.greenDark,
      AppPalette.red,
    ];
    return Subject(
      name: name,
      code: code.isEmpty ? 'SUB-${index + 1}' : code,
      faculty: faculty,
      icon: icons[index % icons.length],
      color: colors[index % colors.length],
      present: 0,
      total: 0,
      isLab: isLab,
      styleIndex: index,
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    final index = (json['styleIndex'] as num?)?.toInt() ?? 0;
    var name = (json['name'] as String?) ?? 'Subject';
    final isLab = (json['isLab'] as bool?) ?? false;
    if (isLab && !name.toUpperCase().endsWith('(LAB)')) {
      name = '$name (LAB)';
    }
    return Subject.blank(
      name,
      index,
      code: (json['code'] as String?) ?? '',
      faculty: (json['faculty'] as String?) ?? '',
      isLab: isLab,
    ).copyWith(
      present: (json['present'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Subject copyWith({
    String? name,
    String? code,
    String? faculty,
    IconData? icon,
    Color? color,
    int? present,
    int? total,
    bool? isLab,
    int? styleIndex,
  }) {
    return Subject(
      name: name ?? this.name,
      code: code ?? this.code,
      faculty: faculty ?? this.faculty,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      present: present ?? this.present,
      total: total ?? this.total,
      isLab: isLab ?? this.isLab,
      styleIndex: styleIndex ?? this.styleIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'faculty': faculty,
        'present': present,
        'total': total,
        'isLab': isLab,
        'styleIndex': styleIndex,
      };

  double get percentage => total == 0 ? 100.0 : (present / total) * 100.0;

  Color get statusColor {
    if (percentage >= 75) return AppPalette.green;
    if (percentage >= 65) return AppPalette.yellow;
    return AppPalette.red;
  }

  String get statusLabel {
    if (percentage >= 75) return 'Safe';
    if (percentage >= 65) return 'Warning';
    return 'Danger';
  }

  int get canMiss {
    const min = 75.0;
    return canMissFor(min);
  }

  int canMissFor(double minimum) {
    if (minimum <= 0) return 999;
    final min = minimum / 100;
    var miss = 0;
    while (present / (total + miss + 1) >= min && miss < 500) {
      miss++;
    }
    return miss;
  }
}

int classesNeeded(int present, int total, double minimum) {
  if (total == 0 || minimum <= 0) return 0;
  final min = minimum / 100;
  var needed = 0;
  while ((present + needed) / (total + needed) < min && needed < 500) {
    needed++;
  }
  return needed;
}
