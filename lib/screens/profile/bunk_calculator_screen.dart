import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../models/subject.dart';
import '../../widgets/common.dart';
import '../today/mark_attendance_screen.dart'; // For ProgressRing

class BunkCalculatorScreen extends StatefulWidget {
  static const route = '/bunk-calculator';

  const BunkCalculatorScreen({super.key});

  @override
  State<BunkCalculatorScreen> createState() => _BunkCalculatorScreenState();
}

class _BunkCalculatorScreenState extends State<BunkCalculatorScreen> {
  final List<Map<String, dynamic>> _testDays = [];
  bool _showTestMode = false;
  int _selectedTab = 0; // 0 = Overall Theory, 1 = After CT1

  int _testPresent = 0;
  int _testTotal = 0;

  void _addTestDay(bool attend) {
    setState(() {
      _testDays.add({
        'attend': attend,
        'label': 'Day ${_testDays.length + 1}',
      });
      if (attend) _testPresent++;
      _testTotal++;
    });
  }

  void _clearTestDays() {
    setState(() {
      _testDays.clear();
      _testPresent = 0;
      _testTotal = 0;
      _showTestMode = false;
    });
  }

  int _calculateCanMiss(int present, int total, double minimum) {
    if (minimum <= 0) return 999;
    final min = minimum / 100;
    var miss = 0;
    while (present / (total + miss + 1) >= min && miss < 500) {
      miss++;
    }
    return miss;
  }

  double _simulatedAttendance(int currentPresent, int currentTotal) {
    final totalPresent = currentPresent + _testPresent;
    final totalAll = currentTotal + _testTotal;
    if (totalAll == 0) return 0;
    return (totalPresent / totalAll) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);

    // Theory-only subjects and counts
    final theorySubjects = model.subjects.where((s) => !s.isLab).toList();
    final theoryPresent = theorySubjects.fold<int>(0, (sum, s) => sum + s.present);
    final theoryTotal = theorySubjects.fold<int>(0, (sum, s) => sum + s.total);

    // After CT1 calculations specifically for Theory
    final hasCt1 = model.ct1CompletedDate != null;
    int afterCt1Present = 0;
    int afterCt1Total = 0;

    if (hasCt1) {
      DateTime dt1;
      try {
        dt1 = DateTime.parse(model.ct1CompletedDate!);
      } catch (_) {
        dt1 = model.today;
      }
      final beforeCt1 = model.calculateSnapshotAt(dt1);
      final beforeCt1Present = beforeCt1['present']!;
      final beforeCt1Total = beforeCt1['total']!;

      afterCt1Present = (theoryPresent - beforeCt1Present).clamp(0, theoryPresent);
      afterCt1Total = (theoryTotal - beforeCt1Total).clamp(0, theoryTotal);
    }

    // Active Tab Data
    final activeTitle = _selectedTab == 0 ? 'Overall Theory' : 'After CT1';
    final currentPresent = _selectedTab == 0 ? theoryPresent : afterCt1Present;
    final currentTotal = _selectedTab == 0 ? theoryTotal : afterCt1Total;
    final currentPct = currentTotal == 0 ? 0.0 : (currentPresent / currentTotal) * 100;

    final canMissSelected = _calculateCanMiss(currentPresent, currentTotal, model.minimumAttendance);
    final neededSelected = classesNeeded(currentPresent, currentTotal, model.minimumAttendance);

    final canPop = Navigator.canPop(context);
    final palette = model.themePalette;

