import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Login form widget with phone/email and password fields
/// Supports Ethiopian phone number format (+251)
/// Includes password visibility toggle and forgot password link
class LoginFormWidget extends StatefulWidget {
  final Function(bool isProvider) onLoginSuccess;
  final Function(bool) onLoadingChanged;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.onLoginSuccess,
    required this.onLoadingChanged,
    required this.isLoading,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _usePhoneNumber = true;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return _usePhoneNumber
          ? 'የስልክ ቁጥር ያስፈልጋል (Phone number required)'
          : 'ኢሜይል ያስፈልጋል (Email required)';
    }

    if (_usePhoneNumber) {
      // Remove spaces and validate Ethiopian phone format
      final cleanPhone = value.replaceAll(' ', '');
      if (cleanPhone.length != 9 || !RegExp(r'^9\d{8}$').hasMatch(cleanPhone)) {
        return 'ትክክለኛ የስልክ ቁጥር ያስገቡ (Enter valid phone number)';
      }
    } else {
      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return 'ትክክለኛ ኢሜይል ያስገቡ (Enter valid email)';
      }
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'የይለፍ ቃል ያስፈልጋል (Password required)';
    }
    if (value.length < 6) {
      return 'የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት (Minimum 6 characters)';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _phoneError = _validatePhone(_phoneController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_phoneError != null || _passwordError != null) {
      return;
    }

    widget.onLoadingChanged(true);

    try {
      final password = _passwordController.text;
      String email = _phoneController.text.trim();
      String? lookupPhone;

      if (_usePhoneNumber) {
        final cleanPhone = _phoneController.text.replaceAll(' ', '').trim();
        final variants = <String>{
          '+251$cleanPhone',
          '0$cleanPhone',
          cleanPhone,
          '251$cleanPhone',
        }..removeWhere((v) => v.isEmpty);

        lookupPhone = '+251$cleanPhone';

        final match = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', whereIn: variants.toList())
            .limit(1)
            .get();

        if (!mounted) return;

        if (match.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No account found for this phone. Please register or use email.',
              ),
            ),
          );
          return;
        }

        email = (match.docs.first.data()['email'] as String?)?.trim() ?? '';
        if (email.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This phone is linked to an account without email. Use email login.',
              ),
            ),
          );
          return;
        }
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      var isProvider = false;

      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final snapshot = await docRef.get();
        final existing = snapshot.data() ?? {};
        final role = (existing['role'] as String?) ?? 'customer';

        await docRef.set({
          'name': user.displayName ?? existing['name'] ?? '',
          'email': user.email ?? existing['email'] ?? email,
          'photoUrl': user.photoURL ?? existing['photoUrl'],
          'phone': existing['phone'] ?? user.phoneNumber ?? lookupPhone,
          'serviceCategory': existing['serviceCategory'],
          'updatedAt': FieldValue.serverTimestamp(),
          if (!snapshot.exists || !existing.containsKey('createdAt'))
            'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        isProvider = role == 'provider';
      }

      HapticFeedback.mediumImpact();
      widget.onLoginSuccess(isProvider);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.message ?? e.code}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        widget.onLoadingChanged(false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final validationError = _validatePhone(_phoneController.text);
    if (validationError != null) {
      setState(() => _phoneError = validationError);
      return;
    }

    String email = _phoneController.text.trim();

    if (_usePhoneNumber) {
      final cleanPhone = _phoneController.text.replaceAll(' ', '').trim();
      final fullPhone = '+251$cleanPhone';

      final match = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: fullPhone)
          .limit(1)
          .get();

      if (!mounted) return;

      if (match.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No account found for this phone. Please register or use email.',
            ),
          ),
        );
        return;
      }

      email = (match.docs.first.data()['email'] as String?)?.trim() ?? '';
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This phone is linked to an account without email. Use email login.',
            ),
          ),
        );
        return;
      }
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent. Check your inbox.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: ${e.message ?? e.code}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reset failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLoginMethodToggle(theme),
          SizedBox(height: 2.h),
          _buildPhoneField(theme),
          SizedBox(height: 2.h),
          _buildPasswordField(theme),
          SizedBox(height: 1.h),
          _buildForgotPasswordLink(theme),
          SizedBox(height: 3.h),
          _buildLoginButton(theme),
        ],
      ),
    );
  }

  Widget _buildLoginMethodToggle(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _usePhoneNumber = true),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: BoxDecoration(
                color: _usePhoneNumber
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: _usePhoneNumber
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'phone',
                    color: _usePhoneNumber
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Phone',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: _usePhoneNumber
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: _usePhoneNumber
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _usePhoneNumber = false),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: BoxDecoration(
                color: !_usePhoneNumber
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: !_usePhoneNumber
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'email',
                    color: !_usePhoneNumber
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Email',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: !_usePhoneNumber
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: !_usePhoneNumber
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: _usePhoneNumber
              ? TextInputType.phone
              : TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: _usePhoneNumber ? 'Phone Number' : 'Email Address',
            hintText: _usePhoneNumber ? '9XX XXX XXX' : 'example@email.com',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_usePhoneNumber) ...[
                    Text(
                      '+251',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      width: 1,
                      height: 20,
                      color: theme.colorScheme.outline,
                    ),
                  ] else
                    CustomIconWidget(
                      iconName: 'email',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                ],
              ),
            ),
            errorText: _phoneError,
            errorMaxLines: 2,
          ),
          inputFormatters: _usePhoneNumber
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ]
              : null,
          onChanged: (value) {
            if (_phoneError != null) {
              setState(() => _phoneError = null);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              icon: CustomIconWidget(
                iconName: _obscurePassword ? 'visibility' : 'visibility_off',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            errorText: _passwordError,
            errorMaxLines: 3,
          ),
          onChanged: (value) {
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
          },
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: Text(
          'Forgot Password?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
      ),
      child: widget.isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Text(
              'Login',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
