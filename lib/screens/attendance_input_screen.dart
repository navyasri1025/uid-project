import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../routes/app_routes.dart';
import '../services/attendance_calculator.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

/// AttendanceInputScreen allows students to input their attendance metrics
/// with full input validation and calculation triggering.
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
  final TextEditingController _targetController = TextEditingController(text: '75');
  final TextEditingController _upcomingController = TextEditingController(text: '10');

  String? _generalErrorMessage;

  @override
  void initState() {
    super.initState();
    // Auto-calculate absent classes when total or attended changes if user hasn't typed manually
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
    super.dispose();
  }

  void _onCalculatePressed() {
    setState(() {
      _generalErrorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final total = int.tryParse(_totalController.text.trim());
    final attended = int.tryParse(_attendedController.text.trim());
    final absent = int.tryParse(_absentController.text.trim());
    final target = double.tryParse(_targetController.text.trim());
    final upcoming = int.tryParse(_upcomingController.text.trim());

    // Validate using the business service
    final validationError = AttendanceCalculator.validateInputs(
      totalClasses: total,
      attendedClasses: attended,
      absentClasses: absent,
      targetPercentage: target,
      upcomingClasses: upcoming,
    );

    if (validationError != null) {
      setState(() {
        _generalErrorMessage = validationError;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Perform calculation
    final result = AttendanceCalculator.calculate(
      totalClasses: total!,
      attendedClasses: attended!,
      absentClasses: absent!,
      targetPercentage: target!,
      upcomingClasses: upcoming!,
    );

    // Navigate to ResultScreen
    Navigator.pushNamed(
      context,
      AppRoutes.result,
      arguments: result,
    );
  }

  void _setTargetPreset(double value) {
    setState(() {
      _targetController.text = value.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Attendance Data'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Instruction Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fill in your current course attendance numbers. We will analyze your safety status and forecast upcoming classes.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Error alert box if any
                if (_generalErrorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.dangerBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _generalErrorMessage!,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Form Field: Total Classes Conducted
                _buildFieldTitle(
                  label: 'Total Classes Conducted',
                  tooltip: 'Total number of lecture/lab periods held so far',
                  icon: Icons.date_range_rounded,
                ),
                TextFormField(
                  controller: _totalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 40',
                    prefixIcon: Icon(Icons.numbers_rounded, color: AppColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter total classes conducted';
                    }
                    final num = int.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Total classes must be at least 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Row with Attended & Absent Classes
                Row(
                  children: [
                    // Attended Classes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldTitle(
                            label: 'Classes Attended',
                            icon: Icons.check_circle_outline_rounded,
                          ),
                          TextFormField(
                            controller: _attendedController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              hintText: 'e.g. 32',
                              prefixIcon: Icon(Icons.check_rounded, color: AppColors.safe),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter attended';
                              }
                              final num = int.tryParse(value);
                              if (num == null || num < 0) {
                                return 'Cannot be negative';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Absent Classes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldTitle(
                            label: 'Classes Absent',
                            icon: Icons.cancel_outlined,
                          ),
                          TextFormField(
                            controller: _absentController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              hintText: 'e.g. 8',
                              prefixIcon: Icon(Icons.close_rounded, color: AppColors.danger),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter absent';
                              }
                              final num = int.tryParse(value);
                              if (num == null || num < 0) {
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
                const SizedBox(height: 18),

                // Target Attendance Percentage
                _buildFieldTitle(
                  label: 'Target Attendance Percentage (%)',
                  tooltip: 'Your college or university minimum required attendance',
                  icon: Icons.track_changes_rounded,
                ),
                TextFormField(
                  controller: _targetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?')),
                  ],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 75',
                    prefixIcon: Icon(Icons.percent_rounded, color: AppColors.textMuted),
                    suffixText: '%',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your target attendance percentage';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num <= 0 || num > 100) {
                      return 'Target percentage must be between 1 and 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Quick Target Presets
                Row(
                  children: [
                    const Text(
                      'Presets: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildPresetChip('65%', 65),
                    const SizedBox(width: 6),
                    _buildPresetChip('75%', 75),
                    const SizedBox(width: 6),
                    _buildPresetChip('80%', 80),
                    const SizedBox(width: 6),
                    _buildPresetChip('85%', 85),
                  ],
                ),
                const SizedBox(height: 18),

                // Upcoming Classes
                _buildFieldTitle(
                  label: 'Upcoming Classes to Forecast',
                  tooltip: 'Number of upcoming classes remaining or planned in this course',
                  icon: Icons.calendar_month_rounded,
                ),
                TextFormField(
                  controller: _upcomingController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 10',
                    prefixIcon: Icon(Icons.forward_rounded, color: AppColors.textMuted),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter upcoming classes';
                    }
                    final num = int.tryParse(value);
                    if (num == null || num < 0) {
                      return 'Cannot be negative';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: 'Calculate & Predict',
                  icon: Icons.analytics_rounded,
                  onPressed: _onCalculatePressed,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTitle({
    required String label,
    String? tooltip,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, double value) {
    final isSelected = _targetController.text == value.toStringAsFixed(0);
    return InkWell(
      onTap: () => _setTargetPreset(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

