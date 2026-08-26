import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendx/models/attendx_model.dart';
import 'package:attendx/models/timetable_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return './build/test_temp';
      },
    );
  });

  group('Multi-Semester Persistence Tests', () {
    test('switching semesters preserves previous semester subjects, timetable, and attendance', () {
      final model = AttendXModel.blank();
      model.completeSetup(
        name: 'Alex',
        semester: 1,
        minimum: 75,
        subjectNames: ['Mathematics', 'Physics'],
      );

      // Mark attendance in Sem 1
      model.markAttendance(model.subjects[0], true); // Math: 1/1
      model.markAttendance(model.subjects[1], false); // Phys: 0/1
      model.addTimetableEntry('Monday', const TimetableEntry(subjectName: 'Mathematics', time: '09:00 AM', room: '101'));

      expect(model.currentSemester, 1);
      expect(model.subjects.length, 2);
      expect(model.attendedClasses, 1);
      expect(model.totalClasses, 2);
      expect(model.weeklyTimetable['Monday']?.length, 1);

      // Switch to Semester 2
      model.setSemester(2);
      expect(model.currentSemester, 2);
      expect(model.subjects.isEmpty, true);
      expect(model.weeklyTimetable.isEmpty, true);

      // Add subjects in Semester 2
      model.addSubject(name: 'Data Structures', code: 'CS201');
      model.addSubject(name: 'Algorithms', code: 'CS202');
      model.markAttendance(model.subjects[0], true);
      model.markAttendance(model.subjects[0], true); // DS: 2/2

      expect(model.subjects.length, 2);
      expect(model.attendedClasses, 2);
      expect(model.totalClasses, 2);

      // Switch back to Semester 1
      model.setSemester(1);
      expect(model.currentSemester, 1);
      expect(model.subjects.length, 2);
      expect(model.subjects[0].name, 'Mathematics');
      expect(model.subjects[0].present, 1);
      expect(model.subjects[0].total, 1);
      expect(model.subjects[1].name, 'Physics');
      expect(model.subjects[1].present, 0);
      expect(model.subjects[1].total, 1);
      expect(model.weeklyTimetable['Monday']?.length, 1);
      expect(model.weeklyTimetable['Monday']?[0].subjectName, 'Mathematics');

      // Switch back to Semester 2
      model.setSemester(2);
      expect(model.currentSemester, 2);
      expect(model.subjects.length, 2);
      expect(model.subjects[0].name, 'Data Structures');
      expect(model.subjects[0].present, 2);
      expect(model.subjects[0].total, 2);
    });

    test('semesterSnapshots correctly reflects stats across all active semesters', () {
      final model = AttendXModel.blank();
      model.completeSetup(
        name: 'Alex',
        semester: 1,
        minimum: 75,
        subjectNames: ['Math'],
      );
      model.markAttendance(model.subjects[0], true); // Sem 1: 100%

      model.setSemester(2);
      model.addSubject(name: 'Chemistry', code: 'CH101');
      model.markAttendance(model.subjects[0], false); // Sem 2: 0%

      final snapshots = model.semesterSnapshots;
      expect(snapshots.length, 8);

      // Sem 1 snapshot
      expect(snapshots[0].attendance, 100.0);
      expect(snapshots[0].subjects, 1);
      expect(snapshots[0].classes, 1);
      expect(snapshots[0].isCurrent, false);

      // Sem 2 snapshot
      expect(snapshots[1].attendance, 0.0);
      expect(snapshots[1].subjects, 1);
      expect(snapshots[1].classes, 1);
      expect(snapshots[1].isCurrent, true);

      // Sem 3 (unused) snapshot
      expect(snapshots[2].attendance, 0.0);
      expect(snapshots[2].subjects, 0);
      expect(snapshots[2].classes, 0);
      expect(snapshots[2].isCurrent, false);
    });

    test('JSON serialization and restoration preserves all semesters', () {
      final model1 = AttendXModel.blank();
      model1.completeSetup(
        name: 'Sam',
        semester: 1,
        minimum: 80,
        subjectNames: ['OS'],
      );
      model1.markAttendance(model1.subjects[0], true);

      model1.setSemester(3);
      model1.addSubject(name: 'DBMS', code: 'CS301');
      model1.markAttendance(model1.subjects[0], true);

      final jsonString = model1.toJsonString();

      final model2 = AttendXModel.blank();
      final success = model2.importFromJsonString(jsonString);
      expect(success, true);
      expect(model2.studentName, 'Sam');
      expect(model2.currentSemester, 3);
      expect(model2.subjects[0].name, 'DBMS');

      model2.setSemester(1);
      expect(model2.currentSemester, 1);
      expect(model2.subjects[0].name, 'OS');
      expect(model2.subjects[0].present, 1);
    });

    test('Legacy single-semester JSON format imports cleanly without error', () {
      const legacyJson = '''
      {
        "studentName": "LegacyUser",
        "currentSemester": 1,
        "minimumAttendance": 75.0,
        "subjects": [
          {
            "name": "History",
            "code": "HIS101",
            "faculty": "Dr. Smith",
            "present": 3,
            "total": 4,
            "isLab": false,
            "iconCodePoint": 58835,
            "colorValue": 4287215678,
            "styleIndex": 0
          }
        ],
        "logs": [],
        "weeklyTimetable": {},
        "dailyRecords": {},
        "extraLectures": {}
      }
      ''';

      final model = AttendXModel.blank();
      final success = model.importFromJsonString(legacyJson);
      expect(success, true);
      expect(model.studentName, 'LegacyUser');
      expect(model.currentSemester, 1);
      expect(model.subjects.length, 1);
      expect(model.subjects[0].name, 'History');
      expect(model.subjects[0].present, 3);
      expect(model.subjects[0].total, 4);

      // Now switch semester and back
      model.setSemester(2);
      expect(model.subjects.isEmpty, true);
      model.setSemester(1);
      expect(model.subjects.length, 1);
      expect(model.subjects[0].name, 'History');
    });

    test('deep copy isolation: mutating active state in one semester does not corrupt other semesters', () {
      final model = AttendXModel.blank();
      model.completeSetup(
        name: 'DeepTest',
        semester: 1,
        minimum: 75,
        subjectNames: ['Math'],
      );

      // Sem 1: Add timetable, daily records, extra lectures
      model.addTimetableEntry('Monday', const TimetableEntry(subjectName: 'Math', time: '10:00 AM', room: 'R1'));
      final today = DateTime.now();
      model.markAttendance(model.subjects[0], true, date: today);
      model.addExtraLecture(date: today, subject: model.subjects[0]);

      // Switch to Sem 2
      model.setSemester(2);
      model.addSubject(name: 'Physics', code: 'PHY101');
      model.addTimetableEntry('Monday', const TimetableEntry(subjectName: 'Physics', time: '11:00 AM', room: 'R3'));
      model.markAttendance(model.subjects[0], false, date: today);

      // Verify Sem 2 state
      expect(model.subjects[0].name, 'Physics');
      expect(model.weeklyTimetable['Monday']!.length, 1);
      expect(model.weeklyTimetable['Monday']![0].subjectName, 'Physics');

      // Switch back to Sem 1 and check complete isolation
      model.setSemester(1);
      expect(model.subjects.length, 1);
      expect(model.subjects[0].name, 'Math');
      expect(model.subjects[0].present, 1);
      expect(model.weeklyTimetable['Monday']!.length, 1);
      expect(model.weeklyTimetable['Monday']![0].subjectName, 'Math');
      expect(model.extraLectures[model.dateKey(today)]?.length, 1);
      expect(model.extraLectures[model.dateKey(today)]?[0].subjectName, 'Math');

      // Reset Attendance in Sem 1 should NOT affect Sem 2
      model.resetAttendance();
      expect(model.subjects[0].present, 0);
      expect(model.subjects[0].total, 0);

      model.setSemester(2);
      expect(model.subjects.length, 1);
      expect(model.subjects[0].name, 'Physics');
      expect(model.subjects[0].present, 0);
      expect(model.subjects[0].total, 1); // 1 absent still intact!
    });

    test('theme selection and JSON persistence works cleanly', () {
      final model = AttendXModel.blank();
      expect(model.selectedTheme, 'obsidian_gold');
      expect(model.isDarkTheme, true);
      expect(model.themePalette.displayName, 'Obsidian Gold');

      model.setTheme('emerald_mint');
      expect(model.selectedTheme, 'emerald_mint');
      expect(model.isDarkTheme, false);
      expect(model.themePalette.displayName, 'Emerald Mint');

      final jsonString = model.toJsonString();
      final restored = AttendXModel.blank();
      restored.importFromJsonString(jsonString);

      expect(restored.selectedTheme, 'emerald_mint');
      expect(restored.isDarkTheme, false);
    });
  });
}
