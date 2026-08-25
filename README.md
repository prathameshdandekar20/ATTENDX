# AttendX

AttendX is a premium Flutter UI concept for an offline-first, student-only attendance management app. The default app shell opens directly on the **Mark Attendance** tab and includes the full mobile workflow requested: semesters, subject management, CT tracking, timetable, statistics, bunk planning, backup/restore, Excel export, settings, profile, splash, and onboarding preview screens.

## Design Direction

- Modern glassmorphism with frosted cards, blur, soft shadows, and subtle glow.
- Soft pastel mint/green background with dark mode compatible surfaces.
- Bottom navigation: Mark Attendance, Subjects, Semester, More/Profile.
- Fast one-tap Present/Absent controls on today's classes.
- Production-style reusable widgets for cards, progress rings, action tiles, charts, and settings rows.

## Run

Flutter has been installed at:

```text
C:\Users\HI\development\flutter
```

Open a new PowerShell window so the updated PATH is loaded, then run:

```bash
flutter pub get
flutter run
```

For a Chrome preview:

```bash
flutter run -d chrome
```

For the static web build used by this workspace preview:

```bash
flutter build web
node scripts/serve_web.mjs build/web 52934 127.0.0.1
```

Then open:

```text
http://127.0.0.1:52934
```

The main implementation lives in `lib/main.dart`.
