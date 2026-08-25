import 'dart:convert';
import 'package:flutter/material.dart';
import '../local_store.dart';
import '../themes/palette.dart';
import 'subject.dart';
import 'attendance_log.dart';
import 'timetable_entry.dart';

class AttendXScope extends InheritedNotifier<AttendXModel> {
  const AttendXScope({
    super.key,
    required AttendXModel model,
    required super.child,
  }) : super(notifier: model);

  static AttendXModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AttendXScope>();
    assert(scope != null, 'AttendXScope not found');
    return scope!.notifier!;
  }
}

class SemesterData {
  List<Subject> subjects;
  List<AttendanceLog> logs;
  Map<String, List<TimetableEntry>> weeklyTimetable;
  Map<String, Map<String, String>> dailyRecords;
  Map<String, List<TimetableEntry>> extraLectures;
  String? ct1CompletedDate;
  int ct1SnapshotPresent;
  int ct1SnapshotTotal;
  String? ct2CompletedDate;
  int ct2SnapshotPresent;
  int ct2SnapshotTotal;

  SemesterData({
    List<Subject>? subjects,
    List<AttendanceLog>? logs,
    Map<String, List<TimetableEntry>>? weeklyTimetable,
    Map<String, Map<String, String>>? dailyRecords,
    Map<String, List<TimetableEntry>>? extraLectures,
    this.ct1CompletedDate,
    this.ct1SnapshotPresent = 0,
    this.ct1SnapshotTotal = 0,
    this.ct2CompletedDate,
    this.ct2SnapshotPresent = 0,
    this.ct2SnapshotTotal = 0,
  })  : subjects = subjects ?? [],
        logs = logs ?? [],
        weeklyTimetable = weeklyTimetable ?? {},
        dailyRecords = dailyRecords ?? {},
        extraLectures = extraLectures ?? {};

  SemesterData copy() {
    return SemesterData(
      subjects: subjects.map((s) => s.copyWith()).toList(),
      logs: logs.map((l) => AttendanceLog(date: l.date, note: l.note, present: l.present)).toList(),
      weeklyTimetable: weeklyTimetable.map(
        (day, entries) => MapEntry(day, entries.map((e) => TimetableEntry(subjectName: e.subjectName, time: e.time, room: e.room)).toList()),
      ),
      dailyRecords: dailyRecords.map(
        (date, records) => MapEntry(date, Map<String, String>.from(records)),
      ),
      extraLectures: extraLectures.map(
        (date, entries) => MapEntry(date, entries.map((e) => TimetableEntry(subjectName: e.subjectName, time: e.time, room: e.room)).toList()),
      ),
      ct1CompletedDate: ct1CompletedDate,
      ct1SnapshotPresent: ct1SnapshotPresent,
      ct1SnapshotTotal: ct1SnapshotTotal,
      ct2CompletedDate: ct2CompletedDate,
      ct2SnapshotPresent: ct2SnapshotPresent,
      ct2SnapshotTotal: ct2SnapshotTotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'logs': logs.map((l) => l.toJson()).toList(),
      'weeklyTimetable': weeklyTimetable.map(
        (day, entries) => MapEntry(day, entries.map((e) => e.toJson()).toList()),
      ),
      'dailyRecords': dailyRecords,
      'extraLectures': extraLectures.map(
        (date, entries) => MapEntry(date, entries.map((e) => e.toJson()).toList()),
      ),
      'ct1CompletedDate': ct1CompletedDate,
      'ct1SnapshotPresent': ct1SnapshotPresent,
      'ct1SnapshotTotal': ct1SnapshotTotal,
      'ct2CompletedDate': ct2CompletedDate,
      'ct2SnapshotPresent': ct2SnapshotPresent,
      'ct2SnapshotTotal': ct2SnapshotTotal,
    };
  }

