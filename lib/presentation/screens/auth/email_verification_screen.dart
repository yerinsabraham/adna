import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';

/// Email verification screen
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _verificationCheckTimer;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationCheckTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  /// Periodically check if email has been verified
  void _startVerificationCheck() {
    _verificationCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.reloadUser();

        if (authProvider.isEmailVerified && mounted) {
          _verificationCheckTimer?.cancel();
          // Navigate to splash which will handle next screen
          Navigator.of(context).pushReplacementNamed('/splash');
        }
      },
    );
  }

  /// Send verification email
  Future<void> _sendVerificationEmail() async {
    if (_resendCountdown > 0) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.sendEmailVerification();

    if (!mounted) return;

    if (success) {
      Helpers.showSuccess(context, 'Verification email sent');
      _startResendCountdown();
    } else {
      Helpers.showError(
        context,
        authProvider.errorMessage ?? 'Failed to send verification email',
      );
    }
  }

  /// Start countdown before resend is allowed
  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_resendCountdown == 0) {
          timer.cancel();
          if (mounted) setState(() {});
        } else {
          if (mounted) {
            setState(() {
              _resendCountdown--;
            });
          }
        }
      },
    );
  }

  /// Manual refresh button
  Future<void> _checkVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.reloadUser();

    if (!mounted) return;

    if (authProvider.isEmailVerified) {
      Navigator.of(context).pushReplacementNamed('/splash');
    } else {
      Helpers.showInfo(
        context,
        'Email not yet verified. Please check your inbox and spam folder.',
      );
    }
  }

  /// Sign out
  Future<void> _handleSignOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      'Verify Your Email',
                      style: AppTextStyles.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      'We sent a verification email to:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Click the link in the email to verify your account. '
                      'Check your spam folder if you don\'t see it.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Auto-checking indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Checking verification status...',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Resend Button
                    CustomButton(
                      text: _resendCountdown > 0
                          ? 'Resend in $_resendCountdown seconds'
                          : 'Resend Verification Email',
                      onPressed: _resendCountdown > 0 ? null : _sendVerificationEmail,
                      variant: ButtonType.secondary,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 16),
                    // Manual Check Button
                    CustomButton(
                      text: 'I\'ve Verified My Email',
                      onPressed: _checkVerification,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
              // Sign Out
              TextButton(
                onPressed: _handleSignOut,
                child: Text(
                  'Sign Out',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
