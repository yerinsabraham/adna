import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';

/// Profile screen - view merchant profile
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: AppTextStyles.h5,
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final merchant = authProvider.merchant;

          if (merchant == null) {
            return const Center(child: LoadingIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Business Info
                _buildSection(
                  'Business Information',
                  [
                    _buildInfoRow('Business Name', merchant.businessName),
                    _buildInfoRow('CAC Number', merchant.cacNumber),
                    _buildInfoRow('TIN', merchant.tin),
                    _buildInfoRow('Category', merchant.category),
                    _buildInfoRow('Phone', merchant.businessPhone),
                    if (merchant.businessEmail != null)
                      _buildInfoRow('Email', merchant.businessEmail!),
                  ],
                ),
                const SizedBox(height: 16),
                // Owner Info
                _buildSection(
                  'Owner Information',
                  [
                    _buildInfoRow('Full Name', merchant.ownerName),
                    _buildInfoRow('Phone', merchant.ownerPhone),
                    _buildInfoRow('BVN/NIN', '***${merchant.bvnOrNin.substring(8)}'),
                    if (merchant.dateOfBirth != null)
                      _buildInfoRow('Date of Birth', merchant.dateOfBirth!),
                  ],
                ),
                const SizedBox(height: 16),
                // Address Info
                _buildSection(
                  'Address',
                  [
                    _buildInfoRow('Street', merchant.businessAddress.street),
                    _buildInfoRow('City', merchant.businessAddress.city),
                    _buildInfoRow('State', merchant.businessAddress.state),
                  ],
                ),
                const SizedBox(height: 16),
                // Bank Info
                _buildSection(
                  'Bank Account',
                  [
                    _buildInfoRow('Bank', merchant.bankName),
                    _buildInfoRow('Account Number', merchant.accountNumber),
                    _buildInfoRow('Account Name', merchant.accountName),
                    _buildInfoRow('Account Type', merchant.accountType.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 16),
                // Account Status
                _buildSection(
                  'Account Status',
                  [
                    _buildInfoRow('KYC Status', merchant.kycStatus.toUpperCase()),
                    _buildInfoRow('Tier', merchant.tier.toUpperCase()),
                    _buildInfoRow(
                      'Daily Limit',
                      Formatters.formatNaira(merchant.dailyLimit),
                    ),
                    _buildInfoRow(
                      'Monthly Limit',
                      Formatters.formatNaira(merchant.monthlyLimit),
                    ),
                    _buildInfoRow(
                      'Created',
                      Formatters.formatDateShort(merchant.createdAt),
                    ),
                    if (merchant.approvedAt != null)
                      _buildInfoRow(
                        'Approved',
                        Formatters.formatDateShort(merchant.approvedAt!),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
