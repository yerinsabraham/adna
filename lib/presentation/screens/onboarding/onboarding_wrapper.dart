import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../providers/merchant_provider.dart';
import 'registration_type_screen.dart';
import 'business_info_screen.dart';
import 'owner_info_screen.dart';
import 'bank_account_screen.dart';
import 'documents_upload_screen.dart';
import 'review_submit_screen.dart';

/// Onboarding wrapper - manages multi-step KYC flow
class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<String> _stepTitles = [
    'Account Type',
    'Business Information',
    'Owner Information',
    'Bank Account',
    'Documents Upload',
    'Review & Submit',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _shouldSkipDocuments() {
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    final registrationType = merchantProvider.onboardingData['registrationType'];
    // Only Tier 3 (limited_company) needs to upload documents
    return registrationType != 'limited_company';
  }

  void _nextStep() {
    // Skip documents screen for Tier 1 and Tier 2
    if (_currentStep == 3 && _shouldSkipDocuments()) {
      // Jump from Bank Account (step 3) to Review & Submit (step 5)
      setState(() {
        _currentStep = 5;
      });
      _pageController.animateToPage(
        5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    // Skip documents screen backwards for Tier 1 and Tier 2
    if (_currentStep == 5 && _shouldSkipDocuments()) {
      // Jump from Review & Submit (step 5) to Bank Account (step 3)
      setState(() {
        _currentStep = 3;
      });
      _pageController.animateToPage(
        3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Merchant Registration',
          style: AppTextStyles.h5,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          const SizedBox(height: 8),
          // Step Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _stepTitles[_currentStep],
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                RegistrationTypeScreen(
                  onNext: _nextStep,
                ),
                BusinessInfoScreen(
                  onNext: _nextStep,
                  onBack: _previousStep,
                ),
                OwnerInfoScreen(
                  onNext: _nextStep,
                  onBack: _previousStep,
                ),
                BankAccountScreen(
                  onNext: _nextStep,
                  onBack: _previousStep,
                ),
                DocumentsUploadScreen(
                  onNext: _nextStep,
                  onBack: _previousStep,
                ),
                ReviewSubmitScreen(
                  onBack: _previousStep,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final shouldSkipDocs = _shouldSkipDocuments();
    final totalSteps = shouldSkipDocs ? 5 : 6; // 5 steps for Tier 1&2, 6 for Tier 3
    
    // Map actual step to display step (accounting for skipped documents screen)
    int displayStep = _currentStep;
    if (shouldSkipDocs && _currentStep == 5) {
      displayStep = 4; // Show as 5th step if documents is skipped
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < displayStep;
          final isCurrent = index == displayStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? AppColors.primary
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < totalSteps - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}
