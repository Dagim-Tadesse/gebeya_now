import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Gallery tab displaying service photos in scrollable grid
class GalleryTabWidget extends StatelessWidget {
  final List<Map<String, dynamic>> galleryImages;

  const GalleryTabWidget({super.key, required this.galleryImages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return galleryImages.isEmpty
        ? Center(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'photo_library',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 64,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "No photos available",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        : GridView.builder(
            padding: EdgeInsets.all(4.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 3.w,
              childAspectRatio: 1,
            ),
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              final image = galleryImages[index];
              return GestureDetector(
                onTap: () => _showImageDialog(context, image),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.w),
                    child: CustomImageWidget(
                      imageUrl: image["url"] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      semanticLabel: image["semanticLabel"] as String,
                    ),
                  ),
                ),
              );
            },
          );
  }

  void _showImageDialog(BuildContext context, Map<String, dynamic> image) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: 70.h, maxWidth: 90.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.w),
                child: CustomImageWidget(
                  imageUrl: image["url"] as String,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  semanticLabel: image["semanticLabel"] as String,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onPrimary,
                size: 32,
              ),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surface,
                shape: CircleBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
