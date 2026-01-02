import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Pricing and description section widget for provider registration
/// Handles hourly rate, service pricing, and business description
class PricingDescriptionSection extends StatelessWidget {
  final TextEditingController hourlyRateController;
  final TextEditingController descriptionController;
  final int descriptionCharCount;
  final int maxDescriptionLength;

  const PricingDescriptionSection({
    super.key,
    required this.hourlyRateController,
    required this.descriptionController,
    required this.descriptionCharCount,
    this.maxDescriptionLength = 500,
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
            'Pricing & Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // Hourly Rate Field
          Text(
            'Hourly Rate (ETB) *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: hourlyRateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter your hourly rate',
              prefixText: 'ETB ',
              suffixText: '/hour',
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'This is your base rate. You can adjust pricing for specific services.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),

          // Business Description Field
          Text(
            'Business Description *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            maxLength: maxDescriptionLength,
            decoration: InputDecoration(
              hintText:
                  'Describe your services, experience, and what makes you unique...',
              counterText: '$descriptionCharCount/$maxDescriptionLength',
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                size: 4.w,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'You can write in English or Amharic',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
