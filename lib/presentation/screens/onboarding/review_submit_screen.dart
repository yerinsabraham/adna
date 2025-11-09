import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../utils/helpers.dart';
import '../../../utils/formatters.dart';
import '../../providers/merchant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import 'pending_approval_screen.dart';

/// Review and submit screen - Step 5 of onboarding
class ReviewSubmitScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ReviewSubmitScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends State<ReviewSubmitScreen> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await merchantProvider.submitOnboarding(
      authProvider.user!.uid,
      authProvider.user!.email!,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      // Refresh merchant data
      await authProvider.refreshMerchantData();

      if (!mounted) return;

      // Navigate to pending approval screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
      );
    } else {
      Helpers.showError(
        context,
        merchantProvider.errorMessage ?? 'Failed to submit application',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, _) {
        final data = merchantProvider.onboardingData;

        if (_isSubmitting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingIndicator(),
                SizedBox(height: 24),
                Text('Submitting your application...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Review your information',
                style: AppTextStyles.subtitle1,
              ),
              const SizedBox(height: 8),
              Text(
                'Please review all details before submitting',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 24),
              // Business Information
              _buildSection(
                'Business Information',
                [
                  _buildItem('Business Name', data['businessName']),
                  if (data['tradingName']?.isNotEmpty ?? false)
                    _buildItem('Trading Name', data['tradingName']),
                  _buildItem('Business Type', data['businessType']),
                  _buildItem('Industry', data['industry']),
                  _buildItem('CAC Number', data['cacNumber']),
                  _buildItem('TIN', data['taxId']),
                  _buildItem('Phone', data['businessPhone']),
                  _buildItem('Email', data['businessEmail']),
                  if (data['website']?.isNotEmpty ?? false)
                    _buildItem('Website', data['website']),
                ],
              ),
              const SizedBox(height: 24),
              // Owner Information
              _buildSection(
                'Owner Information',
                [
                  _buildItem(
                    'Full Name',
                    '${data['ownerFirstName']} ${data['ownerLastName']}',
                  ),
                  _buildItem('Phone', data['ownerPhone']),
                  _buildItem('Email', data['ownerEmail']),
                  _buildItem('BVN', '***${data['ownerBvn']?.substring(7)}'),
                  _buildItem('Date of Birth', data['ownerDob']),
                  _buildItem('Address', data['ownerAddress']),
                  _buildItem('City', data['ownerCity']),
                  _buildItem('State', data['ownerState']),
                ],
              ),
              const SizedBox(height: 24),
              // Bank Account
              _buildSection(
                'Bank Account',
                [
                  _buildItem('Bank', data['bankName']),
                  _buildItem('Account Number', data['bankAccountNumber']),
                  _buildItem('Account Name', data['bankAccountName']),
                ],
              ),
              const SizedBox(height: 24),
              // Documents
              _buildSection(
                'Documents',
                [
                  _buildDocumentItem('CAC Certificate', data['cacDocument'] != null),
                  _buildDocumentItem('Utility Bill', data['utilityBill'] != null),
                  _buildDocumentItem('Government ID', data['idCard'] != null),
                ],
              ),
              const SizedBox(height: 32),
              // Terms Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your application will be reviewed within 24-48 hours',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We will notify you via email once your account is approved',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Back',
                      onPressed: widget.onBack,
                      variant: ButtonType.secondary,
                      fullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Submit Application',
                      onPressed: _handleSubmit,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String label, bool uploaded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            uploaded ? Icons.check_circle : Icons.cancel,
            color: uploaded ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
