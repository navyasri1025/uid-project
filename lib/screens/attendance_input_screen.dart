import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../routes/app_routes.dart';
import '../services/attendance_calculator.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/responsive_content.dart';

/// Clean input form screen. Preserves all calculation logic and validation.
class AttendanceInputScreen extends StatefulWidget {
  const AttendanceInputScreen({super.key});

  @override
  State<AttendanceInputScreen> createState() => _AttendanceInputScreenState();
}

class _AttendanceInputScreenState extends State<AttendanceInputScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _attendedController = TextEditingController();
  final TextEditingController _absentController = TextEditingController();
  final TextEditingController _targetController =
      TextEditingController(text: '75');
  final TextEditingController _upcomingController =
      TextEditingController(text: '10');
  final TextEditingController _nameController = TextEditingController();

  String? _generalErrorMessage;

  @override
  void initState() {
    super.initState();
    _attendedController.addListener(_autoUpdateAbsent);
    _totalController.addListener(_autoUpdateAbsent);
  }

  void _autoUpdateAbsent() {
    final total = int.tryParse(_totalController.text);
    final attended = int.tryParse(_attendedController.text);
    if (total != null && attended != null && attended <= total) {
      final absent = total - attended;
      if (_absentController.text != absent.toString()) {
        _absentController.text = absent.toString();
      }
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    _attendedController.dispose();
    _absentController.dispose();
    _targetController.dispose();
    _upcomingController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onCalculatePressed() {
    setState(() => _generalErrorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final total = int.tryParse(_totalController.text.trim());
    final attended = int.tryParse(_attendedController.text.trim());
    final absent = int.tryParse(_absentController.text.trim());
    final target = double.tryParse(_targetController.text.trim());
    final upcoming = int.tryParse(_upcomingController.text.trim());

    final validationError = AttendanceCalculator.validateInputs(
      totalClasses: total,
      attendedClasses: attended,
      absentClasses: absent,
      targetPercentage: target,
      upcomingClasses: upcoming,
    );

    if (validationError != null) {
      setState(() => _generalErrorMessage = validationError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = AttendanceCalculator.calculate(
      name: _nameController.text.trim(),
      totalClasses: total!,
      attendedClasses: attended!,
      absentClasses: absent!,
      targetPercentage: target!,
      upcomingClasses: upcoming!,
    );

    Navigator.pushNamed(context, AppRoutes.result, arguments: result);
  }

  void _setTargetPreset(double value) {
    setState(() => _targetController.text = value.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Calculation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          child: ResponsiveContent(
            maxWidth: 680,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error banner
                  if (_generalErrorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.dangerBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.danger, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _generalErrorMessage!,
                              style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Card: Record name ──────────────────────────────────
                  _FormCard(
                    children: [
                      const _FieldLabel(
                          icon: Icons.label_outline_rounded,
                          text: 'Record name'),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Mathematics or Alex – Physics',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Please enter a name for this record'
                                : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Card: Class counts ─────────────────────────────────
                  _FormCard(
                    children: [
                      const _SectionTitle(text: 'Class counts'),
                      const SizedBox(height: 16),
                      const _FieldLabel(
                          icon: Icons.date_range_rounded,
                          text: 'Total classes conducted'),
                      TextFormField(
                        controller: _totalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:
                            const InputDecoration(hintText: 'e.g. 40'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter total classes conducted';
                          }
                          final n = int.tryParse(v);
                          if (n == null || n <= 0) {
                            return 'Must be at least 1';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel(
                                    icon: Icons.check_circle_outline_rounded,
                                    text: 'Attended',
                                    color: AppColors.safe),
                                TextFormField(
                                  controller: _attendedController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: const InputDecoration(
                                      hintText: 'e.g. 32'),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Enter attended';
                                    }
                                    final n = int.tryParse(v);
                                    if (n == null || n < 0) {
                                      return 'Cannot be negative';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel(
                                    icon: Icons.cancel_outlined,
                                    text: 'Absent',
                                    color: AppColors.danger),
                                TextFormField(
                                  controller: _absentController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: const InputDecoration(
                                      hintText: 'e.g. 8'),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Enter absent';
                                    }
                                    final n = int.tryParse(v);
                                    if (n == null || n < 0) {
                                      return 'Cannot be negative';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Card: Target & upcoming ────────────────────────────
                  _FormCard(
                    children: [
                      const _SectionTitle(text: 'Target & forecast'),
                      const SizedBox(height: 16),
                      const _FieldLabel(
                          icon: Icons.track_changes_rounded,
                          text: 'Target attendance (%)'),
                      TextFormField(
                        controller: _targetController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d{0,3}(\.\d{0,2})?')),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'e.g. 75',
                          suffixText: '%',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter target percentage';
                          }
                          final n = double.tryParse(v);
                          if (n == null || n <= 0 || n > 100) {
                            return 'Must be between 1 and 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Quick preset chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [75, 65, 80, 85].map((p) {
                          final selected =
                              _targetController.text == p.toString();
                          return GestureDetector(
                            onTap: () => _setTargetPreset(p.toDouble()),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                '$p%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel(
                          icon: Icons.calendar_month_rounded,
                          text: 'Upcoming classes to forecast'),
                      TextFormField(
                        controller: _upcomingController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration:
                            const InputDecoration(hintText: 'e.g. 10'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter upcoming classes';
                          }
                          final n = int.tryParse(v);
                          if (n == null || n < 0) {
                            return 'Cannot be negative';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Calculate button
                  CustomButton(
                    text: 'Calculate & Predict',
                    icon: Icons.analytics_rounded,
                    onPressed: _onCalculatePressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Local helper widgets ──────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _FieldLabel({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: c),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
