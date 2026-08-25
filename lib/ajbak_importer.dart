import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models/attendx_model.dart';
import 'models/subject.dart';
import 'models/timetable_entry.dart';
import 'themes/palette.dart';


class AjbakImporter {
  static const _sqliteHeader = 'SQLite format 3\x00';

  static Future<AttendXModel?> importBackup() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final bytes = await file.readAsBytes();

    final tempDir = await getTemporaryDirectory();
    final workDir = Directory(
        p.join(tempDir.path, 'ajbak_${DateTime.now().millisecondsSinceEpoch}'));
    await workDir.create(recursive: true);

    try {
      String? dbPath;

      // Strategy 1: ZIP archive
      dbPath = await _tryZip(bytes, workDir);

      // Strategy 2: GZIP compressed (maybe gzipped SQLite or gzipped tar)
      dbPath ??= await _tryGzip(bytes, workDir);

      // Strategy 3: TAR archive (uncompressed)
      dbPath ??= await _tryTar(bytes, workDir);

      // Strategy 4: Raw SQLite database
      dbPath ??= await _tryRawSqlite(bytes, workDir);

      // Strategy 5: Binary scan for embedded SQLite
      dbPath ??= await _tryEmbeddedSqlite(bytes, workDir);


      if (dbPath == null) {
        // Show first 16 bytes as hex for debugging
        final preview = bytes.length >= 16
            ? bytes.sublist(0, 16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')
            : 'file too small';
        final ascii = bytes.length >= 16
            ? String.fromCharCodes(bytes.sublist(0, 16).map((b) => (b >= 32 && b < 127) ? b : 46))
            : '';
        throw Exception(
            'Unsupported backup format.\n'
            'File size: ${bytes.length} bytes\n'
            'Header: $preview\n'
            'ASCII: $ascii');
      }

      return await _readDatabase(dbPath);
    } finally {
      try {
        await workDir.delete(recursive: true);
      } catch (_) {}
    }
  }

