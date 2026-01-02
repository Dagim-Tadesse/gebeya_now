import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Featured category widget for horizontal scrolling featured services
class FeaturedCategoryWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  const FeaturedCategoryWidget({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmergency = category['isEmergency'] == true;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40.w,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'FEATURED',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
                if (isEmergency)
                  Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'emergency',
                      color: theme.colorScheme.onError,
                      size: 12,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: category['icon'] as String,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              category['name'] as String,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              '${category['providerCount']} available',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
