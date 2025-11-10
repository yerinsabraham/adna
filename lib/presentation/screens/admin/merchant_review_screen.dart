import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../utils/formatters.dart';
import '../../../utils/helpers.dart';
import '../../../data/models/merchant.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_button.dart';

/// Merchant Review Screen - View and approve/reject applications
class MerchantReviewScreen extends StatefulWidget {
  const MerchantReviewScreen({super.key});

  @override
  State<MerchantReviewScreen> createState() => _MerchantReviewScreenState();
}

class _MerchantReviewScreenState extends State<MerchantReviewScreen> {
  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await adminProvider.loadPendingApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Review Applications'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadApplications,
        child: Consumer<AdminProvider>(
          builder: (context, adminProvider, _) {
            if (adminProvider.isLoading && adminProvider.pendingMerchants.isEmpty) {
              return const Center(child: LoadingIndicator());
            }

            if (adminProvider.pendingMerchants.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Pending Applications',
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All applications have been reviewed',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.pendingMerchants.length,
              itemBuilder: (context, index) {
                final merchant = adminProvider.pendingMerchants[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildMerchantApplicationCard(merchant),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMerchantApplicationCard(Merchant merchant) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showMerchantDetails(merchant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.store,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant.businessName,
                          style: AppTextStyles.subtitle1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          merchant.ownerName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Pending',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Details
              _buildInfoRow('Type', _getReadableRegistrationType(merchant.registrationType)),
              _buildInfoRow('Tier', merchant.tier),
              _buildInfoRow('Phone', merchant.businessPhone),
              _buildInfoRow('Email', merchant.businessEmail ?? merchant.email),
              _buildInfoRow(
                'Applied',
                Formatters.formatTimestamp(merchant.createdAt),
              ),
              const SizedBox(height: 16),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Reject',
                      onPressed: () => _handleReject(merchant),
                      variant: ButtonType.secondary,
                      fullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Approve',
                      onPressed: () => _handleApprove(merchant),
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getReadableRegistrationType(String type) {
    switch (type) {
      case 'individual':
        return 'Individual';
      case 'business_name':
        return 'Business Name';
      case 'limited_company':
        return 'Limited Company';
      default:
        return type;
    }
  }

  void _showMerchantDetails(Merchant merchant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Application Details',
                  style: AppTextStyles.h5,
                ),
                const SizedBox(height: 24),
                
                // Business Information
                _buildSection('Business Information', [
                  _buildDetailItem('Business Name', merchant.businessName),
                  _buildDetailItem('Category', merchant.category),
                  _buildDetailItem('CAC Number', merchant.cacNumber),
                  _buildDetailItem('TIN', merchant.tin),
                  _buildDetailItem('Phone', merchant.businessPhone),
                  _buildDetailItem('Email', merchant.businessEmail ?? merchant.email),
                  _buildDetailItem('Address', merchant.businessAddress.toString()),
                ]),
                const SizedBox(height: 24),

                // Owner Information
                _buildSection('Owner Information', [
                  _buildDetailItem('Owner Name', merchant.ownerName),
                  _buildDetailItem('Phone', merchant.ownerPhone),
                  _buildDetailItem('BVN/NIN', merchant.bvnOrNin),
                  _buildDetailItem('DOB', merchant.dateOfBirth ?? 'N/A'),
                  _buildDetailItem('ID Type', merchant.idType),
                  _buildDetailItem('Address', merchant.residentialAddress.toString()),
                ]),
                const SizedBox(height: 24),

                // Bank Account
                _buildSection('Bank Account', [
                  _buildDetailItem('Bank', merchant.bankName),
                  _buildDetailItem('Account Number', merchant.accountNumber),
                  _buildDetailItem('Account Name', merchant.accountName),
                  _buildDetailItem('Account Type', merchant.accountType),
                ]),
                const SizedBox(height: 24),

                // Tier & Limits
                _buildSection('Tier & Limits', [
                  _buildDetailItem('Registration Type', _getReadableRegistrationType(merchant.registrationType)),
                  _buildDetailItem('Tier', merchant.tier),
                  _buildDetailItem('Daily Limit', Formatters.formatNaira(merchant.dailyLimit, showDecimals: false)),
                  _buildDetailItem('Monthly Limit', Formatters.formatNaira(merchant.monthlyLimit, showDecimals: false)),
                ]),
                const SizedBox(height: 24),

                // Documents
                if (merchant.documents.isNotEmpty) ...[
                  _buildSection('Documents', [
                    ...merchant.documents.map((doc) => 
                      _buildDetailItem(doc.type, doc.fileName),
                    ),
                  ]),
                  const SizedBox(height: 24),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Reject Application',
                        onPressed: () {
                          Navigator.pop(context);
                          _handleReject(merchant);
                        },
                        variant: ButtonType.secondary,
                        fullWidth: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Approve Application',
                        onPressed: () {
                          Navigator.pop(context);
                          _handleApprove(merchant);
                        },
                        fullWidth: true,
                      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle1.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
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

  Future<void> _handleApprove(Merchant merchant) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Application'),
        content: Text('Approve ${merchant.businessName}\'s application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await adminProvider.approveMerchant(
        merchant.id,
        authProvider.user!.uid,
      );

      if (!mounted) return;

      if (success) {
        Helpers.showSuccess(context, 'Application approved successfully');
      } else {
        Helpers.showError(
          context,
          adminProvider.errorMessage ?? 'Failed to approve application',
        );
      }
    }
  }

  Future<void> _handleReject(Merchant merchant) async {
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject ${merchant.businessName}\'s application?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      final success = await adminProvider.rejectMerchant(
        merchant.id,
        reasonController.text.trim(),
        authProvider.user!.uid,
      );

      if (!mounted) return;

      if (success) {
        Helpers.showSuccess(context, 'Application rejected');
      } else {
        Helpers.showError(
          context,
          adminProvider.errorMessage ?? 'Failed to reject application',
        );
      }
    }

    reasonController.dispose();
  }
}
