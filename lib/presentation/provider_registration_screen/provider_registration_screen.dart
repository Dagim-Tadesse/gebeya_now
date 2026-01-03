import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/business_details_section.dart';
import './widgets/location_section.dart';
import './widgets/personal_info_section.dart';
import './widgets/pricing_description_section.dart';
import './widgets/working_hours_section.dart';

/// Provider Registration Screen
/// Enables service professionals to create business profiles with streamlined mobile-optimized form design
class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({super.key});

  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // State Variables
  String? _profileImagePath;
  String? _selectedCategory;
  final List<String> _selectedSpecializations = [];
  double _yearsOfExperience = 0;
  double _serviceRadius = 5;
  bool _isLocationDetected = false;
  int _currentStep = 1;
  final int _totalSteps = 3;

  // Working Hours State
  final Map<String, bool> _workingDays = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': false,
    'Sunday': false,
  };

  final Map<String, TimeOfDay> _startTimes = {
    'Monday': const TimeOfDay(hour: 9, minute: 0),
    'Tuesday': const TimeOfDay(hour: 9, minute: 0),
    'Wednesday': const TimeOfDay(hour: 9, minute: 0),
    'Thursday': const TimeOfDay(hour: 9, minute: 0),
    'Friday': const TimeOfDay(hour: 9, minute: 0),
    'Saturday': const TimeOfDay(hour: 9, minute: 0),
    'Sunday': const TimeOfDay(hour: 9, minute: 0),
  };

  final Map<String, TimeOfDay> _endTimes = {
    'Monday': const TimeOfDay(hour: 17, minute: 0),
    'Tuesday': const TimeOfDay(hour: 17, minute: 0),
    'Wednesday': const TimeOfDay(hour: 17, minute: 0),
    'Thursday': const TimeOfDay(hour: 17, minute: 0),
    'Friday': const TimeOfDay(hour: 17, minute: 0),
    'Saturday': const TimeOfDay(hour: 17, minute: 0),
    'Sunday': const TimeOfDay(hour: 17, minute: 0),
  };

  bool _hasUnsavedChanges = false;

  String _formatTimeOfDay(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+251 9'; // Pre-filled from authentication
    _addTextListeners();
  }

  void _addTextListeners() {
    _nameController.addListener(
      () => setState(() => _hasUnsavedChanges = true),
    );
    _phoneController.addListener(
      () => setState(() => _hasUnsavedChanges = true),
    );
    _addressController.addListener(
      () => setState(() => _hasUnsavedChanges = true),
    );
    _districtController.addListener(
      () => setState(() => _hasUnsavedChanges = true),
    );
    _hourlyRateController.addListener(
      () => setState(() => _hasUnsavedChanges = true),
    );
    _descriptionController.addListener(
      () => setState(() => _hasUnsavedChanges = true),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _hourlyRateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Validation Methods
  bool get _isNameValid => _nameController.text.trim().length >= 3;
  bool get _isPhoneValid =>
      _phoneController.text.replaceAll(' ', '').length >= 13;
  bool get _isStep1Valid =>
      _isNameValid && _isPhoneValid && _profileImagePath != null;
  bool get _isStep2Valid =>
      _selectedCategory != null && _selectedSpecializations.isNotEmpty;
  bool get _isStep3Valid =>
      _addressController.text.trim().isNotEmpty &&
      _districtController.text.trim().isNotEmpty &&
      _hourlyRateController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().length >= 50;

  bool get _canProceed {
    switch (_currentStep) {
      case 1:
        return _isStep1Valid;
      case 2:
        return _isStep2Valid;
      case 3:
        return _isStep3Valid;
      default:
        return false;
    }
  }

  // Image Selection
  Future<void> _selectProfileImage() async {
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                size: 6.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                size: 6.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
          _hasUnsavedChanges = true;
        });
      }
    }
  }

  // Location Detection
  Future<void> _detectLocation() async {
    // Simulate GPS detection
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLocationDetected = true;
      _addressController.text = 'Bole Road, Near Edna Mall';
      _districtController.text = 'Bole';
      _hasUnsavedChanges = true;
    });
  }

  // Navigation Methods
  void _nextStep() {
    if (_canProceed && _currentStep < _totalSteps) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _handleBackNavigation() async {
    if (_hasUnsavedChanges) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to leave?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave'),
            ),
          ],
        ),
      );

      if (shouldLeave == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitRegistration() async {
    if (!_isStep3Valid) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue')),
      );
      return;
    }

    final theme = Theme.of(context);
    try {
      final workingSchedule = <String, dynamic>{};
      for (final day in _workingDays.keys) {
        final enabled = _workingDays[day] ?? false;
        workingSchedule[day] = {
          'enabled': enabled,
          'start': _formatTimeOfDay(
            _startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0),
          ),
          'end': _formatTimeOfDay(
            _endTimes[day] ?? const TimeOfDay(hour: 17, minute: 0),
          ),
        };
      }

      final applicationRef = FirebaseFirestore.instance
          .collection('provider_applications')
          .doc(user.uid);

      await applicationRef.set({
        'uid': user.uid,
        'email': user.email,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'selectedCategory': _selectedCategory,
        'specializations': List<String>.from(_selectedSpecializations),
        'yearsOfExperience': _yearsOfExperience,
        'serviceRadiusKm': _serviceRadius,
        'address': _addressController.text.trim(),
        'district': _districtController.text.trim(),
        'hourlyRate': _hourlyRateController.text.trim(),
        'description': _descriptionController.text.trim(),
        // NOTE: This is a local device path; for real apps upload to Storage and store a download URL.
        'profileImagePath': _profileImagePath,
        'workingSchedule': workingSchedule,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': 'customer',
        'providerApplicationStatus': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => _hasUnsavedChanges = false);

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                size: 8.w,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 3.w),
              const Text('Registration Submitted'),
            ],
          ),
          content: const Text(
            'Your provider profile has been submitted for verification. We will review your information and notify you within 24-48 hours.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacementNamed(
                  context,
                  '/service-categories-screen',
                );
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              size: 6.w,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: _handleBackNavigation,
          ),
          title: Text(
            'Provider Registration',
            style: theme.textTheme.titleLarge,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Center(
                child: Text(
                  'Step $_currentStep of $_totalSteps',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: List.generate(_totalSteps, (index) {
                    final stepNumber = index + 1;
                    final isCompleted = stepNumber < _currentStep;
                    final isCurrent = stepNumber == _currentStep;

                    return Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 0.5.h,
                              decoration: BoxDecoration(
                                color: isCompleted || isCurrent
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                                borderRadius: BorderRadius.circular(1.w),
                              ),
                            ),
                          ),
                          if (index < _totalSteps - 1) SizedBox(width: 2.w),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 1) ...[
                        PersonalInfoSection(
                          nameController: _nameController,
                          phoneController: _phoneController,
                          profileImagePath: _profileImagePath,
                          onImageSelect: _selectProfileImage,
                          isNameValid: _isNameValid,
                          isPhoneValid: _isPhoneValid,
                        ),
                      ] else if (_currentStep == 2) ...[
                        BusinessDetailsSection(
                          selectedCategory: _selectedCategory,
                          selectedSpecializations: _selectedSpecializations,
                          yearsOfExperience: _yearsOfExperience,
                          onCategoryChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _selectedSpecializations.clear();
                              _hasUnsavedChanges = true;
                            });
                          },
                          onSpecializationToggle: (spec) {
                            setState(() {
                              if (_selectedSpecializations.contains(spec)) {
                                _selectedSpecializations.remove(spec);
                              } else {
                                _selectedSpecializations.add(spec);
                              }
                              _hasUnsavedChanges = true;
                            });
                          },
                          onExperienceChanged: (value) {
                            setState(() {
                              _yearsOfExperience = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                      ] else if (_currentStep == 3) ...[
                        LocationSection(
                          addressController: _addressController,
                          districtController: _districtController,
                          serviceRadius: _serviceRadius,
                          isLocationDetected: _isLocationDetected,
                          onDetectLocation: _detectLocation,
                          onRadiusChanged: (value) {
                            setState(() {
                              _serviceRadius = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        SizedBox(height: 2.h),
                        WorkingHoursSection(
                          workingDays: _workingDays,
                          startTimes: _startTimes,
                          endTimes: _endTimes,
                          onDayToggle: (day, value) {
                            setState(() {
                              _workingDays[day] = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                          onStartTimeChanged: (day, time) {
                            setState(() {
                              _startTimes[day] = time;
                              _hasUnsavedChanges = true;
                            });
                          },
                          onEndTimeChanged: (day, time) {
                            setState(() {
                              _endTimes[day] = time;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                        SizedBox(height: 2.h),
                        PricingDescriptionSection(
                          hourlyRateController: _hourlyRateController,
                          descriptionController: _descriptionController,
                          descriptionCharCount:
                              _descriptionController.text.length,
                          maxDescriptionLength: 500,
                        ),
                      ],
                      SizedBox(height: 3.h),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      if (_currentStep > 1) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            child: const Text('Back'),
                          ),
                        ),
                        SizedBox(width: 3.w),
                      ],
                      Expanded(
                        flex: _currentStep > 1 ? 1 : 1,
                        child: ElevatedButton(
                          onPressed: _canProceed
                              ? (_currentStep == _totalSteps
                                    ? _submitRegistration
                                    : _nextStep)
                              : null,
                          child: Text(
                            _currentStep == _totalSteps ? 'Submit' : 'Continue',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
