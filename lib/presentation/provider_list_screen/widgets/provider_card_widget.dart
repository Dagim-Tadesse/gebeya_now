import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProviderCardWidget extends StatelessWidget {
  final Map<String, dynamic> provider;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onCallTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onLongPress;

  const ProviderCardWidget({
    super.key,
    required this.provider,
    required this.isFavorite,
    required this.onTap,
    required this.onCallTap,
    required this.onFavoriteTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFeatured = (provider["isFeatured"] as bool?) ?? false;
    final isEmergency = (provider["isEmergency"] as bool?) ?? false;
    final availability = (provider["availability"] as String?) ?? 'Offline';
    final avatarUrl = (provider["avatar"] as String?)?.trim();
    final semanticLabel = (provider["semanticLabel"] as String?)?.trim();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isFeatured
              ? Border.all(color: theme.colorScheme.secondary, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow,
              blurRadius: isFeatured ? 8 : 4,
              offset: Offset(0, isFeatured ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Featured badge
            if (isFeatured)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'star',
                      color: theme.colorScheme.onSecondary,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Featured Provider',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile photo
                      Stack(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: CustomImageWidget(
                                imageUrl:
                                    (avatarUrl == null || avatarUrl.isEmpty)
                                    ? null
                                    : avatarUrl,
                                width: 20.w,
                                height: 20.w,
                                fit: BoxFit.cover,
                                semanticLabel:
                                    (semanticLabel == null ||
                                        semanticLabel.isEmpty)
                                    ? null
                                    : semanticLabel,
                              ),
                            ),
                          ),
                          // Availability indicator
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 5.w,
                              height: 5.w,
                              decoration: BoxDecoration(
                                color: _getAvailabilityColor(
                                  availability,
                                  theme,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 4.w),

                      // Provider info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (provider["name"] as String?) ??
                                        'Unknown Provider',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: CustomIconWidget(
                                    iconName: isFavorite
                                        ? 'favorite'
                                        : 'favorite_border',
                                    color: isFavorite
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurfaceVariant,
                                    size: 24,
                                  ),
                                  onPressed: onFavoriteTap,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              (provider["specialization"] as String?) ??
                                  'General Services',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: theme.colorScheme.secondary,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${provider["rating"]}',
                                  // Rating stored as num; default to 0.0 if missing.
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '(${provider["reviewCount"] ?? 0})',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Location and distance
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          (provider["location"] as String?) ??
                              'Location not specified',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${provider["distance"]} km',
                          // Distance stored as num; default to 0 if missing.
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),

                  // Status and badges
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getAvailabilityColor(
                            availability,
                            theme,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          availability,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getAvailabilityColor(availability, theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isEmergency) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'emergency',
                                color: theme.colorScheme.error,
                                size: 12,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Emergency 24/7',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: onCallTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                          icon: CustomIconWidget(
                            iconName: 'phone',
                            color: theme.colorScheme.onPrimary,
                            size: 18,
                          ),
                          label: const Text('Call Now'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                          child: const Text('View'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvailabilityColor(String availability, ThemeData theme) {
    switch (availability) {
      case "Available":
        return const Color(0xFF2E7D32); // Success green
      case "Busy":
        return const Color(0xFFF57C00); // Warning orange
      case "Offline":
        return theme.colorScheme.onSurfaceVariant;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}
