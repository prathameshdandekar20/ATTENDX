import 'package:flutter/material.dart';
import 'subject.dart';

class TimetableEntry {
  const TimetableEntry({
    required this.subjectName,
    this.time = '',
    this.room = '',
  });

  final String subjectName;
  final String time;
  final String room;

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      subjectName: (json['subjectName'] as String?) ?? '',
      time: (json['time'] as String?) ?? '',
      room: (json['room'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'subjectName': subjectName,
        'time': time,
        'room': room,
      };
}

class ScheduleItem {
  const ScheduleItem({
    required this.subject,
    this.time = '',
    this.room = '',
    this.isExtra = false,
  });

  final Subject subject;
  final String time;
  final String room;
  final bool isExtra;
}

class CtSlice {
  const CtSlice({
    required this.label,
    required this.present,
    required this.total,
    required this.color,
  });

  final String label;
  final int present;
  final int total;
  final Color color;

  double get percent => total == 0 ? 0 : present / total;
}

class SemesterSnapshot {
  const SemesterSnapshot({
    required this.title,
    required this.attendance,
    required this.subjects,
    required this.classes,
    required this.isCurrent,
  });

  final String title;
  final double attendance;
  final int subjects;
  final int classes;
  final bool isCurrent;
}

class TimetableSlot {
  const TimetableSlot({
    required this.time,
    required this.subject,
    required this.room,
    required this.status,
    required this.icon,
    required this.color,
  });

  final String time;
  final String subject;
  final String room;
  final String status;
  final IconData icon;
  final Color color;
}
