import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';
import '../onboarding/onboarding_wrapper.dart';
import '../onboarding/pending_approval_screen.dart';
import '../dashboard/dashboard_screen.dart';

/// Splash screen - app entry point
/// Checks authentication state and navigates accordingly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  /// Check authentication state and navigate
  Future<void> _checkAuthState() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Not logged in → Login
    if (!authProvider.isLoggedIn) {
      if (!mounted) return;
      _navigateToLogin();
      return;
    }

    // SKIP EMAIL VERIFICATION FOR TESTING
    // Users can proceed without email verification during development

    // Check if merchant profile exists
    final merchantExists = await authProvider.checkMerchantExists();

    if (!mounted) return;

    if (!merchantExists) {
      // No merchant profile → Onboarding
      _navigateToOnboarding();
      return;
    }

    // Refresh merchant data
    await authProvider.refreshMerchantData();

    if (!mounted) return;

    // Check KYC status
    final kycStatus = authProvider.kycStatus;

    if (kycStatus == 'pending') {
      // KYC pending → Pending Approval Screen
      _navigateToPendingApproval();
    } else if (kycStatus == 'approved') {
      // KYC approved → Dashboard
      _navigateToDashboard();
    } else if (kycStatus == 'rejected') {
      // KYC rejected → Show rejection reason and allow resubmission
      // For now, navigate to pending approval screen
      _navigateToPendingApproval();
    } else {
      // Unknown status → Onboarding
      _navigateToOnboarding();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _navigateToEmailVerification() {
    Navigator.of(context).pushReplacementNamed('/email-verification');
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  void _navigateToPendingApproval() {
    Navigator.of(context).pushReplacementNamed('/pending-approval');
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Container(
          width: 180,
          height: 180,
          padding: const EdgeInsets.all(20),
          child: Image.asset(
            'assets/icons/app logo qr.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
