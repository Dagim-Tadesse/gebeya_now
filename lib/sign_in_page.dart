import 'package:flutter/material.dart';
import 'facebook_home_page.dart';
import 'auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  String? _error;
  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    setState(() => _error = null);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final cred = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      if (cred.user != null && mounted) {
        if (!_authService.isEmailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email not verified yet. Check your inbox or resend.',
              ),
            ),
          );
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FacebookHomePage()),
        );
      }
    } catch (e) {
      setState(() => _error = 'Sign-in failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1877F2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in or create account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign in with your email and password, or Google.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF65676B)),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Please enter an email';
                              final emailRegex = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );
                              if (!emailRegex.hasMatch(v)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleSubmit(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: const Color(0xFF1877F2),
                      ),
                      onPressed: _handleSubmit,
                      child: const Text('Sign In'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () async {
                        setState(() => _error = null);
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        try {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;
                          await _authService.registerWithEmail(
                            email: email,
                            password: password,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Account created. A verification link was sent to your email.',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => _error = 'Sign-up failed: $e');
                        }
                      },
                      child: const Text('Create Account'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        setState(() => _error = null);
                        final email = _emailController.text.trim();
                        if (email.isEmpty) {
                          setState(() => _error = 'Enter your email first');
                          return;
                        }
                        try {
                          await _authService.sendPasswordResetEmail(email);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reset link sent to your email.'),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => _error = 'Reset failed: $e');
                        }
                      },
                      child: const Text('Forgot password?'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                      onPressed: () async {
                        setState(() => _error = null);
                        try {
                          final cred = await _authService.signInWithGoogle();
                          if (cred != null && mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const FacebookHomePage(),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() => _error = 'Google sign-in failed: $e');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        try {
                          await _authService.sendVerificationEmail();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Verification link sent again.'),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(
                            () => _error = 'Send verification failed: $e',
                          );
                        }
                      },
                      child: const Text('Resend verification link'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
