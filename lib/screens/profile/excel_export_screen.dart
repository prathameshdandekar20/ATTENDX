import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../widgets/common.dart';
import '../../local_store.dart';

class ExcelExportScreen extends StatefulWidget {
  static const route = '/excel-export';

  const ExcelExportScreen({super.key});

  @override
  State<ExcelExportScreen> createState() => _ExcelExportScreenState();
}

class _ExcelExportScreenState extends State<ExcelExportScreen> {
  String? _lastExportPath;
  bool _isExporting = false;

  Future<void> _exportAndShareCsv() async {
    setState(() => _isExporting = true);
    final model = AttendXScope.of(context);
    final buffer = StringBuffer();

    // 1. Header Information
    buffer.writeln('=== ATTENDX ATTENDANCE REPORT ===');
    buffer.writeln('Semester,${model.currentSemester}');
    buffer.writeln('Overall Attendance,${model.overallAttendance.toStringAsFixed(2)}%');
    buffer.writeln('Target Minimum,${model.minimumAttendance.round()}%');
    buffer.writeln('Total Attended,${model.attendedClasses}/${model.totalClasses}');
    buffer.writeln('Export Date,"${DateTime.now().toIso8601String()}"');
    buffer.writeln();

    // 2. Subject Summary Section
    buffer.writeln('--- SUBJECT SUMMARY ---');
    buffer.writeln('Subject Name,Code,Type,Present,Total,Percentage(%)');
    for (final s in model.subjects) {
      buffer.writeln('"${s.name}","${s.code}","${s.isLab ? "LAB" : "THEORY"}",${s.present},${s.total},${s.percentage.toStringAsFixed(2)}%');
    }
    buffer.writeln();

    // 3. CT Breakdown Section
    buffer.writeln('--- CLASS TEST (CT) BREAKDOWN ---');
    buffer.writeln('Window,Present,Total,Percentage(%)');
    for (final ct in model.ctSlices) {
      buffer.writeln('"${ct.label}",${ct.present},${ct.total},${ct.percent.toStringAsFixed(2)}%');
    }
    buffer.writeln();

    // 4. Daily Attendance Logs Section
    buffer.writeln('--- DATE-WISE ATTENDANCE RECORDS ---');
    buffer.writeln('Date,Subject,Status');
    
    // Sort dates in chronological order
    final sortedDates = model.dailyRecords.keys.toList()..sort();
    for (final dateKey in sortedDates) {
      final dayMap = model.dailyRecords[dateKey] ?? {};
      for (final entry in dayMap.entries) {
        final subjectName = entry.key;
        final status = entry.value;
        if (status.isNotEmpty && status != 'clear') {
          final displayStatus = status == 'present'
              ? 'Present'
              : (status == 'absent' ? 'Absent' : 'No Class');
          buffer.writeln('"$dateKey","$subjectName","$displayStatus"');
        }
      }
    }

    try {
      final fileName = 'AttendX_Semester_${model.currentSemester}_Report.csv';
      final file = await AttendXLocalStore.writeBackup(fileName, buffer.toString());
      setState(() => _lastExportPath = file);

      // Trigger standard system Share Sheet (WhatsApp, Instagram, Drive, etc.)
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
      await Share.shareXFiles(
        [XFile(file)],
        text: '📊 AttendX Attendance Report (Semester ${model.currentSemester})',
        subject: 'AttendX Semester ${model.currentSemester} Attendance CSV',
        sharePositionOrigin: origin,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppPalette.green,
            content: Text('✅ Report exported and share dialog opened!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppPalette.red,
            content: Text('⚠️ Export failed: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    return GradientScaffold(
      child: SafeArea(
        child: PageFrame(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
          children: [
            const TopBar(showBack: true, title: 'Export Data'),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Attendance Records',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppPalette.ink,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Export detailed semester-wise and CT breakdown reports as standard CSV files compatible with Excel, Google Sheets, and other spreadsheet apps.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppPalette.slate),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppPalette.glassLine),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.doc_text_fill, color: AppPalette.green, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'AttendX_Semester_${model.currentSemester}_Report.csv',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppPalette.ink),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppPalette.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('CSV / Excel', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppPalette.green)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Primary Export & Share Card
            GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppPalette.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.share, color: AppPalette.green, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Semester ${model.currentSemester} Report',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppPalette.ink),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Includes all ${model.subjects.length} subjects, CT breakdowns, and date-wise attendance logs.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppPalette.slate),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isExporting ? null : _exportAndShareCsv,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(CupertinoIcons.share_up, size: 18),
                      label: Text(_isExporting ? 'Generating CSV...' : 'Export & Share CSV'),
                    ),
                  ),
                ],
              ),
            ),
            if (_lastExportPath != null)
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Last Exported File'),
                    const SizedBox(height: 8),
                    Text(
                      _lastExportPath!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPalette.green,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            // Included Data List
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Data Included In Report'),
                  const SizedBox(height: 14),
                  ...[
                    'Overall Attendance & Target %',
                    'Subject-wise Present / Total & %',
                    'Lab & Theory Categorization',
                    'Class Test (CT1) Attendance Slices',
                    'Complete Date-wise Daily Logs (Present, Absent, Cancelled)',
                  ].map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.checkmark_seal_fill,
                              color: AppPalette.green, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppPalette.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