  factory SemesterData.fromJson(Map<String, dynamic> data, String Function(String) normalizeDateKey) {
    final subjects = ((data['subjects'] as List?) ?? [])
        .whereType<Map>()
        .map((item) => Subject.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final logs = ((data['logs'] as List?) ?? [])
        .whereType<Map>()
        .map((item) => AttendanceLog.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final weeklyTimetable = <String, List<TimetableEntry>>{};
    final ttRaw = data['weeklyTimetable'] as Map<String, dynamic>?;
    if (ttRaw != null) {
      ttRaw.forEach((day, entriesRaw) {
        if (entriesRaw is List) {
          weeklyTimetable[day] = entriesRaw
              .whereType<Map>()
              .map((e) => TimetableEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      });
    }

    final dailyRecords = <String, Map<String, String>>{};
    final drRaw = data['dailyRecords'] as Map<String, dynamic>?;
    if (drRaw != null) {
      drRaw.forEach((dateStr, recordsRaw) {
        if (recordsRaw is Map) {
          final records = Map<String, dynamic>.from(recordsRaw)
              .map((k, v) => MapEntry(k.toString(), v.toString()));
          final normalizedKey = normalizeDateKey(dateStr);
          dailyRecords[normalizedKey] = records;
        }
      });
    }

    final extraLectures = <String, List<TimetableEntry>>{};
    final extraRaw = data['extraLectures'] as Map<String, dynamic>?;
    if (extraRaw != null) {
      extraRaw.forEach((dateStr, entriesRaw) {
        if (entriesRaw is List) {
          final entries = entriesRaw
              .whereType<Map>()
              .map((e) => TimetableEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          final normalizedKey = normalizeDateKey(dateStr);
          extraLectures[normalizedKey] = entries;
        }
      });
    }

    return SemesterData(
      subjects: subjects,
      logs: logs,
      weeklyTimetable: weeklyTimetable,
      dailyRecords: dailyRecords,
      extraLectures: extraLectures,
      ct1CompletedDate: data['ct1CompletedDate'] as String?,
      ct1SnapshotPresent: (data['ct1SnapshotPresent'] as num?)?.toInt() ?? 0,
      ct1SnapshotTotal: (data['ct1SnapshotTotal'] as num?)?.toInt() ?? 0,
      ct2CompletedDate: data['ct2CompletedDate'] as String?,
      ct2SnapshotPresent: (data['ct2SnapshotPresent'] as num?)?.toInt() ?? 0,
      ct2SnapshotTotal: (data['ct2SnapshotTotal'] as num?)?.toInt() ?? 0,
    );
  }
}

class AttendXModel extends ChangeNotifier {
  AttendXModel.blank();

  static Future<AttendXModel> load() async {
    final raw = await AttendXLocalStore.read();
    if (raw == null || raw.trim().isEmpty) return AttendXModel.blank();
    try {
      return AttendXModel.blank().._restoreFromJson(raw);
    } catch (_) {
      return AttendXModel.blank();
    }
  }

  String studentName = '';
  int currentSemester = 1;
  double minimumAttendance = 75;
  List<Subject> subjects = [];
  List<AttendanceLog> logs = [];
  /// Weekly timetable: key is weekday name (e.g. 'Monday'), value is list of entries
  Map<String, List<TimetableEntry>> weeklyTimetable = {};
  /// Daily records: key is dateKey (YYYY-MM-DD), value is map of subject name to action
  Map<String, Map<String, String>> dailyRecords = {};
  /// Extra lectures for specific dates: key is dateKey (YYYY-MM-DD), value is list of TimetableEntry
  Map<String, List<TimetableEntry>> extraLectures = {};

  // ---------- CT Tracking ----------
  String? ct1CompletedDate; // dateKey when CT1 was marked completed
  int ct1SnapshotPresent = 0; // attended classes at CT1 completion
  int ct1SnapshotTotal = 0;   // total classes at CT1 completion
  String? ct2CompletedDate;
  int ct2SnapshotPresent = 0;
  int ct2SnapshotTotal = 0;

  /// Multi-semester archive: stores data for each semester (1 to 8)
  Map<int, SemesterData> semestersData = {};

  void _syncCurrentSemesterToMap() {
    semestersData[currentSemester] = SemesterData(
      subjects: List.from(subjects),
      logs: List.from(logs),
      weeklyTimetable: Map.from(weeklyTimetable),
      dailyRecords: Map.from(dailyRecords),
      extraLectures: Map.from(extraLectures),
      ct1CompletedDate: ct1CompletedDate,
      ct1SnapshotPresent: ct1SnapshotPresent,
      ct1SnapshotTotal: ct1SnapshotTotal,
      ct2CompletedDate: ct2CompletedDate,
      ct2SnapshotPresent: ct2SnapshotPresent,
      ct2SnapshotTotal: ct2SnapshotTotal,
    );
  }

  void _loadSemesterFromMap(int semester) {
    currentSemester = semester;
    final semData = semestersData[semester];
    if (semData != null) {
      subjects = List.from(semData.subjects);
      logs = List.from(semData.logs);
      weeklyTimetable = Map.from(semData.weeklyTimetable);
      dailyRecords = Map.from(semData.dailyRecords);
      extraLectures = Map.from(semData.extraLectures);
      ct1CompletedDate = semData.ct1CompletedDate;
      ct1SnapshotPresent = semData.ct1SnapshotPresent;
      ct1SnapshotTotal = semData.ct1SnapshotTotal;
      ct2CompletedDate = semData.ct2CompletedDate;
      ct2SnapshotPresent = semData.ct2SnapshotPresent;
      ct2SnapshotTotal = semData.ct2SnapshotTotal;
    } else {
      subjects = [];
      logs = [];
      weeklyTimetable = {};
      dailyRecords = {};
      extraLectures = {};
      ct1CompletedDate = null;
      ct1SnapshotPresent = 0;
      ct1SnapshotTotal = 0;
      ct2CompletedDate = null;
      ct2SnapshotPresent = 0;
      ct2SnapshotTotal = 0;
    }
  }

  String dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String normalizeDateKey(String input) {
    try {
      final dt = DateTime.parse(input);
      return dateKey(dt);
    } catch (_) {
      try {
        final parts = input.split(RegExp(r'[^0-9]'));
        if (parts.length >= 3) {
          if (parts[0].length <= 2 && parts[2].length == 4) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            return dateKey(DateTime(year, month, day));
          }
          if (parts[0].length == 4 && parts[2].length <= 2) {
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final day = int.parse(parts[2]);
            return dateKey(DateTime(year, month, day));
          }
        }
      } catch (_) {}
    }
    return input.trim();
  }

  String? getActionForDate(Subject subject, DateTime date) {
    final key = dateKey(date);
    return dailyRecords[key]?[subject.name];
  }

  bool get isSetup => studentName.trim().isNotEmpty;
  String get firstName => studentName.trim().split(RegExp(r'\s+')).first;
  DateTime get today => DateTime.now();
  int get totalClasses => subjects.where((s) => !s.isLab).fold(0, (sum, subject) => sum + subject.total);
  int get attendedClasses =>
      subjects.where((s) => !s.isLab).fold(0, (sum, subject) => sum + subject.present);
  int get missedClasses => totalClasses - attendedClasses;
  double get overallAttendance =>
      totalClasses == 0 ? 0 : (attendedClasses / totalClasses) * 100;

  int get labAttendedClasses => subjects.where((s) => s.isLab).fold(0, (sum, subject) => sum + subject.present);
  int get labTotalClasses => subjects.where((s) => s.isLab).fold(0, (sum, subject) => sum + subject.total);
  int get combinedAttendedClasses => attendedClasses + labAttendedClasses;
  int get combinedTotalClasses => totalClasses + labTotalClasses;
  double get combinedOverallAttendance => combinedTotalClasses == 0 ? 0 : (combinedAttendedClasses / combinedTotalClasses) * 100;

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  String normalizeDayName(String dayName) {
    final trimmed = dayName.trim();
    for (final d in _dayNames) {
      if (d.toLowerCase() == trimmed.toLowerCase()) return d;
    }
    return trimmed;
  }

  String dayNameForDate(DateTime date) => _dayNames[date.weekday - 1];
  String get todayDayName => dayNameForDate(today);

  List<ScheduleItem> get todaySchedule {
    return scheduleForDate(today);
  }

  List<ScheduleItem> scheduleForDay(String dayName) {
    final normalized = normalizeDayName(dayName);
    final entries = weeklyTimetable[normalized] ?? [];
    if (entries.isEmpty) return [];
    return entries.map((entry) {
      final subject = subjects.firstWhere(
        (s) => s.name == entry.subjectName,
        orElse: () => Subject.blank(entry.subjectName, 0),
      );
      return ScheduleItem(
        subject: subject,
        time: entry.time,
        room: entry.room,
        isExtra: false,
      );
    }).toList();
  }

  List<ScheduleItem> scheduleForDate(DateTime date) {
    final dayName = dayNameForDate(date);
    final regular = scheduleForDay(dayName);
    final key = dateKey(date);
    final extras = (extraLectures[key] ?? []).map((entry) {
      final subject = subjects.firstWhere(
        (s) => s.name == entry.subjectName,
        orElse: () => Subject.blank(entry.subjectName, 0),
      );
      return ScheduleItem(
        subject: subject,
        time: entry.time,
        room: entry.room,
        isExtra: true,
      );
    }).toList();

    return [...regular, ...extras];
  }

  void addExtraLecture({
    required DateTime date,
    required Subject subject,
    String? initialStatus,
  }) {
    final key = dateKey(date);
    extraLectures[key] ??= [];
    extraLectures[key]!.add(
      TimetableEntry(
        subjectName: subject.name,
      ),
    );

    if (initialStatus != null && initialStatus.isNotEmpty && initialStatus != 'clear') {
      final pDelta = initialStatus == 'present' ? 1 : 0;
      final tDelta = (initialStatus == 'present' || initialStatus == 'absent') ? 1 : 0;
      adjustAttendance(
        subject,
        presentDelta: pDelta,
        totalDelta: tDelta,
        action: initialStatus,
        date: date,
        logNote: '${subject.name} (Extra Lecture) marked $initialStatus',
        logPresent: initialStatus == 'present',
      );
    } else {
      _save();
      notifyListeners();
    }
  }

  void removeExtraLecture({
    required DateTime date,
    required Subject subject,
  }) {
    final key = dateKey(date);
    if (extraLectures[key] != null) {
      final index = extraLectures[key]!.indexWhere((e) => e.subjectName == subject.name);
      if (index != -1) {
        extraLectures[key]!.removeAt(index);
        if (extraLectures[key]!.isEmpty) {
          extraLectures.remove(key);
        }

        final currentAction = getActionForDate(subject, date);
        if (currentAction != null) {
          int pDelta = 0;
          int tDelta = 0;
          if (currentAction == 'present') {
            pDelta = -1;
            tDelta = -1;
          } else if (currentAction == 'absent') {
            tDelta = -1;
          }
          adjustAttendance(
            subject,
            presentDelta: pDelta,
            totalDelta: tDelta,
            action: 'clear',
            date: date,
            logNote: '${subject.name} (Extra Lecture) removed',
            logPresent: false,
          );
          return;
        }
        _save();
        notifyListeners();
      }
    }
  }

  Color getDayColor(DateTime date) {
    final schedule = scheduleForDate(date);
    if (schedule.isEmpty) return Colors.transparent;

    final key = dateKey(date);
    final records = dailyRecords[key] ?? {};
    final scheduledKeys = schedule.map((item) => item.subject.name).toSet();

    if (scheduledKeys.isNotEmpty) {
      final relevantRecords = records.entries.where((e) => scheduledKeys.contains(e.key)).toList();
      if (relevantRecords.length == scheduledKeys.length) {
        if (relevantRecords.every((e) => e.value == 'present')) {
          return AppPalette.green;
        } else if (relevantRecords.every((e) => e.value == 'absent')) {
          return AppPalette.red;
        } else if (relevantRecords.every((e) => e.value == 'off')) {
          return AppPalette.yellow;
        } else {
          return AppPalette.purple;
        }
      }
    }
    return AppPalette.slate.withValues(alpha: 0.2); // Not marked
  }

  int get currentStreak {
    int streak = 0;
    DateTime checkDate = today;

    for (int i = 0; i < 365; i++) {
      final key = dateKey(checkDate);
      final records = dailyRecords[key];
      final schedule = scheduleForDate(checkDate);

      if (schedule.isEmpty && (records == null || records.isEmpty)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }

      if (records == null || records.isEmpty) {
        if (i == 0) {
          // Today might not be marked yet
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }

      final hasAbsent = records.values.any((v) => v == 'absent');
      final hasPresent = records.values.any((v) => v == 'present');

      if (hasPresent && !hasAbsent) {
        streak++;
      } else {
        break;
      }
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<SemesterSnapshot> get semesterSnapshots {
    _syncCurrentSemesterToMap();
    return List.generate(8, (index) {
      final semester = index + 1;
      if (semester == currentSemester) {
        return SemesterSnapshot(
          title: 'Semester $semester',
          attendance: overallAttendance,
          subjects: subjects.length,
          classes: totalClasses,
          isCurrent: true,
        );
      }
      final semData = semestersData[semester];
      if (semData != null && semData.subjects.isNotEmpty) {
        final total = semData.subjects.where((s) => !s.isLab).fold(0, (sum, s) => sum + s.total);
        final present = semData.subjects.where((s) => !s.isLab).fold(0, (sum, s) => sum + s.present);
        final att = total == 0 ? 0.0 : (present / total) * 100;
        return SemesterSnapshot(
          title: 'Semester $semester',
          attendance: att,
          subjects: semData.subjects.length,
          classes: total,
          isCurrent: false,
        );
      }
      return SemesterSnapshot(
        title: 'Semester $semester',
        attendance: 0,
        subjects: 0,
        classes: 0,
        isCurrent: false,
      );
    });
  }

  List<TimetableSlot> get weeklySlots {
    return todaySchedule.map((item) {
      return TimetableSlot(
        time: item.time.isEmpty ? '' : item.time.split(' - ').first,
        subject: item.subject.name,
        room: item.room,
        status: item.subject.total == 0 ? 'New' : 'Ready',
        icon: item.subject.icon,
        color: item.subject.color,
      );
    }).toList();
  }

  List<CtSlice> get ctSlices {
    final overallPercent = totalClasses == 0 ? 0.0 : attendedClasses / totalClasses;
    final slices = <CtSlice>[
      CtSlice(
        label: 'Overall',
        present: attendedClasses,
        total: totalClasses,
        color: overallPercent * 100 >= minimumAttendance ? AppPalette.green : AppPalette.red,
      ),
    ];

    if (ct1CompletedDate != null) {
      DateTime dt1;
      try {
        dt1 = DateTime.parse(ct1CompletedDate!);
      } catch (_) {
        dt1 = today;
      }

      final beforeCt1 = calculateSnapshotAt(dt1);
      final beforeCt1Present = beforeCt1['present']!;
      final beforeCt1Total = beforeCt1['total']!;

      final afterCt1Present = (attendedClasses - beforeCt1Present).clamp(0, attendedClasses);
      final afterCt1Total = (totalClasses - beforeCt1Total).clamp(0, totalClasses);
      final afterCt1Pct = afterCt1Total == 0 ? 0.0 : afterCt1Present / afterCt1Total;

      slices.add(CtSlice(
        label: 'After CT1',
        present: afterCt1Present,
        total: afterCt1Total,
        color: afterCt1Pct * 100 >= minimumAttendance ? AppPalette.green : AppPalette.red,
      ));
    }

    return slices;
  }

  Map<String, int> calculateSnapshotAt(DateTime date) {
    final key = dateKey(date);

    int dailyPresentSum = 0;
    int dailyTotalSum = 0;
    int dailyPresentBeforeDate = 0;
    int dailyTotalBeforeDate = 0;

    for (final entry in dailyRecords.entries) {
      final isBeforeOrOn = entry.key.compareTo(key) <= 0;
      for (final subject in subjects) {
        if (subject.isLab) continue;
        final status = entry.value[subject.name];
        if (status == 'present') {
          dailyPresentSum++;
          dailyTotalSum++;
          if (isBeforeOrOn) {
            dailyPresentBeforeDate++;
            dailyTotalBeforeDate++;
          }
        } else if (status == 'absent') {
          dailyTotalSum++;
          if (isBeforeOrOn) {
            dailyTotalBeforeDate++;
          }
        }
      }
    }

    final basePresent = (attendedClasses - dailyPresentSum).clamp(0, attendedClasses);
    final baseTotal = (totalClasses - dailyTotalSum).clamp(0, totalClasses);

    final present = (dailyPresentBeforeDate + basePresent).clamp(0, attendedClasses);
    final total = (dailyTotalBeforeDate + baseTotal).clamp(0, totalClasses);

    return {
      'present': present,
      'total': total,
    };
  }

  void completeCT1At(DateTime date) {
    final key = dateKey(date);
    ct1CompletedDate = key;

    final snapshot = calculateSnapshotAt(date);
    ct1SnapshotPresent = snapshot['present']!;
    ct1SnapshotTotal = snapshot['total']!;

    _save();
    notifyListeners();
  }

  void completeCT1() {
    completeCT1At(today);
  }

  void undoCT1() {
    ct1CompletedDate = null;
    ct1SnapshotPresent = 0;
    ct1SnapshotTotal = 0;
    ct2CompletedDate = null;
    ct2SnapshotPresent = 0;
    ct2SnapshotTotal = 0;
    _save();
    notifyListeners();
  }

  void completeCT2At(DateTime date) {
    if (ct1CompletedDate == null) return; // CT1 must be completed first
    ct2CompletedDate = dateKey(date);
    final snapshot = calculateSnapshotAt(date);
    ct2SnapshotPresent = snapshot['present']!;
    ct2SnapshotTotal = snapshot['total']!;
    _save();
    notifyListeners();
  }

  void completeCT2() {
    completeCT2At(today);
  }

  void undoCT2() {
    ct2CompletedDate = null;
    ct2SnapshotPresent = 0;
    ct2SnapshotTotal = 0;
    _save();
    notifyListeners();
  }

  void resetCTTracking() {
    ct1CompletedDate = null;
    ct1SnapshotPresent = 0;
    ct1SnapshotTotal = 0;
    ct2CompletedDate = null;
    ct2SnapshotPresent = 0;
    ct2SnapshotTotal = 0;
    _save();
    notifyListeners();
  }

  void completeReset() {
    studentName = '';
    currentSemester = 1;
    minimumAttendance = 75;
    subjects = [];
    logs.clear();
    weeklyTimetable.clear();
    dailyRecords.clear();
    extraLectures.clear();
    ct1CompletedDate = null;
    ct1SnapshotPresent = 0;
    ct1SnapshotTotal = 0;
    ct2CompletedDate = null;
    ct2SnapshotPresent = 0;
    ct2SnapshotTotal = 0;
    semestersData.clear();
    _save();
    notifyListeners();
  }

  void resetAttendance() {
    subjects = subjects.map((s) => s.copyWith(present: 0, total: 0)).toList();
    logs.clear();
    dailyRecords.clear();
    extraLectures.clear();
    ct1CompletedDate = null;
    ct1SnapshotPresent = 0;
    ct1SnapshotTotal = 0;
    ct2CompletedDate = null;
    ct2SnapshotPresent = 0;
    ct2SnapshotTotal = 0;
    _syncCurrentSemesterToMap();
    _save();
    notifyListeners();
  }

  void resetSchedule() {
    weeklyTimetable.clear();
    extraLectures.clear();
    _syncCurrentSemesterToMap();
    _save();
    notifyListeners();
  }

  void completeSetup({
    required String name,
    required int semester,
    required double minimum,
    required List<String> subjectNames,
  }) {
    studentName = name.trim();
    currentSemester = semester;
    minimumAttendance = minimum;
    subjects = subjectNames.asMap().entries.map((entry) {
      return Subject.blank(entry.value.trim(), entry.key);
    }).toList();
    logs.clear();
    weeklyTimetable.clear();
    dailyRecords.clear();
    extraLectures.clear();
    ct1CompletedDate = null;
    ct1SnapshotPresent = 0;
    ct1SnapshotTotal = 0;
    ct2CompletedDate = null;
    ct2SnapshotPresent = 0;
    ct2SnapshotTotal = 0;
    semestersData.clear();
    _syncCurrentSemesterToMap();
    _save();
    notifyListeners();
  }

  void addSubject({
    required String name,
    required String code,
    String faculty = '',
    bool isLab = false,
    IconData? icon,
    Color? color,
  }) {
    String finalName = name.trim();
    if (isLab && !finalName.toUpperCase().endsWith('(LAB)')) {
      finalName = '$finalName (LAB)';
    }

    final blank = Subject.blank(
      finalName,
      subjects.length,
      code: code.trim(),
      faculty: faculty.trim(),
      isLab: isLab,
    );

    subjects = [
      ...subjects,
      blank.copyWith(
        icon: icon ?? blank.icon,
        color: color ?? blank.color,
      ),
    ];
    _save();
    notifyListeners();
  }

  void updateSubject(Subject oldSubject, Subject newSubject) {
    subjects = subjects.map((s) {
      if (s.name == oldSubject.name && s.isLab == oldSubject.isLab && s.code == oldSubject.code) {
        String finalName = newSubject.name.trim();
        if (newSubject.isLab && !finalName.toUpperCase().endsWith('(LAB)')) {
          finalName = '$finalName (LAB)';
        }
        return newSubject.copyWith(name: finalName);
      }
      return s;
    }).toList();
    _save();
    notifyListeners();
  }

  void deleteSubject(Subject subject) {
    subjects = subjects
        .where((item) => item.name != subject.name || item.isLab != subject.isLab || item.code != subject.code)
        .toList();
    _save();
    notifyListeners();
  }

  void setSemester(int semester) {
    if (currentSemester == semester) return;
    _syncCurrentSemesterToMap();
    _loadSemesterFromMap(semester);
    _syncCurrentSemesterToMap();
    _save();
    notifyListeners();
  }

  void setMinimumAttendance(double value) {
    minimumAttendance = value.clamp(0, 100);
    _save();
    notifyListeners();
  }

  void markAttendance(Subject subject, bool present, {DateTime? date}) {
    adjustAttendance(
      subject,
      presentDelta: present ? 1 : 0,
      totalDelta: 1,
      action: present ? 'present' : 'absent',
      date: date,
      logNote: '${subject.name} marked ${present ? 'present' : 'absent'}',
      logPresent: present,
    );
  }

  void adjustAttendance(
    Subject subject, {
    required int presentDelta,
    required int totalDelta,
    required String action,
    DateTime? date,
    String? logNote,
    bool? logPresent,
  }) {
    final markDate = date ?? today;
    subjects = subjects.map((item) {
      if (item.name != subject.name || item.isLab != subject.isLab || item.code != subject.code) return item;
      return item.copyWith(
        present: (item.present + presentDelta).clamp(0, 999999),
        total: (item.total + totalDelta).clamp(0, 999999),
      );
    }).toList();

    // Update daily records
    final key = dateKey(markDate);
    final subjectKey = subject.name;
    dailyRecords[key] ??= {};
    if (action.isEmpty || action == 'clear') {
      dailyRecords[key]!.remove(subjectKey);
    } else {
      dailyRecords[key]![subjectKey] = action;
    }

    if (logNote != null) {
      logs.insert(
        0,
        AttendanceLog(
          date: fullDate(markDate),
          note: logNote,
          present: logPresent ?? false,
        ),
      );
    }
    _save();
    notifyListeners();
  }

  void markAllAttendance(String action, DateTime date, {List<ScheduleItem>? targetItems}) {
    final markDate = date;
    final key = dateKey(markDate);
    dailyRecords[key] ??= {};

    // If targetItems is null, apply to all subjects
    final items = targetItems ?? subjects.map((s) => ScheduleItem(subject: s, time: '', room: '')).toList();

    for (var item in items) {
      final subject = item.subject;
      final subjectKey = subject.name;
      final currentAction = dailyRecords[key]?[subjectKey];
      if (currentAction == action) continue; // Already marked correctly

      int pDelta = 0;
      int tDelta = 0;

      // Undo current action
      if (currentAction == 'present') { pDelta -= 1; tDelta -= 1; }
      else if (currentAction == 'absent') { tDelta -= 1; }

      // Apply new action
      if (action == 'present') { pDelta += 1; tDelta += 1; }
      else if (action == 'absent') { tDelta += 1; }

      // Update counters
      subjects = subjects.map((s) {
        if (s.name != subject.name || s.isLab != subject.isLab || s.code != subject.code) return s;
        return s.copyWith(
          present: s.present + pDelta,
          total: s.total + tDelta,
        );
      }).toList();

      if (action.isEmpty || action == 'clear') {
        dailyRecords[key]!.remove(subjectKey);
      } else {
        dailyRecords[key]![subjectKey] = action;
      }
    }

    // Add single log for master action
    String? logNote;
    bool? logPresent;
    if (action == 'present') {
      logNote = 'All subjects marked present';
      logPresent = true;
    } else if (action == 'absent') {
      logNote = 'All subjects marked absent';
      logPresent = false;
    } else if (action == 'off') {
      logNote = 'All classes cancelled';
      logPresent = false;
    }

    if (logNote != null) {
      logs.insert(
        0,
        AttendanceLog(
          date: fullDate(markDate),
          note: logNote,
          present: logPresent ?? false,
        ),
      );
    }

    _save();
    notifyListeners();
  }

  // ---------- Weekly Timetable ----------

  void setTimetableForDay(String dayName, List<TimetableEntry> entries) {
    final normalized = normalizeDayName(dayName);
    weeklyTimetable[normalized] = entries;
    _save();
    notifyListeners();
  }

  void addTimetableEntry(String dayName, TimetableEntry entry) {
    final normalized = normalizeDayName(dayName);
    final current = weeklyTimetable[normalized] ?? [];
    weeklyTimetable[normalized] = [...current, entry];
    _save();
    notifyListeners();
  }

  void removeTimetableEntry(String dayName, int index) {
    final normalized = normalizeDayName(dayName);
    final current = weeklyTimetable[normalized] ?? [];
    if (index >= 0 && index < current.length) {
      weeklyTimetable[normalized] = [...current]..removeAt(index);
      _save();
      notifyListeners();
    }
  }

  void removeTimetableItem(String dayName, TimetableEntry entry) {
    final normalized = normalizeDayName(dayName);
    final current = weeklyTimetable[normalized] ?? [];
    weeklyTimetable[normalized] = current.where((e) =>
      e.subjectName != entry.subjectName ||
      e.time != entry.time ||
      e.room != entry.room
    ).toList();
    _save();
    notifyListeners();
  }

  // ---------- JSON Export / Import ----------

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(_toMap());
  }

  bool importFromJsonString(String jsonStr) {
    try {
      _restoreFromJson(jsonStr);
      _save();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void applyModel(AttendXModel other) {
    studentName = other.studentName;
    currentSemester = other.currentSemester;
    minimumAttendance = other.minimumAttendance;
    subjects = other.subjects;
    logs = other.logs;
    weeklyTimetable = other.weeklyTimetable;
    dailyRecords = other.dailyRecords;
    extraLectures = other.extraLectures;
    ct1CompletedDate = other.ct1CompletedDate;
    ct1SnapshotPresent = other.ct1SnapshotPresent;
    ct1SnapshotTotal = other.ct1SnapshotTotal;
    ct2CompletedDate = other.ct2CompletedDate;
    ct2SnapshotPresent = other.ct2SnapshotPresent;
    ct2SnapshotTotal = other.ct2SnapshotTotal;
    semestersData = {
      for (final e in other.semestersData.entries) e.key: e.value.copy(),
    };
    _syncCurrentSemesterToMap();
    _save();
    notifyListeners();
  }

  Map<String, dynamic> _toMap() {
    _syncCurrentSemesterToMap();
    return {
      'studentName': studentName,
      'currentSemester': currentSemester,
      'minimumAttendance': minimumAttendance,
      // Backward compatibility top-level fields for current semester:
      'subjects': subjects.map((s) => s.toJson()).toList(),
      'logs': logs.map((l) => l.toJson()).toList(),
      'weeklyTimetable': weeklyTimetable.map(
        (day, entries) => MapEntry(day, entries.map((e) => e.toJson()).toList()),
      ),
      'dailyRecords': dailyRecords,
      'extraLectures': extraLectures.map(
        (date, entries) => MapEntry(date, entries.map((e) => e.toJson()).toList()),
      ),
      'ct1CompletedDate': ct1CompletedDate,
      'ct1SnapshotPresent': ct1SnapshotPresent,
      'ct1SnapshotTotal': ct1SnapshotTotal,
      'ct2CompletedDate': ct2CompletedDate,
      'ct2SnapshotPresent': ct2SnapshotPresent,
      'ct2SnapshotTotal': ct2SnapshotTotal,
      // All semesters map:
      'semesters': semestersData.map((k, v) => MapEntry(k.toString(), v.toJson())),
    };
  }

  void _restoreFromJson(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    studentName = (data['studentName'] as String?) ?? '';
    currentSemester = (data['currentSemester'] as num?)?.toInt() ?? 1;
    minimumAttendance =
        (data['minimumAttendance'] as num?)?.toDouble() ?? 75;

    semestersData.clear();
    final semRaw = data['semesters'] as Map<String, dynamic>?;
    if (semRaw != null && semRaw.isNotEmpty) {
      semRaw.forEach((semKey, semMap) {
        final semNum = int.tryParse(semKey);
        if (semNum != null && semMap is Map<String, dynamic>) {
          semestersData[semNum] = SemesterData.fromJson(semMap, normalizeDateKey);
        }
      });
    }

    if (semestersData.containsKey(currentSemester)) {
      _loadSemesterFromMap(currentSemester);
    } else {
      // Legacy JSON fallback
      subjects = ((data['subjects'] as List?) ?? [])
          .whereType<Map>()
          .map((item) => Subject.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      logs = ((data['logs'] as List?) ?? [])
          .whereType<Map>()
          .map((item) => AttendanceLog.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      final ttRaw = data['weeklyTimetable'] as Map<String, dynamic>?;
      weeklyTimetable = {};
      if (ttRaw != null) {
        weeklyTimetable = ttRaw.map((day, entriesRaw) {
          final entries = (entriesRaw as List)
              .whereType<Map>()
              .map((e) => TimetableEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          return MapEntry(day, entries);
        });
      }
      final drRaw = data['dailyRecords'] as Map<String, dynamic>?;
      dailyRecords = {};
      if (drRaw != null) {
        dailyRecords = drRaw.map((dateStr, recordsRaw) {
          final records = Map<String, dynamic>.from(recordsRaw as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
          final normalizedKey = normalizeDateKey(dateStr);
          return MapEntry(normalizedKey, records);
        });
      }
      final extraRaw = data['extraLectures'] as Map<String, dynamic>?;
      extraLectures = {};
      if (extraRaw != null) {
        extraLectures = extraRaw.map((dateStr, entriesRaw) {
          final entries = (entriesRaw as List)
              .whereType<Map>()
              .map((e) => TimetableEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          final normalizedKey = normalizeDateKey(dateStr);
          return MapEntry(normalizedKey, entries);
        });
      }
      ct1CompletedDate = data['ct1CompletedDate'] as String?;
      ct1SnapshotPresent = (data['ct1SnapshotPresent'] as num?)?.toInt() ?? 0;
      ct1SnapshotTotal = (data['ct1SnapshotTotal'] as num?)?.toInt() ?? 0;
      ct2CompletedDate = data['ct2CompletedDate'] as String?;
      ct2SnapshotPresent = (data['ct2SnapshotPresent'] as num?)?.toInt() ?? 0;
      ct2SnapshotTotal = (data['ct2SnapshotTotal'] as num?)?.toInt() ?? 0;

      _syncCurrentSemesterToMap();
    }
  }

  void _save() {
    _syncCurrentSemesterToMap();
    AttendXLocalStore.write(jsonEncode(_toMap()));
  }
}

// Helpers that were in main.dart
String greetingFor(DateTime time) {
  final hour = time.hour;
  if (hour < 5) return 'Good Night';
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  if (hour < 21) return 'Good Evening';
  return 'Good Night';
}

String shortDate(DateTime date) => '${date.day} ${_monthName(date.month)}';

String fullDate(DateTime date) =>
    '${date.day} ${_monthName(date.month)} ${date.year}';

String _monthName(int month) {
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return names[month - 1];
}
