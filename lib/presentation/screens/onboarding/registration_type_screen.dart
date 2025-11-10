import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/merchant_provider.dart';
import '../../widgets/common/custom_button.dart';

/// Registration Type Selection - Step 0 of onboarding
/// Allows users to choose between Individual, Business Name, or Limited Company
class RegistrationTypeScreen extends StatefulWidget {
  final VoidCallback onNext;

  const RegistrationTypeScreen({
    super.key,
    required this.onNext,
  });

  @override
  State<RegistrationTypeScreen> createState() => _RegistrationTypeScreenState();
}

class _RegistrationTypeScreenState extends State<RegistrationTypeScreen> {
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    final data = merchantProvider.onboardingData;
    setState(() {
      _selectedType = data['registrationType'];
    });
  }

  void _handleNext() {
    if (_selectedType == null) {
      return;
    }

    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    
    // Get tier and limits for selected registration type
    final regTypeInfo = AppConstants.businessRegistrationTypes[_selectedType]!;
    final tier = regTypeInfo['tier'] as String;
    final tierDetails = AppConstants.getTierDetails(tier);

    // Save registration type and tier information
    merchantProvider.updateOnboardingSection({
      'registrationType': _selectedType,
      'tier': tier,
      'dailyLimit': (tierDetails['dailyLimit'] as num).toDouble(),
      'monthlyLimit': (tierDetails['monthlyLimit'] as num).toDouble(),
    });

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Choose Your Account Type',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Text(
            'Select the option that best describes your business',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Registration Type Options
          ...AppConstants.businessRegistrationTypes.entries.map((entry) {
            final type = entry.key;
            final info = entry.value;
            final isSelected = _selectedType == type;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RegistrationTypeCard(
                icon: info['icon'],
                title: info['label'],
                description: info['description'],
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedType = type;
                  });
                },
              ),
            );
          }).toList(),

          const SizedBox(height: 32),

          // Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your account type determines your transaction limits. You can upgrade later by providing additional business documents.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Continue Button
          CustomButton(
            text: 'Continue',
            onPressed: _selectedType != null ? _handleNext : null,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

/// Registration Type Card Widget
class _RegistrationTypeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegistrationTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.1) 
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title and Radio
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.subtitle1.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                // Radio Button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