  // ── ZIP (PK\x03\x04) ──
  static Future<String?> _tryZip(Uint8List bytes, Directory dir) async {
    if (bytes.length < 4 || bytes[0] != 0x50 || bytes[1] != 0x4B) return null;
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      return await _extractArchive(archive, dir);
    } catch (_) {
      return null;
    }
  }

  // ── GZIP (0x1F 0x8B) ──
  static Future<String?> _tryGzip(Uint8List bytes, Directory dir) async {
    if (bytes.length < 2 || bytes[0] != 0x1F || bytes[1] != 0x8B) return null;
    try {
      final decompressed = GZipDecoder().decodeBytes(bytes);
      final decompressedBytes = Uint8List.fromList(decompressed);

      // Check if decompressed content is a SQLite DB
      if (decompressedBytes.length >= 16 &&
          String.fromCharCodes(decompressedBytes.sublist(0, 16)) == _sqliteHeader) {
        final dbFile = File(p.join(dir.path, 'Attendance.db'));
        await dbFile.writeAsBytes(decompressedBytes);
        return dbFile.path;
      }

      // Check if decompressed content is a TAR archive
      final tarResult = await _tryTarBytes(decompressedBytes, dir);
      if (tarResult != null) return tarResult;

      // Check if decompressed content is a ZIP
      if (decompressedBytes.length >= 4 &&
          decompressedBytes[0] == 0x50 && decompressedBytes[1] == 0x4B) {
        try {
          final archive = ZipDecoder().decodeBytes(decompressedBytes);
          return await _extractArchive(archive, dir);
        } catch (_) {}
      }

      // Maybe decompressed is just raw data, try embedded SQLite scan
      return await _tryEmbeddedSqliteBytes(decompressedBytes, dir);
    } catch (_) {
      return null;
    }
  }

  // ── TAR ──
  static Future<String?> _tryTar(Uint8List bytes, Directory dir) async {
    return _tryTarBytes(bytes, dir);
  }

  static Future<String?> _tryTarBytes(Uint8List bytes, Directory dir) async {
    try {
      final archive = TarDecoder().decodeBytes(bytes);
      return await _extractArchive(archive, dir);
    } catch (_) {
      return null;
    }
  }

  // ── Raw SQLite ──
  static Future<String?> _tryRawSqlite(Uint8List bytes, Directory dir) async {
    if (bytes.length >= 16 &&
        String.fromCharCodes(bytes.sublist(0, 16)) == _sqliteHeader) {
      final dbFile = File(p.join(dir.path, 'Attendance.db'));
      await dbFile.writeAsBytes(bytes);
      return dbFile.path;
    }
    return null;
  }

  // ── Embedded SQLite scan ──
  static Future<String?> _tryEmbeddedSqlite(Uint8List bytes, Directory dir) async {
    return _tryEmbeddedSqliteBytes(bytes, dir);
  }

  static Future<String?> _tryEmbeddedSqliteBytes(Uint8List bytes, Directory dir) async {
    final headerBytes = _sqliteHeader.codeUnits;
    for (int i = 0; i <= bytes.length - headerBytes.length; i++) {
      bool match = true;
      for (int j = 0; j < headerBytes.length; j++) {
        if (bytes[i + j] != headerBytes[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        final dbFile = File(p.join(dir.path, 'Attendance.db'));
        await dbFile.writeAsBytes(bytes.sublist(i));
        return dbFile.path;
      }
    }
    return null;
  }

  // ── Extract any archive and find a .db file ──
  static Future<String?> _extractArchive(Archive archive, Directory dir) async {
    String? dbPath;
    for (final entry in archive) {
      if (entry.isFile) {
        final data = entry.content as List<int>;
        final outFile = File(p.join(dir.path, entry.name));
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(data);

        final lower = entry.name.toLowerCase();
        // Prefer "Attendance.db" but accept any .db or .sqlite file
        if (lower.contains('attendance') && lower.endsWith('.db')) {
          dbPath = outFile.path;
        } else if (dbPath == null && (lower.endsWith('.db') || lower.endsWith('.sqlite'))) {
          dbPath = outFile.path;
        }
      }
    }

    // If no .db found in archive, check if any extracted file is a SQLite DB
    if (dbPath == null) {
      final files = dir.listSync(recursive: true).whereType<File>();
      for (final f in files) {
        final header = await f.openRead(0, 16).fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
        if (header.length >= 16 && String.fromCharCodes(header.sublist(0, 16)) == _sqliteHeader) {
          dbPath = f.path;
          break;
        }
      }
    }

    return dbPath;
  }

  // ── Read SQLite database ──
  static Future<AttendXModel> _readDatabase(String dbPath) async {
    final db = await openDatabase(dbPath, readOnly: true);
    try {
      final model = AttendXModel.blank();

      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'");
      final tableNames =
          tables.map((t) => (t['name'] as String).toLowerCase()).toSet();

      // 1. Subjects
      List<Map<String, dynamic>> subjectsData = [];
      for (final name in ['subjects', 'subject', 'SubjectTable', 'subjecttable']) {
        if (tableNames.contains(name.toLowerCase())) {
          subjectsData = await db.query(name);
          break;
        }
      }

      if (subjectsData.isNotEmpty) {
        model.subjects = subjectsData.map((s) {
          return Subject(
            name: _str(s, ['name', 'subject_name', 'title', 'subjectName']) ?? 'Unknown',
            code: _str(s, ['code', 'subject_code', 'subjectCode']) ?? '',
            faculty: _str(s, ['faculty', 'teacher', 'professor', 'facultyName']) ?? '',
            present: _int(s, ['present', 'attended', 'presentCount']),
            total: _int(s, ['total', 'totalClasses', 'total_classes', 'totalCount']),
            isLab: _isLab(s),
            icon: AttendXData.iconChoices[0].icon,
            color: AttendXData.iconChoices[0].color,
            styleIndex: 0,
          );
        }).toList();
      }

      // 2. Attendance records
      List<Map<String, dynamic>> attendanceData = [];
      for (final name in ['attendance', 'records', 'attendance_records', 'AttendanceTable', 'attendancetable']) {
        if (tableNames.contains(name.toLowerCase())) {
          attendanceData = await db.query(name);
          break;
        }
      }

      for (final row in attendanceData) {
        final dateStr = _str(row, ['date', 'attendance_date', 'dateStr', 'recordDate']);
        if (dateStr == null || dateStr.isEmpty) continue;

        String? subjectName = _str(row, ['subject_name', 'subjectName', 'subject']);
        if (subjectName == null && subjectsData.isNotEmpty) {
          final sid = row['subject_id'] ?? row['subjectId'] ?? row['sid'];
          if (sid != null) {
            for (final s in subjectsData) {
              if (s['id'] == sid || s['_id'] == sid || s['subjectId'] == sid) {
                subjectName = _str(s, ['name', 'subject_name', 'title', 'subjectName']);
                break;
              }
            }
          }
        }
        if (subjectName == null) continue;

        final status = _normalizeStatus(
            _str(row, ['status', 'type', 'state', 'attendanceStatus']) ?? 'present');

        final normalizedKey = model.normalizeDateKey(dateStr);
        model.dailyRecords[normalizedKey] ??= {};
        model.dailyRecords[normalizedKey]![subjectName] = status;
      }

      // 3. Timetable
      for (final name in ['timetable', 'schedule', 'TimetableTable', 'timetabletable']) {
        if (tableNames.contains(name.toLowerCase())) {
          final data = await db.query(name);
          for (final row in data) {
            final day = _str(row, ['day', 'day_name', 'weekday', 'dayName']);
            if (day == null || day.isEmpty) continue;
            final normalizedDay = model.normalizeDayName(day);
            final subName = _str(row, ['subject_name', 'subject', 'subjectName']);
            if (subName == null || subName.isEmpty) continue;
            final time = _str(row, ['time', 'time_slot', 'period', 'timeSlot']) ?? '';
            final room = _str(row, ['room', 'location', 'classroom', 'roomNo']) ?? '';

            model.weeklyTimetable[normalizedDay] ??= [];
            model.weeklyTimetable[normalizedDay]!.add(TimetableEntry(
              subjectName: subName, time: time, room: room));
          }
          break;
        }
      }

      // 4. Settings
      for (final name in ['settings', 'preferences', 'config', 'SettingsTable']) {
        if (tableNames.contains(name.toLowerCase())) {
          try {
            final rows = await db.query(name, limit: 1);
            if (rows.isNotEmpty) {
              final s = rows.first;
              model.studentName = _str(s, ['student_name', 'name', 'user_name', 'studentName']) ?? '';
              model.currentSemester = _int(s, ['current_semester', 'semester', 'currentSemester']);
              if (model.currentSemester == 0) model.currentSemester = 1;
              final minAtt = _double(s, ['min_attendance', 'minimum_attendance', 'target', 'minAttendance']);
              if (minAtt > 0) model.minimumAttendance = minAtt;
            }
          } catch (_) {}
          break;
        }
      }

      return model;
    } finally {
      await db.close();
    }
  }

  // ── Helpers ──

  static String? _str(Map<String, dynamic> row, List<String> keys) {
    for (final k in keys) {
      if (row.containsKey(k) && row[k] != null) return row[k].toString();
    }
    return null;
  }

  static int _int(Map<String, dynamic> row, List<String> keys) {
    for (final k in keys) {
      if (row.containsKey(k) && row[k] != null) {
        final v = row[k];
        if (v is num) return v.toInt();
        if (v is String) return int.tryParse(v) ?? 0;
      }
    }
    return 0;
  }

  static double _double(Map<String, dynamic> row, List<String> keys) {
    for (final k in keys) {
      if (row.containsKey(k) && row[k] != null) {
        final v = row[k];
        if (v is num) return v.toDouble();
        if (v is String) return double.tryParse(v) ?? 0.0;
      }
    }
    return 0.0;
  }

  static bool _isLab(Map<String, dynamic> row) {
    if (row.containsKey('is_lab') || row.containsKey('isLab')) {
      final v = row['is_lab'] ?? row['isLab'];
      if (v is num) return v.toInt() == 1;
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
    }
    if (row.containsKey('type')) {
      final t = (row['type']?.toString() ?? '').toLowerCase();
      return t == 'lab' || t == 'practical';
    }
    final name = (_str(row, ['name', 'subject_name', 'title']) ?? '').toLowerCase();
    return name.contains('lab') || name.contains('practical');
  }

  static String _normalizeStatus(String raw) {
    final s = raw.toLowerCase().trim();
    if (s == 'present' || s == 'p' || s == '1' || s == 'attended') return 'present';
    if (s == 'absent' || s == 'a' || s == '0' || s == 'missed') return 'absent';
    if (s == 'off' || s == 'cancelled' || s == 'holiday' || s == 'cancel') return 'off';
    return 'present';
  }
}
