import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Reviews tab displaying customer feedback with ratings and comments
class ReviewsTabWidget extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const ReviewsTabWidget({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return reviews.isEmpty
        ? Center(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'rate_review',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 64,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "No reviews yet",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        : ListView.separated(
            padding: EdgeInsets.all(4.w),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final review = reviews[index];
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
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          child: ClipOval(
                            child: CustomImageWidget(
                              imageUrl: review["customerPhoto"] as String,
                              width: 12.w,
                              height: 12.w,
                              fit: BoxFit.cover,
                              semanticLabel:
                                  review["customerPhotoLabel"] as String,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review["customerName"] as String,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                review["date"] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'star',
                              color: theme.colorScheme.secondary,
                              size: 18,
                            ),
                            SizedBox(width: 0.5.w),
                            Text(
                              "${review["rating"]}",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      review["comment"] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
