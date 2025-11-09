import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';

/// Pending approval screen
/// Shown after KYC submission while waiting for admin approval
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _checkStatus(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshMerchantData();

    if (!context.mounted) return;

    final kycStatus = authProvider.kycStatus;

    if (kycStatus == 'approved') {
      Helpers.showSuccess(context, 'Your account has been approved!');
      Navigator.of(context).pushReplacementNamed('/splash');
    } else if (kycStatus == 'rejected') {
      Helpers.showError(
        context,
        'Your application was rejected. Please contact support.',
      );
    } else {
      Helpers.showInfo(
        context,
        'Your application is still under review',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    // Clock Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hourglass_empty,
                        size: 60,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      'Application Under Review',
                      style: AppTextStyles.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      'Thank you for submitting your merchant application!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _buildInfoItem(
                            Icons.access_time,
                            'Review Time',
                            '24-48 hours',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoItem(
                            Icons.email_outlined,
                            'Notification',
                            'We\'ll email you when approved',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoItem(
                            Icons.support_agent,
                            'Need Help?',
                            'Contact support@adna.ng',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Refresh Status Button
                    CustomButton(
                      text: 'Check Status',
                      onPressed: () => _checkStatus(context),
                      variant: ButtonType.secondary,
                      fullWidth: true,
                      icon: Icons.refresh,
                    ),
                  ],
                ),
              ),
              // Sign Out Button
              CustomButton(
                text: 'Sign Out',
                onPressed: () => _handleSignOut(context),
                variant: ButtonType.text,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
