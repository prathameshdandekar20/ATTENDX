import 'package:attendx/main.dart';
import 'package:attendx/models/attendx_model.dart';
import 'package:attendx/screens/today/mark_attendance_screen.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('AttendX opens on Mark Attendance', (tester) async {
    final model = AttendXModel.blank()
      ..completeSetup(
        name: 'Student',
        semester: 1,
        minimum: 75,
        subjectNames: ['Mathematics'],
      );

    await tester.pumpWidget(AttendXApp(model: model));
    await tester.pumpAndSettle();

    expect(find.byType(MarkAttendanceScreen), findsOneWidget);
    expect(find.text("Day status:"), findsOneWidget);
  });
}
