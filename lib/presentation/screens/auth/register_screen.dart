import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../utils/validators.dart';
import '../../../utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'email_verification_screen.dart';

/// Registration screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      Helpers.showError(context, 'Please accept the Terms and Conditions');
      return;
    }

    Helpers.unfocus(context);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      // Skip email verification - go directly to splash for navigation
      Navigator.of(context).pushReplacementNamed('/splash');
    } else {
      Helpers.showError(
        context,
        authProvider.errorMessage ?? 'Registration failed',
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!_acceptedTerms) {
      Helpers.showError(context, 'Please accept the Terms and Conditions');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      // Google accounts are pre-verified, go to splash for navigation
      Navigator.of(context).pushReplacementNamed('/splash');
    } else {
      Helpers.showError(
        context,
        authProvider.errorMessage ?? 'Google sign-in failed',
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'ADNA TERMS AND CONDITIONS\n\n'
            '1. ACCOUNT REGISTRATION\n'
            'You must provide accurate business information during registration. '
            'All accounts are subject to KYC verification.\n\n'
            '2. SERVICES\n'
            'Adna provides cryptocurrency payment processing services for legitimate business transactions. '
            'You agree to use the service only for lawful purposes.\n\n'
            '3. FEES\n'
            'Transaction fees apply as displayed in the app. Fees are deducted from payment amounts before settlement. '
            'Network fees for crypto transactions are additional.\n\n'
            '4. COMPLIANCE\n'
            'You agree to comply with all applicable Nigerian and international laws, including AML/CFT regulations. '
            'You must maintain accurate transaction records.\n\n'
            '5. PROHIBITED ACTIVITIES\n'
            'Prohibited uses include: money laundering, terrorist financing, fraud, '
            'sale of prohibited goods, or any illegal activity.\n\n'
            '6. ACCOUNT SUSPENSION\n'
            'We reserve the right to suspend or terminate accounts that violate these terms or engage in suspicious activity.\n\n'
            '7. LIABILITY\n'
            'Adna is not liable for losses due to market volatility, network issues, or user error. '
            'You are responsible for securing your account credentials.\n\n'
            '8. DATA PRIVACY\n'
            'We collect and process personal and business data in accordance with Nigerian data protection laws. '
            'Your data is used to provide services and ensure compliance.\n\n'
            '9. MODIFICATIONS\n'
            'We may modify these terms at any time. Continued use constitutes acceptance of changes.\n\n'
            '10. CONTACT\n'
            'For support or questions, contact support@adna.ng\n\n'
            'By registering, you acknowledge that you have read and agree to these terms.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _navigateToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Create Account',
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Register your business with Adna',
                  style: AppTextStyles.subtitle1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your business email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,validator: Validators.email,
                ),
                const SizedBox(height: 20),
                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Create a strong password',
                  controller: _passwordController,
                  obscureText: true,validator: Validators.password,
                ),
                const SizedBox(height: 16),
                // Password Requirements
                _buildPasswordRequirements(),
                const SizedBox(height: 20),
                // Confirm Password Field
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: true,validator: (value) {
                    final error = Validators.required(value, 'Confirm Password');
                    if (error != null) return error;
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Terms Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptedTerms = !_acceptedTerms;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: AppTextStyles.bodyMedium,
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _showTermsAndConditions,
                                    child: const Text(
                                      'Terms and Conditions',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
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
                const SizedBox(height: 24),
                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'Register',
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                      fullWidth: true,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Divider with "OR"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                // Google Sign-In Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return OutlinedButton.icon(
                      onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
                      icon: Image.asset(
                        'assets/icons/google.png',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text('Sign up with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.border),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _navigateToLogin,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password must contain:',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem('At least 8 characters'),
          _buildRequirementItem('One uppercase letter'),
          _buildRequirementItem('One lowercase letter'),
          _buildRequirementItem('One number'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
