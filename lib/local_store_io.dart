import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AttendXLocalStore {
  static String? _cachedBasePath;

  static Future<String> _basePath() async {
    if (_cachedBasePath != null) return _cachedBasePath!;
    final dir = await getApplicationDocumentsDirectory();
    _cachedBasePath = '${dir.path}/attendx';
    return _cachedBasePath!;
  }

  static Future<String?> read() async {
    final file = await _file();
    if (!await file.exists()) {
      // Migrate from old temp-based storage if it exists
      final oldFile = File('${Directory.systemTemp.path}/attendx/student_profile.json');
      if (await oldFile.exists()) {
        final data = await oldFile.readAsString();
        await write(data); // Write to new persistent location
        return data;
      }
      return null;
    }
    return file.readAsString();
  }

  static Future<void> write(String value) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(value, flush: true);
  }

  static Future<File> _file() async {
    final base = await _basePath();
    return File('$base/student_profile.json');
  }

  /// Returns the backup directory path
  static Future<String> backupDir() async {
    final base = await _basePath();
    final root = Directory('$base/backups');
    await root.create(recursive: true);
    return root.path;
  }

  /// Writes a backup file and returns the full path
  static Future<String> writeBackup(String fileName, String content) async {
    final dir = await backupDir();
    final file = File('$dir/$fileName');
    await file.writeAsString(content, flush: true);
    return file.path;
  }

  /// Reads a backup file by path
  static Future<String?> readBackup(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsString();
  }
}
