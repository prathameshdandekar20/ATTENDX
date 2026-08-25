import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../widgets/common.dart';
import '../../ajbak_importer.dart';
import '../../local_store.dart';


class BackupRestoreScreen extends StatefulWidget {
  static const route = '/backup-restore';

  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final _importController = TextEditingController();
  String? _lastExportPath;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _exportJson() async {
    final model = AttendXScope.of(context);
    final jsonStr = model.toJsonString();
    try {
      final fileName = 'attendx_sem${model.currentSemester}_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = await AttendXLocalStore.writeBackup(fileName, jsonStr);
      setState(() => _lastExportPath = file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('✅ Exported to: $file'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('⚠️ Export failed: $e'),
          ),
        );
      }
    }
  }

  Future<void> _importAjbak() async {
    try {
      final importedModel = await AjbakImporter.importBackup();
      if (importedModel != null) {
        if (mounted) {
          AttendXScope.of(context).applyModel(importedModel);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('✅ .ajbak backup restored successfully!'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('❌ Import failed: $e'),
          ),
        );
      }
    }
  }

  void _showImportDialog() {
    _importController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import JSON'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: _importController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste your AttendX JSON backup here...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = _importController.text.trim();
              if (text.isEmpty) return;
              final model = AttendXScope.of(context);
              final success = model.importFromJsonString(text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(success
                      ? '✅ Data restored successfully!'
                      : '⚠️ Invalid JSON format.'),
                ),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = AttendXScope.of(context);
    final backup = BackupItem(
      'attendx_sem${model.currentSemester}_${shortDate(model.today).replaceAll(' ', '_').toLowerCase()}.json',
      'Today',
      '${(24 + model.subjects.length * 8 + model.logs.length * 2)} KB',
    );
    return DetailShell(
      title: 'Backup',
      children: [
        const HeroTitle(
          eyebrow: 'JSON backup for offline-first records',
          title: 'Backup & Restore',
        ),
        BackupHeroCard(
          title: 'Local Backup',
          subtitle: 'All semesters, subjects, CT windows, timetable, and logs.',
          icon: Icons.cloud_upload_rounded,
          color: AppPalette.green,
          button: 'Create JSON',
          onPressed: _exportJson,
        ),
        BackupHeroCard(
          title: 'Restore Data',
          subtitle: 'Paste a JSON backup to recover your full AttendX archive.',
          icon: Icons.cloud_download_rounded,
          color: AppPalette.blue,
          button: 'Import JSON',
          onPressed: _showImportDialog,
        ),
        BackupHeroCard(
          title: 'Legacy Import',
          subtitle: 'Select an .ajbak file to migrate from older attendance apps.',
          icon: Icons.settings_backup_restore_rounded,
          color: AppPalette.purple,
          button: 'Select .ajbak',
          onPressed: _importAjbak,
        ),
        if (_lastExportPath != null)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Last Export'),
                const SizedBox(height: 10),
                Text(
                  _lastExportPath!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.green,
                      ),
                ),
              ],
            ),
          ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Quick Copy'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Copy JSON to clipboard-like display
                    final jsonStr = model.toJsonString();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Your JSON Data'),
                        content: SizedBox(
                          width: double.maxFinite,
                          height: 300,
                          child: SingleChildScrollView(
                            child: SelectableText(
                              jsonStr,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(CupertinoIcons.doc_on_clipboard),
                  label: const Text('View JSON Data'),
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Recent Backups'),
              const SizedBox(height: 14),
              BackupRow(backup: backup),
            ],
          ),
        ),
      ],
    );
  }
}
