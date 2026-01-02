import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen for GebeyaNow - Ethiopian Hyperlocal Service Marketplace
/// Provides branded launch experience while initializing core services
/// Determines user navigation path based on authentication and onboarding status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isInitializing = true;
  String _initializationStatus = 'Initializing...';
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  /// Setup logo scale and fade animations
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  /// Initialize app services and determine navigation path
  Future<void> _initializeApp() async {
    try {
      // Simulate checking authentication status
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _initializationStatus = 'Loading services...');
      }

      // Simulate loading cached provider data
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _initializationStatus = 'Fetching categories...');
      }

      // Simulate fetching service categories
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _initializationStatus = 'Checking permissions...');
      }

      // Simulate checking GPS permissions
      await Future.delayed(const Duration(milliseconds: 400));

      // Wait for animation to complete
      await _animationController.forward();
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => _isInitializing = false);
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initializationStatus = 'Initialization failed';
        });
        _showRetryDialog();
      }
    }
  }

  /// Determine and navigate to appropriate screen
  void _navigateToNextScreen() {
    final bool isAuthenticated = FirebaseAuth.instance.currentUser != null;
    final bool hasCompletedOnboarding = _onboardingComplete ?? false;

    if (isAuthenticated) {
      // Authenticated users go directly to Service Categories
      Navigator.pushReplacementNamed(context, '/service-categories-screen');
    } else if (hasCompletedOnboarding) {
      // Returning users go to Service Categories with location prompt
      Navigator.pushReplacementNamed(context, '/service-categories-screen');
    } else {
      // New users see authentication/onboarding
      Navigator.pushReplacementNamed(context, '/authentication-screen');
    }
  }

  /// Show retry dialog on initialization failure
  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Connection Error', style: theme.textTheme.titleLarge),
          content: Text(
            'Unable to initialize the app. Please check your internet connection and try again.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isInitializing = true;
                  _initializationStatus = 'Retrying...';
                });
                _initializeApp();
              },
              child: Text(
                'Retry',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Set status bar style to match Ethiopian flag colors
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary, colorScheme.primaryContainer],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildAnimatedLogo(theme, colorScheme),
              const SizedBox(height: 24),
              _buildAppName(theme),
              const SizedBox(height: 8),
              _buildTagline(theme),
              const Spacer(flex: 2),
              _buildLoadingIndicator(theme, colorScheme),
              const SizedBox(height: 16),
              _buildStatusText(theme),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  /// Build animated logo with Ethiopian-inspired design
  Widget _buildAnimatedLogo(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'store',
                      size: 48,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GN',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build app name text
  Widget _buildAppName(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Text(
            'GebeyaNow',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        );
      },
    );
  }

  /// Build tagline text
  Widget _buildTagline(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value * 0.9,
          child: Text(
            'Find Local Services Instantly',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(ThemeData theme, ColorScheme colorScheme) {
    return _isInitializing
        ? SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.9),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  /// Build initialization status text
  Widget _buildStatusText(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _isInitializing ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Text(
        _initializationStatus,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
