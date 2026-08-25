import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../models/subject.dart';
import '../../widgets/common.dart';

class AddEditSubjectScreen extends StatefulWidget {
  static const route = '/subject/edit';

  const AddEditSubjectScreen({super.key});

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLab = false;
  int _selectedIconIndex = 0;
  Subject? _editingSubject;
  bool _initialized = false;
  int _addedCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Subject) {
        _editingSubject = args;
        _nameController.text = args.name.replaceAll(' (LAB)', '').trim();
        _codeController.text = args.code;
        _isLab = args.isLab;
        // Try to find icon index
        for (int i = 0; i < AttendXData.iconChoices.length; i++) {
          if (AttendXData.iconChoices[i].icon == args.icon) {
            _selectedIconIndex = i;
            break;
          }
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingSubject != null;

    return DetailShell(
      title: isEditing ? 'Edit Subject' : 'Add Subject',
      children: [
        HeroTitle(
          eyebrow: isEditing
              ? 'Update subject details'
              : (_addedCount > 0
                  ? 'Subject added! Add another or tap Done when finished'
                  : 'Create subject cards continuously'),
          title: isEditing ? 'Edit Subject' : 'Add Subject',
        ),
        GlassCard(
          child: Column(
            children: [
              SetupTextField(
                controller: _nameController,
                label: 'Subject name',
                hint: 'Example: Mathematics',
                icon: CupertinoIcons.book,
              ),
              const SizedBox(height: 14),
              SetupTextField(
                controller: _codeController,
                label: 'Subject code',
                hint: 'Optional',
                icon: CupertinoIcons.number,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Theory',
                      isSelected: !_isLab,
                      onTap: () => setState(() => _isLab = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeButton(
                      label: 'Lab',
                      isSelected: _isLab,
                      onTap: () => setState(() => _isLab = true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Subject Icon & Color'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(AttendXData.iconChoices.length, (index) {
                  final choice = AttendXData.iconChoices[index];
                  final isSelected = _selectedIconIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = index),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: choice.color.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? choice.color
                              : Colors.white.withValues(alpha: 0.5),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(choice.icon, color: choice.color),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        if (isEditing)
          FilledButton.icon(
            onPressed: _saveAndClose,
            icon: const Icon(CupertinoIcons.check_mark_circled),
            label: const Text('Update Subject'),
          )
        else ...[
          FilledButton.icon(
            onPressed: _saveAndAddNext,
            icon: const Icon(CupertinoIcons.plus_circle),
            label: const Text('Save Subject'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _finish,
            icon: const Icon(CupertinoIcons.check_mark_circled),
            label: Text(_addedCount > 0 ? 'Done ($_addedCount Added)' : 'Done'),
          ),
        ],
      ],
    );
  }

  void _saveAndAddNext() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please enter a subject name.'),
        ),
      );
      return;
    }

    final model = AttendXScope.of(context);
    final iconChoice = AttendXData.iconChoices[_selectedIconIndex];

    model.addSubject(
      name: name,
      code: _codeController.text.trim(),
      isLab: _isLab,
      icon: iconChoice.icon,
      color: iconChoice.color,
    );

    setState(() {
      _addedCount++;
      _nameController.clear();
      _codeController.clear();
      _isLab = false;
      _selectedIconIndex = (_selectedIconIndex + 1) % AttendXData.iconChoices.length;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text('✅ Added "$name"! Enter next subject below.'),
      ),
    );
  }

  void _saveAndClose() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please enter a subject name.'),
        ),
      );
      return;
    }

    final model = AttendXScope.of(context);
    final iconChoice = AttendXData.iconChoices[_selectedIconIndex];

    String finalName = name;
    if (_isLab && !finalName.toUpperCase().endsWith('(LAB)')) {
      finalName = '$finalName (LAB)';
    } else if (!_isLab) {
      finalName = finalName.replaceAll(RegExp(r'\s*\(LAB\)', caseSensitive: false), '').trim();
    }

    final updated = _editingSubject!.copyWith(
      name: finalName,
      code: _codeController.text.trim(),
      isLab: _isLab,
      icon: iconChoice.icon,
      color: iconChoice.color,
    );
    model.updateSubject(_editingSubject!, updated);
    Navigator.pop(context);
  }

  void _finish() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final model = AttendXScope.of(context);
      final iconChoice = AttendXData.iconChoices[_selectedIconIndex];
      model.addSubject(
        name: name,
        code: _codeController.text.trim(),
        isLab: _isLab,
        icon: iconChoice.icon,
        color: iconChoice.color,
      );
    }
    Navigator.pop(context);
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppPalette.green.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppPalette.green : Colors.white.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? AppPalette.green : AppPalette.slate,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }
}
