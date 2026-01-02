import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Business details section widget for provider registration
/// Handles service category, specializations, and experience
class BusinessDetailsSection extends StatelessWidget {
  final String? selectedCategory;
  final List<String> selectedSpecializations;
  final double yearsOfExperience;
  final Function(String?) onCategoryChanged;
  final Function(String) onSpecializationToggle;
  final Function(double) onExperienceChanged;

  const BusinessDetailsSection({
    super.key,
    required this.selectedCategory,
    required this.selectedSpecializations,
    required this.yearsOfExperience,
    required this.onCategoryChanged,
    required this.onSpecializationToggle,
    required this.onExperienceChanged,
  });

  static const List<String> serviceCategories = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Tailoring',
    'Tutoring',
    'House Cleaning',
    'Painting',
    'Appliance Repair',
    'Beauty Services',
    'Catering',
  ];

  static const Map<String, List<String>> specializationsByCategory = {
    'Plumbing': ['Pipe Repair', 'Installation', 'Drainage', 'Water Heater'],
    'Electrical': ['Wiring', 'Installation', 'Repair', 'Solar Setup'],
    'Carpentry': ['Furniture', 'Doors', 'Windows', 'Custom Work'],
    'Tailoring': [
      'Traditional Wear',
      'Modern Clothing',
      'Alterations',
      'Custom Design',
    ],
    'Tutoring': ['Math', 'Science', 'Languages', 'Computer Skills'],
    'House Cleaning': [
      'Deep Cleaning',
      'Regular Maintenance',
      'Move-in/out',
      'Office Cleaning',
    ],
    'Painting': ['Interior', 'Exterior', 'Decorative', 'Commercial'],
    'Appliance Repair': ['Refrigerator', 'Washing Machine', 'TV', 'AC'],
    'Beauty Services': ['Hair Styling', 'Makeup', 'Nails', 'Spa'],
    'Catering': ['Traditional Food', 'Modern Cuisine', 'Events', 'Daily Meals'],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableSpecializations = selectedCategory != null
        ? specializationsByCategory[selectedCategory] ?? []
        : <String>[];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // Service Category Dropdown
          Text(
            'Service Category *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: InputDecoration(
              hintText: 'Select your service category',
              suffixIcon: CustomIconWidget(
                iconName: 'arrow_drop_down',
                size: 6.w,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            items: serviceCategories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
            onChanged: onCategoryChanged,
          ),
          SizedBox(height: 2.h),

          // Specialization Tags
          if (selectedCategory != null) ...[
            Text(
              'Specializations *',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: availableSpecializations.map((spec) {
                final isSelected = selectedSpecializations.contains(spec);
                return FilterChip(
                  label: Text(spec),
                  selected: isSelected,
                  onSelected: (_) => onSpecializationToggle(spec),
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                  checkmarkColor: theme.colorScheme.primary,
                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 2.h),
          ],

          // Years of Experience Slider
          Text(
            'Years of Experience: ${yearsOfExperience.toInt()} years',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Slider(
            value: yearsOfExperience,
            min: 0,
            max: 30,
            divisions: 30,
            label: '${yearsOfExperience.toInt()} years',
            onChanged: onExperienceChanged,
          ),
        ],
      ),
    );
  }
}
