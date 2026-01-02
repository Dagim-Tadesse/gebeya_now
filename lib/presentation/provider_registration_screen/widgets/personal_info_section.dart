import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Personal information section widget for provider registration
/// Handles name, phone, and profile photo upload
class PersonalInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String? profileImagePath;
  final VoidCallback onImageSelect;
  final bool isNameValid;
  final bool isPhoneValid;

  const PersonalInfoSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    this.profileImagePath,
    required this.onImageSelect,
    required this.isNameValid,
    required this.isPhoneValid,
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
            'Personal Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // Profile Photo Upload
          Center(
            child: GestureDetector(
              onTap: onImageSelect,
              child: Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: profileImagePath != null
                    ? ClipOval(
                        child: CustomImageWidget(
                          imageUrl: profileImagePath!,
                          width: 25.w,
                          height: 25.w,
                          fit: BoxFit.cover,
                          semanticLabel:
                              "Provider profile photo showing uploaded image",
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'add_a_photo',
                            size: 8.w,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Add Photo',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Full Name Field
          Text(
            'Full Name *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              suffixIcon: isNameValid
                  ? CustomIconWidget(
                      iconName: 'check_circle',
                      color: theme.colorScheme.primary,
                      size: 5.w,
                    )
                  : null,
            ),
          ),
          SizedBox(height: 2.h),

          // Phone Number Field
          Text(
            'Phone Number *',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+251 9XX XXX XXX',
              prefixText: '+251 ',
              suffixIcon: isPhoneValid
                  ? CustomIconWidget(
                      iconName: 'check_circle',
                      color: theme.colorScheme.primary,
                      size: 5.w,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
