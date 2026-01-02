import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Registration form widget for new users
/// Supports both customer and service provider registration
/// Includes service category selection for providers
class RegisterFormWidget extends StatefulWidget {
  final Function(bool isProvider) onRegisterSuccess;
  final Function(bool) onLoadingChanged;
  final bool isLoading;

  const RegisterFormWidget({
    super.key,
    required this.onRegisterSuccess,
    required this.onLoadingChanged,
    required this.isLoading,
  });

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isProvider = false;
  String? _selectedCategory;
  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final List<String> _serviceCategories = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Tailoring',
    'Tutoring',
    'Cleaning',
    'Painting',
    'Gardening',
    'Appliance Repair',
    'Beauty Services',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'ስም ያስፈልጋል (Name required)';
    }
    if (value.length < 3) {
      return 'ስም ቢያንስ 3 ቁምፊዎች መሆን አለበት (Minimum 3 characters)';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'የስልክ ቁጥር ያስፈልጋል (Phone number required)';
    }
    final cleanPhone = value.replaceAll(' ', '');
    if (cleanPhone.length != 9 || !RegExp(r'^9\d{8}$').hasMatch(cleanPhone)) {
      return 'ትክክለኛ የስልክ ቁጥር ያስገቡ (Enter valid phone number)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'ኢሜይል ያስፈልጋል (Email required)';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'ትክክለኛ ኢሜይል ያስገቡ (Enter valid email)';
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'የይለፍ ቃል ማረጋገጫ ያስፈልጋል (Confirm password required)';
    }
    if (value != _passwordController.text) {
      return 'የይለፍ ቃሎች አይዛመዱም (Passwords do not match)';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    setState(() {
      _nameError = _validateName(_nameController.text);
      _phoneError = _validatePhone(_phoneController.text);
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(
        _confirmPasswordController.text,
      );
    });

    if (_nameError != null ||
        _phoneError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    if (_isProvider && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a service category'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    widget.onLoadingChanged(true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await credential.user?.updateDisplayName(_nameController.text.trim());

      HapticFeedback.mediumImpact();
      widget.onRegisterSuccess(_isProvider);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.message ?? e.code}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration failed. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNameField(theme),
          SizedBox(height: 2.h),
          _buildPhoneField(theme),
          SizedBox(height: 2.h),
          _buildEmailField(theme),
          SizedBox(height: 2.h),
          _buildPasswordField(theme),
          SizedBox(height: 2.h),
          _buildConfirmPasswordField(theme),
          SizedBox(height: 2.h),
          _buildProviderCheckbox(theme),
          if (_isProvider) ...[
            SizedBox(height: 2.h),
            _buildCategoryDropdown(theme),
          ],
          SizedBox(height: 3.h),
          _buildRegisterButton(theme),
        ],
      ),
    );
  }

  Widget _buildNameField(ThemeData theme) {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'person',
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        errorText: _nameError,
        errorMaxLines: 2,
      ),
      onChanged: (value) {
        if (_nameError != null) {
          setState(() => _nameError = null);
        }
      },
    );
  }

  Widget _buildPhoneField(ThemeData theme) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '9XX XXX XXX',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+251',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 2.w),
              Container(width: 1, height: 20, color: theme.colorScheme.outline),
            ],
          ),
        ),
        errorText: _phoneError,
        errorMaxLines: 2,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      onChanged: (value) {
        if (_phoneError != null) {
          setState(() => _phoneError = null);
        }
      },
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'example@email.com',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'email',
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        errorText: _emailError,
        errorMaxLines: 2,
      ),
      onChanged: (value) {
        if (_emailError != null) {
          setState(() => _emailError = null);
        }
      },
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Minimum 6 characters',
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
        errorMaxLines: 2,
      ),
      onChanged: (value) {
        if (_passwordError != null) {
          setState(() => _passwordError = null);
        }
      },
    );
  }

  Widget _buildConfirmPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
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
            iconName: _obscureConfirmPassword ? 'visibility' : 'visibility_off',
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
        ),
        errorText: _confirmPasswordError,
        errorMaxLines: 2,
      ),
      onChanged: (value) {
        if (_confirmPasswordError != null) {
          setState(() => _confirmPasswordError = null);
        }
      },
      onFieldSubmitted: (_) => _handleRegister(),
    );
  }

  Widget _buildProviderCheckbox(ThemeData theme) {
    return InkWell(
      onTap: () => setState(() => _isProvider = !_isProvider),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: _isProvider,
              onChanged: (value) =>
                  setState(() => _isProvider = value ?? false),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Register as Service Provider',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Service Category',
        hintText: 'Select your service category',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'work',
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
      items: _serviceCategories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value);
      },
    );
  }

  Widget _buildRegisterButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : _handleRegister,
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
              'Register',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
