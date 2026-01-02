import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final double locationRadius;
  final String availabilityFilter;
  final double ratingThreshold;
  final RangeValues priceRange;
  final Function(double, String, double, RangeValues) onApply;
  final VoidCallback onReset;

  const FilterBottomSheetWidget({
    super.key,
    required this.locationRadius,
    required this.availabilityFilter,
    required this.ratingThreshold,
    required this.priceRange,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late double _locationRadius;
  late String _availabilityFilter;
  late double _ratingThreshold;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _locationRadius = widget.locationRadius;
    _availabilityFilter = widget.availabilityFilter;
    _ratingThreshold = widget.ratingThreshold;
    _priceRange = widget.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Providers',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onReset,
                      child: const Text('Reset All'),
                    ),
                  ],
                ),
              ),
              Divider(color: theme.colorScheme.outline),
              SizedBox(height: 2.h),

              // Location radius
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Location Radius',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '${_locationRadius.toStringAsFixed(1)} km',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Slider(
                      value: _locationRadius,
                      min: 1.0,
                      max: 20.0,
                      divisions: 19,
                      label: '${_locationRadius.toStringAsFixed(1)} km',
                      onChanged: (value) {
                        setState(() => _locationRadius = value);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // Availability status
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability Status',
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: ['All', 'Available', 'Busy', 'Offline'].map((
                        status,
                      ) {
                        final isSelected = _availabilityFilter == status;
                        return FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _availabilityFilter = status);
                          },
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: theme.colorScheme.primaryContainer,
                          labelStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // Rating threshold
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Minimum Rating',
                          style: theme.textTheme.titleMedium,
                        ),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'star',
                              color: theme.colorScheme.secondary,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              _ratingThreshold > 0
                                  ? _ratingThreshold.toStringAsFixed(1)
                                  : 'Any',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Slider(
                      value: _ratingThreshold,
                      min: 0.0,
                      max: 5.0,
                      divisions: 10,
                      label: _ratingThreshold > 0
                          ? _ratingThreshold.toStringAsFixed(1)
                          : 'Any',
                      onChanged: (value) {
                        setState(() => _ratingThreshold = value);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // Price range
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price Range (ETB)',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '${_priceRange.start.toInt()} - ${_priceRange.end.toInt()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      labels: RangeLabels(
                        '${_priceRange.start.toInt()}',
                        '${_priceRange.end.toInt()}',
                      ),
                      onChanged: (values) {
                        setState(() => _priceRange = values);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Action buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(
                            _locationRadius,
                            _availabilityFilter,
                            _ratingThreshold,
                            _priceRange,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
