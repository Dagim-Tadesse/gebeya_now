import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';

import './widgets/login_form_widget.dart';
import './widgets/register_form_widget.dart';
import './widgets/social_login_widget.dart';

/// Authentication screen for user login and registration
/// Supports both customer and service provider authentication
/// Implements tabbed interface with phone/email login options
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAuthenticationSuccess(bool isProvider) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in first. Authentication required.'),
        ),
      );
      return;
    }

    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    // Navigate based on user type
    if (isProvider) {
      Navigator.pushReplacementNamed(context, '/provider-registration-screen');
    } else {
      Navigator.pushReplacementNamed(context, '/service-categories-screen');
    }
  }

  Future<void> _upsertUserProfile(
    User user, {
    String? fallbackRole,
    String? phone,
    String? serviceCategory,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await docRef.get();
    final existingData = snapshot.data() ?? {};
    final role =
        (existingData['role'] as String?) ?? fallbackRole ?? 'customer';

    final data = <String, dynamic>{
      'name': user.displayName ?? existingData['name'] ?? '',
      'email': user.email ?? existingData['email'] ?? '',
      'photoUrl': user.photoURL ?? existingData['photoUrl'],
      'phone': phone ?? existingData['phone'] ?? user.phoneNumber,
      'serviceCategory': serviceCategory ?? existingData['serviceCategory'],
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists || !existingData.containsKey('createdAt')) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(data, SetOptions(merge: true));
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 2.h),
                      _buildAppLogo(theme),
                      SizedBox(height: 4.h),
                      _buildTabBar(theme),
                      SizedBox(height: 3.h),
                      SizedBox(height: 50.h, child: _buildTabBarView()),
                      SizedBox(height: 2.h),
                      SocialLoginWidget(
                        onGoogleLogin: () => _handleSocialLogin('Google'),
                        onFacebookLogin: () => _handleSocialLogin('Facebook'),
                        isLoading: _isLoading,
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppLogo(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Center(
            child: Text(
              'GN',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'GebeyaNow',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Connect with Local Service Providers',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(2.w),
        ),
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Register'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        SingleChildScrollView(
          child: LoginFormWidget(
            onLoginSuccess: _handleAuthenticationSuccess,
            onLoadingChanged: _setLoading,
            isLoading: _isLoading,
          ),
        ),
        SingleChildScrollView(
          child: RegisterFormWidget(
            onRegisterSuccess: _handleAuthenticationSuccess,
            onLoadingChanged: _setLoading,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      if (provider == 'Google') {
        final googleSignIn = GoogleSignIn();

        // Force account chooser by clearing any cached Google session
        await googleSignIn.signOut();

        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Google sign-in was canceled.')),
            );
          }
          return;
        }

        final googleAuth = await googleUser.authentication;

        if (googleAuth.idToken == null) {
          throw FirebaseAuthException(
            code: 'missing-id-token',
            message: 'Google ID token missing from sign-in response.',
          );
        }

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _upsertUserProfile(user, fallbackRole: 'customer');
        }
      } else if (provider == 'Facebook') {
        final LoginResult result = await FacebookAuth.instance.login(
          permissions: ['email'],
        );

        if (result.status == LoginStatus.cancelled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Facebook sign-in was canceled.')),
            );
          }
          return;
        }

        if (result.status != LoginStatus.success ||
            result.accessToken == null) {
          throw FirebaseAuthException(
            code: 'facebook-login-failed',
            message: result.message ?? 'Unknown Facebook login error.',
          );
        }

        final credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _upsertUserProfile(user, fallbackRole: 'customer');
        }
      } else {
        // Fallback for any future providers
        await Future.delayed(const Duration(seconds: 1));
      }

      if (mounted) {
        _handleAuthenticationSuccess(false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider login failed: ${e.message ?? e.code}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider login failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }
}
