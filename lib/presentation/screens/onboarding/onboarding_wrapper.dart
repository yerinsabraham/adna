import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../providers/merchant_provider.dart';
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

  void _nextStep() {
    if (_currentStep < 4) {
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
                BusinessInfoScreen(
                  onNext: _nextStep,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(5, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;

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
                if (index < 4) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}
