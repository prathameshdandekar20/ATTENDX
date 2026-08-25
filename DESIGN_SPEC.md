# AttendX UI/UX Design Spec

## Product Positioning

AttendX is a student-only, offline-first attendance companion. It opens directly to **Mark Attendance** so the most common daily action is never buried behind dashboards, teacher panels, or backend workflows.

## Visual System

- **Mood:** premium productivity, iOS-inspired softness, modern Android clarity.
- **Surface:** frosted glass cards with blur, translucent borders, smooth shadows, and rounded 22-32px corners.
- **Background:** soft pastel mint, white, and pale green gradient with dark mode variants.
- **Status colors:** green for safe, yellow for warning, red for danger, blue/purple for analytics.
- **Motion:** fade/slide page transitions, animated progress rings, press-scale interactions, and animated charts.

## Navigation

Bottom navigation is persistent in the app shell:

1. Mark Attendance
2. Subjects
3. Semester
4. More/Profile

The default selected tab is `Mark Attendance`.

## Core Student Flows

- **Daily marking:** Today schedule -> one-tap Present/Absent -> quick snackbar confirmation.
- **Subject review:** Subject list -> details -> CT breakdown -> attendance history -> edit/delete actions.
- **Semester switching:** Semester 1-8 cards with current/archived status and separate statistics.
- **CT tracking:** CT1/CT2 completion actions reset the current tracking window while preserving old CT data.
- **Bunk planning:** minimum attendance slider, safe miss count, recovery count, and danger warnings.
- **Reports:** JSON backup/restore and Excel export screens with semester-wise and CT-wise report choices.

## Screens Implemented

- Splash Screen
- Onboarding Screens
- Mark Attendance Screen
- Subject List Screen
- Subject Details Screen
- Add/Edit Subject Screen
- Semester Management Screen
- Timetable Screen
- Statistics Screen
- CT Tracking Screen
- Bunk Calculator Screen
- Backup & Restore Screen
- Excel Export Screen
- Settings Screen
- Profile Screen

## Implementation Notes

The Flutter UI is currently mock-data driven and ready for integration with Hive, JSON import/export, and Excel generation. The UI components are intentionally reusable so persistence and real calculations can be wired in without redesigning the screens.