    return PageFrame(
      children: [
        if (canPop)
          const TopBar(showBack: true, title: 'Bunk Calculator')
        else
          const HeroTitle(
            eyebrow: 'Theory limits & safe bunks',
            title: 'Bunk Calculator',
          ),

            // 1. Top Two-Tab Selector: Overall Theory vs After CT1
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: palette.cardFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BouncyTap(
                      onTap: () => setState(() => _selectedTab = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? palette.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.chart_pie,
                              size: 16,
                              color: _selectedTab == 0
                                  ? (palette.isDark ? Colors.black : Colors.white)
                                  : palette.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Overall',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: _selectedTab == 0
                                    ? (palette.isDark ? Colors.black : Colors.white)
                                    : palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: BouncyTap(
                      onTap: () => setState(() => _selectedTab = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? palette.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.forward,
                              size: 16,
                              color: _selectedTab == 1
                                  ? (palette.isDark ? Colors.black : Colors.white)
                                  : palette.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'After CT1',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: _selectedTab == 1
                                    ? (palette.isDark ? Colors.black : Colors.white)
                                    : palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Notice if After CT1 tab selected but CT1 not yet marked
            if (_selectedTab == 1 && !hasCt1)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.info_circle_fill, color: AppPalette.yellow, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'CT1 has not been marked as completed yet. Complete CT1 in the Breakdown tab to unlock separate After-CT1 tracking.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),

            // 2. Target Minimum Card with Quick Presets
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Minimum',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Theory limits for $activeTitle',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppPalette.slate,
                                    fontSize: 12,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppPalette.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppPalette.green.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${model.minimumAttendance.round()}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppPalette.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      activeTrackColor: AppPalette.green,
                      inactiveTrackColor: AppPalette.green.withValues(alpha: 0.15),
                      thumbColor: AppPalette.green,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayColor: AppPalette.green.withValues(alpha: 0.15),
                    ),
                    child: Slider(
                      value: model.minimumAttendance.clamp(0, 100),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: model.setMinimumAttendance,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quick Preset Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [65, 75, 80, 85, 90].map((preset) {
                      final isSelected = model.minimumAttendance.round() == preset;
                      return GestureDetector(
                        onTap: () => model.setMinimumAttendance(preset.toDouble()),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppPalette.green : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppPalette.green : AppPalette.glassLine,
                            ),
                          ),
                          child: Text(
                            '$preset%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppPalette.slate,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // 3. Dynamic Summary Cards for Active Window (Theory Only)
            Row(
              children: [
                Expanded(
                  child: PredictionCard(
                    title: 'Can miss',
                    value: '$canMissSelected',
                    subtitle: 'Theory classes ($activeTitle)',
                    icon: CupertinoIcons.moon_zzz_fill,
                    color: AppPalette.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PredictionCard(
                    title: 'Need to attend',
                    value: '$neededSelected',
                    subtitle: 'to reach ${model.minimumAttendance.round()}% in $activeTitle',
                    icon: CupertinoIcons.arrow_up_circle_fill,
                    color: neededSelected > 0 ? AppPalette.red : AppPalette.blue,
                  ),
                ),
              ],
            ),

            // 4. Theory Subjects Breakdown
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Theory Subjects (${theorySubjects.length})',
                    trailing: Text(
                      'Target: ${model.minimumAttendance.round()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: model.themePalette.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (theorySubjects.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No theory subjects found. Add theory subjects in Schedule.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...theorySubjects.map((subject) {
                      final canMiss = subject.canMissFor(model.minimumAttendance);
                      final needToAttend = classesNeeded(
                        subject.present,
                        subject.total,
                        model.minimumAttendance,
                      );
                      final pct = subject.percentage;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: palette.isDark ? const Color(0xFF1A1610) : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: palette.isDark ? subject.color.withValues(alpha: 0.25) : palette.cardBorder,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SubjectIcon(subject: subject, size: 38),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: palette.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${subject.present}/${subject.total} classes attended (${pct.toStringAsFixed(1)}%)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: palette.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (canMiss > 0)
                                  StatusPill(
                                    label: 'Can miss $canMiss',
                                    color: AppPalette.green,
                                  )
                                else if (needToAttend > 0)
                                  StatusPill(
                                    label: 'Need $needToAttend',
                                    color: AppPalette.red,
                                  )
                                else
                                  const StatusPill(
                                    label: "Can't miss",
                                    color: AppPalette.yellow,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Mini progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (pct / 100).clamp(0.0, 1.0),
                                minHeight: 4,
                                backgroundColor: palette.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
                                valueColor: AlwaysStoppedAnimation(
                                  pct >= model.minimumAttendance ? (palette.isDark ? palette.accent : AppPalette.green) : AppPalette.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            // 5. Theory Attendance Simulator
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: SectionHeader(title: 'Theory Attendance Simulator'),
                      ),
                      CupertinoSwitch(
                        value: _showTestMode,
                        activeTrackColor: palette.accent,
                        onChanged: (value) {
                          setState(() {
                            _showTestMode = value;
                            if (!value) _clearTestDays();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Simulate attending or skipping future Theory classes to project your $activeTitle percentage.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                  ),
                  if (_showTestMode) ...[
                    const SizedBox(height: 16),
                    // Live Projection Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.isDark ? const Color(0xFF1A1610) : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: palette.cardBorder),
                      ),
                      child: Row(
                        children: [
                          ProgressRing(
                            value: _simulatedAttendance(currentPresent, currentTotal) / 100,
                            label: '${_simulatedAttendance(currentPresent, currentTotal).toStringAsFixed(1)}%',
                            color: _simulatedAttendance(currentPresent, currentTotal) >= model.minimumAttendance
                                ? (palette.isDark ? palette.accent : AppPalette.green)
                                : AppPalette.red,
                            size: 76,
                            strokeWidth: 8,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Projected $activeTitle Attendance',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: palette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Simulated: +$_testPresent / +$_testTotal classes',
                                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                                ),
                                Text(
                                  'Total: ${currentPresent + _testPresent}/${currentTotal + _testTotal}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: palette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: palette.isDark ? palette.accent : AppPalette.green,
                              foregroundColor: palette.isDark ? Colors.black : Colors.white,
                            ),
                            onPressed: () => _addTestDay(true),
                            icon: const Icon(CupertinoIcons.check_mark, size: 16),
                            label: const Text('+ Attend Class'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppPalette.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _addTestDay(false),
                            icon: const Icon(CupertinoIcons.xmark, size: 16),
                            label: const Text('+ Miss Class'),
                          ),
                        ),
                      ],
                    ),
                    if (_testDays.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _testDays.asMap().entries.map((entry) {
                          final day = entry.value;
                          final attend = day['attend'] as bool;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: attend
                                  ? AppPalette.green.withValues(alpha: 0.12)
                                  : AppPalette.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: attend
                                    ? AppPalette.green.withValues(alpha: 0.3)
                                    : AppPalette.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${day['label']}: ${attend ? '✓ Attended' : '✗ Missed'}',
                              style: TextStyle(
                                color: attend ? AppPalette.green : AppPalette.red,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: _clearTestDays,
                          icon: const Icon(CupertinoIcons.delete, size: 14, color: AppPalette.red),
                          label: const Text('Reset Simulation', style: TextStyle(color: AppPalette.red)),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            // 6. Smart Recommendation Card
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Smart Recommendation'),
                  const SizedBox(height: 12),
                  WarningTile(
                    title: (currentTotal == 0 || currentPct >= model.minimumAttendance)
                        ? 'Safe Standing'
                        : 'Attendance Action Required',
                    subtitle: currentTotal == 0
                        ? 'Mark a few theory classes to get personalized bunk predictions.'
                        : currentPct >= model.minimumAttendance
                            ? 'You have a safety margin of $canMissSelected Theory classes in $activeTitle.'
                            : 'Attend $neededSelected consecutive Theory classes to bring $activeTitle attendance to ${model.minimumAttendance.round()}%.',
                    color: (currentTotal == 0 || currentPct >= model.minimumAttendance)
                        ? AppPalette.green
                        : AppPalette.red,
                    icon: (currentTotal == 0 || currentPct >= model.minimumAttendance)
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.exclamationmark_triangle_fill,
                  ),
                ],
              ),
            ),
        const SizedBox(height: 80),
      ],
    );
  }
}
