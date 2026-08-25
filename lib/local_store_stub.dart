class AttendXLocalStore {
  static String? _value;

  static Future<String?> read() async => _value;

  static Future<void> write(String value) async {
    _value = value;
  }

  static Future<String> backupDir() async => '/tmp/attendx/backups';

  static Future<String> writeBackup(String fileName, String content) async {
    return '/tmp/attendx/backups/$fileName';
  }

  static Future<String?> readBackup(String path) async => null;
}
