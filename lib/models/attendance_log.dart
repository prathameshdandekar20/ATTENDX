class AttendanceLog {
  const AttendanceLog({
    required this.date,
    required this.note,
    required this.present,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      date: (json['date'] as String?) ?? '',
      note: (json['note'] as String?) ?? '',
      present: (json['present'] as bool?) ?? false,
    );
  }

  final String date;
  final String note;
  final bool present;

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'note': note,
      'present': present,
    };
  }
}

class BackupItem {
  const BackupItem(this.name, this.date, this.size);
  final String name;
  final String date;
  final String size;
}
