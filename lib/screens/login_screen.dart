import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF87CEEB), // Sky blue
              const Color(0xFF98FB98), // Light green
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle animated field pattern
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: 0.05,
                duration: const Duration(seconds: 3),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/field_pattern.png'), // Add this asset
                      repeat: ImageRepeat.repeat,
                      opacity: 0.1,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Enhanced Logo and Title
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: const Icon(
                            Icons.agriculture,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Harvestor Monitor',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Precision Agriculture at Your Fingertips',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Enhanced Login Card
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    Colors.white.withOpacity(0.95),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      // Enhanced Email Field
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: _getInputShadow(),
                                        ),
                                        child: TextFormField(
                                          controller: _emailCtrl,
                                          decoration: InputDecoration(
                                            labelText: 'Email Address',
                                            hintText: 'farmer@harvestor.com',
                                            prefixIcon: Icon(
                                              Icons.email_outlined,
                                              color: AppColors.textHint,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppColors.primary,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            contentPadding: const EdgeInsets.all(16),
                                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                                          ),
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                          ),
                                          validator: (v) => (v == null || !v.contains('@')) ? 'Please enter a valid email address' : null,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Enhanced Password Field
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: _getInputShadow(),
                                        ),
                                        child: TextFormField(
                                          controller: _passCtrl,
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            hintText: 'Enter your password',
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                              color: AppColors.textHint,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: AppColors.textHint,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
                                                });
                                              },
                                              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppColors.primary,
                                                width: 2,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            contentPadding: const EdgeInsets.all(16),
                                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                                          ),
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                          ),
                                          obscureText: _obscurePassword,
                                          validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Enhanced Error Display
                                      if (_error != null)
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppColors.error,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: AppColors.error,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _error!,
                                                  style: TextStyle(
                                                    color: AppColors.error,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 20),

                                      // Enhanced Sign In Button
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.3),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: FilledButton(
                                          onPressed: _loading ? null : () async {
                                            if (!_formKey.currentState!.validate()) return;
                                            setState(() { _loading = true; _error = null; });
                                            try {
                                              await auth.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text.trim());
                                            } catch (e) {
                                              setState(() { _error = 'Login failed. Please check your credentials.'; });
                                            } finally {
                                              if (mounted) setState(() { _loading = false; });
                                            }
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            child: _loading
                                                ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Signing In...',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.login,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Sign In',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Enhanced Forgot Password Link
                                      TextButton(
                                        onPressed: () async {
                                          if (_emailCtrl.text.isEmpty) {
                                            setState(() { _error = 'Please enter your email address first'; });
                                            return;
                                          }
                                          try {
                                            await auth.sendPasswordReset(_emailCtrl.text.trim());
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: AppColors.success,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Password reset email sent!',
                                                        style: TextStyle(color: AppColors.textPrimary),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: AppColors.success.withOpacity(0.1),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          } catch (_) {
                                            setState(() { _error = 'Failed to send reset email. Please try again.'; });
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.lock_reset,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Forgot password?',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Enhanced Divider
                                      Container(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.primary.withOpacity(0.2),
                                                      AppColors.primary,
                                                      AppColors.primary.withOpacity(0.2),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.primary.withOpacity(0.2),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.agriculture,
                                                    size: 16,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'OR',
                                                    style: TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.primary.withOpacity(0.2),
                                                      AppColors.primary,
                                                      AppColors.primary.withOpacity(0.2),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Enhanced Create Account Link
                                      TextButton(
                                        onPressed: _loading ? null : () async {
                                          if (!_formKey.currentState!.validate()) return;
                                          setState(() { _loading = true; _error = null; });
                                          try {
                                            await auth.signUpWithEmail(_emailCtrl.text.trim(), _passCtrl.text.trim());
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person_add,
                                                        color: AppColors.success,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Account created successfully! Welcome to Harvestor Monitor.',
                                                        style: TextStyle(color: AppColors.textPrimary),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: AppColors.success.withOpacity(0.1),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            setState(() { _error = 'Account creation failed. Please try again.'; });
                                          } finally {
                                            if (mounted) setState(() { _loading = false; });
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_add_alt_1,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Create new account',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Enhanced Google Sign-In Button
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: OutlinedButton(
                                          onPressed: _loading ? null : () async {
                                            setState(() { _loading = true; _error = null; });
                                            try {
                                              await auth.signInWithGoogle();
                                              // If successful, the auth state will change and the app will navigate
                                            } catch (e) {
                                              String errorMessage = 'Google sign-in failed. Please try again.';
                                              if (e.toString().contains('popup_closed_by_user') || e.toString().contains('canceled')) {
                                                errorMessage = 'Google sign-in was canceled. Please try again.';
                                              } else if (e.toString().contains('network')) {
                                                errorMessage = 'Network error. Please check your internet connection.';
                                              } else if (e.toString().contains('blocked') || e.toString().contains('denied')) {
                                                errorMessage = 'Google sign-in was blocked. Please allow popups and try again.';
                                              }
                                              setState(() { _error = errorMessage; });
                                            } finally {
                                              if (mounted) setState(() { _loading = false; });
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black87,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.login,
                                                size: 20,
                                                color: Colors.black87,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Continue with Google',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BoxShadow> _getInputShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        spreadRadius: 2,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
