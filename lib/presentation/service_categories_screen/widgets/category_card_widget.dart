import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Category card widget for displaying service categories
/// Supports both grid and list view modes
class CategoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isListView;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategoryCardWidget({
    super.key,
    required this.category,
    this.isListView = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmergency = category['isEmergency'] == true;

    if (isListView) {
      return _buildListCard(context, theme, isEmergency);
    }
    return _buildGridCard(context, theme, isEmergency);
  }

  Widget _buildGridCard(
    BuildContext context,
    ThemeData theme,
    bool isEmergency,
  ) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmergency
                ? theme.colorScheme.error.withValues(alpha: 0.3)
                : theme.colorScheme.outline,
            width: isEmergency ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isEmergency)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'emergency',
                      color: theme.colorScheme.onError,
                      size: 12,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '24/7',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: category['icon'] as String,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            SizedBox(height: 1.5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                category['name'] as String,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${category['providerCount']} providers',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(
    BuildContext context,
    ThemeData theme,
    bool isEmergency,
  ) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmergency
                ? theme.colorScheme.error.withValues(alpha: 0.3)
                : theme.colorScheme.outline,
            width: isEmergency ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: category['icon'] as String,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category['name'] as String,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isEmergency)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'emergency',
                                color: theme.colorScheme.onError,
                                size: 12,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '24/7',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    category['description'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${category['providerCount']} providers',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
