import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/palette.dart';
import '../../models/attendx_model.dart';
import '../../widgets/common.dart';

class StudentSetupScreen extends StatefulWidget {
  const StudentSetupScreen({super.key});

  @override
  State<StudentSetupScreen> createState() => _StudentSetupScreenState();
}

class _StudentSetupScreenState extends State<StudentSetupScreen> {
  final _nameController = TextEditingController();
  final _minimumController = TextEditingController(text: '75');
  double _minimum = 75;

  @override
  void dispose() {
    _nameController.dispose();
    _minimumController.dispose();
    super.dispose();
  }

  void _onMinimumSliderChanged(double value) {
    setState(() {
      _minimum = value;
      _minimumController.text = value.round().toString();
    });
  }

  void _onMinimumTextChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 0 && parsed <= 100) {
      setState(() => _minimum = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: PageFrame(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppPalette.green,
                          child: const Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AttendX Setup',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter your details to get started.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPalette.slate,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GlassCard(
              child: Column(
                children: [
                  SetupTextField(
                    controller: _nameController,
                    label: 'Your name',
                    hint: 'Example: Rahul Sharma',
                    icon: CupertinoIcons.person,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Minimum attendance',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _minimumController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppPalette.green,
                                fontWeight: FontWeight.w900,
                              ),
                          decoration: InputDecoration(
                            suffixText: '%',
                            suffixStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppPalette.green,
                                  fontWeight: FontWeight.w900,
                                ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppPalette.green.withValues(alpha: 0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppPalette.green.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppPalette.green, width: 1.5),
                            ),
                          ),
                          onChanged: _onMinimumTextChanged,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _minimum.clamp(0, 100),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: _onMinimumSliderChanged,
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(CupertinoIcons.arrow_right_circle),
              label: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please enter your name.'),
        ),
      );
      return;
    }

    AttendXScope.of(context).completeSetup(
      name: name,
      semester: 1,
      minimum: _minimum,
      subjectNames: [],
    );
  }
}
