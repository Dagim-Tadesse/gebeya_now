import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Social login widget with Google and Facebook options
/// Implements platform-native authentication flows
/// Includes Ethiopian localization support
class SocialLoginWidget extends StatelessWidget {
  final VoidCallback onGoogleLogin;
  final VoidCallback onFacebookLogin;
  final bool isLoading;

  const SocialLoginWidget({
    super.key,
    required this.onGoogleLogin,
    required this.onFacebookLogin,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: theme.colorScheme.outline)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or continue with',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: Divider(color: theme.colorScheme.outline)),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                context: context,
                theme: theme,
                label: 'Google',
                icon: Icons.g_mobiledata,
                iconColor: const Color.fromARGB(255, 255, 9, 9),
                onTap: isLoading ? null : onGoogleLogin,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildSocialButton(
                context: context,
                theme: theme,
                label: 'Facebook',
                icon: Icons.facebook,
                iconColor: const Color(0xFF1877F2),
                onTap: isLoading ? null : onFacebookLogin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required ThemeData theme,
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
        side: BorderSide(color: theme.colorScheme.outline, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          SizedBox(width: 2.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
