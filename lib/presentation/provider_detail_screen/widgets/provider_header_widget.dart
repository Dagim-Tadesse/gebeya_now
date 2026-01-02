import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Provider header widget displaying profile photo, name, category, and rating
class ProviderHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderHeaderWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.w)),
      ),
      child: Column(
        children: [
          // Profile photo with availability status
          Stack(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 0.5.w,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: provider["profilePhoto"] as String,
                    width: 30.w,
                    height: 30.w,
                    fit: BoxFit.cover,
                    semanticLabel: provider["profilePhotoLabel"] as String,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: (provider["isAvailable"] as bool)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 0.3.w,
                    ),
                  ),
                  child: Text(
                    (provider["isAvailable"] as bool) ? "Available" : "Busy",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 9.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Provider name
          Text(
            provider["name"] as String,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          // Service category
          Text(
            provider["category"] as String,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          // Rating and reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'star',
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 1.w),
              Text(
                "${provider["rating"]}",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                "(${provider["reviewCount"]} reviews)",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
