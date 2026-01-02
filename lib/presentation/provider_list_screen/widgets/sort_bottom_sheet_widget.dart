import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SortBottomSheetWidget extends StatelessWidget {
  final String currentSort;
  final Function(String) onSelect;

  const SortBottomSheetWidget({
    super.key,
    required this.currentSort,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortOptions = [
      {'label': 'Distance', 'icon': 'near_me'},
      {'label': 'Rating', 'icon': 'star'},
      {'label': 'Availability', 'icon': 'schedule'},
      {'label': 'Recently Joined', 'icon': 'new_releases'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort By',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Divider(color: theme.colorScheme.outline),

            // Sort options
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortOptions.length,
              itemBuilder: (context, index) {
                final option = sortOptions[index];
                final isSelected = currentSort == option['label'];

                return ListTile(
                  leading: CustomIconWidget(
                    iconName: option['icon'] as String,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  title: Text(
                    option['label'] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: theme.colorScheme.primary,
                          size: 24,
                        )
                      : null,
                  onTap: () => onSelect(option['label'] as String),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
