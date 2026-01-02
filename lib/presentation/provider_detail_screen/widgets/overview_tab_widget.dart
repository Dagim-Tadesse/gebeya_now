import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Overview tab displaying service description, specializations, experience, and pricing
class OverviewTabWidget extends StatelessWidget {
  final Map<String, dynamic> provider;

  const OverviewTabWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service description
          Text(
            "About",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            provider["description"] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: 3.h),
          // Specializations
          Text(
            "Specializations",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: (provider["specializations"] as List)
                .map(
                  (spec) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      spec as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 3.h),
          // Experience and pricing
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  theme,
                  "Experience",
                  "${provider["yearsOfExperience"]} years",
                  'work_history',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildInfoCard(
                  context,
                  theme,
                  "Starting Price",
                  provider["startingPrice"] as String,
                  'payments',
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Working hours
          Text(
            "Working Hours",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider["workingHours"] as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: (provider["isAvailable"] as bool)
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                      child: Text(
                        (provider["isAvailable"] as bool)
                            ? "Open Now"
                            : "Closed",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: (provider["isAvailable"] as bool)
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!(provider["isAvailable"] as bool)) ...[
                  SizedBox(height: 1.h),
                  Text(
                    "Next available: ${provider["nextAvailable"]}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 3.h),
          // Verification badges
          Text(
            "Verification",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: (provider["verificationBadges"] as List)
                .map(
                  (badge) => _buildVerificationBadge(
                    context,
                    theme,
                    (badge as Map<String, dynamic>)["label"] as String,
                    (badge)["icon"] as String,
                    (badge)["verified"] as bool,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    String iconName,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(
    BuildContext context,
    ThemeData theme,
    String label,
    String iconName,
    bool verified,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: verified
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: verified
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: verified
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: verified
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: verified ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
