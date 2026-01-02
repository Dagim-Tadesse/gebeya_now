import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Location section widget for provider registration
/// Handles GPS detection, manual address, service radius, and district
class LocationSection extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController districtController;
  final double serviceRadius;
  final bool isLocationDetected;
  final VoidCallback onDetectLocation;
  final Function(double) onRadiusChanged;

  const LocationSection({
    super.key,
    required this.addressController,
    required this.districtController,
    required this.serviceRadius,
    required this.isLocationDetected,
    required this.onDetectLocation,
    required this.onRadiusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            'Location',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // GPS Detection Button
          OutlinedButton.icon(
            onPressed: onDetectLocation,
            icon: CustomIconWidget(
              iconName: isLocationDetected ? 'check_circle' : 'my_location',
              size: 5.w,
              color: isLocationDetected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            label: Text(
              isLocationDetected ? 'Location Detected' : 'Detect My Location',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 6.h),
              side: BorderSide(
                color: isLocationDetected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Manual Address Field
          Text(
            'Address *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Enter your business address',
            ),
          ),
          SizedBox(height: 2.h),

          // District/Kebele Field
          Text(
            'District/Kebele *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: districtController,
            decoration: const InputDecoration(
              hintText: 'e.g., Bole, Kirkos, Yeka',
            ),
          ),
          SizedBox(height: 2.h),

          // Service Radius Slider
          Text(
            'Service Radius: ${serviceRadius.toInt()} km',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Slider(
            value: serviceRadius,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${serviceRadius.toInt()} km',
            onChanged: onRadiusChanged,
          ),
          Text(
            'How far are you willing to travel for service?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
