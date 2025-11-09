import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../utils/validators.dart';
import '../../../utils/helpers.dart';
import '../../providers/merchant_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_dropdown.dart';

/// Bank account screen - Step 3 of onboarding
class BankAccountScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const BankAccountScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  String? _selectedBankCode;
  String? _selectedBankName;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  void _loadSavedData() {
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    final data = merchantProvider.onboardingData;

    _accountNumberController.text = data['bankAccountNumber'] ?? '';
    _accountNameController.text = data['bankAccountName'] ?? '';
    _selectedBankCode = data['bankCode'];
    _selectedBankName = data['bankName'];
  }

  Future<void> _verifyAccount() async {
    if (_selectedBankCode == null) {
      Helpers.showError(context, 'Please select a bank');
      return;
    }

    if (_accountNumberController.text.length != 10) {
      Helpers.showError(context, 'Account number must be 10 digits');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // In production, this would call Paystack or another bank verification API
    // For now, simulate verification
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isVerifying = false;
        // Simulate verified account name
        _accountNameController.text = 'VERIFIED ACCOUNT NAME';
      });

      Helpers.showSuccess(context, 'Account verified successfully');
    }
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBankCode == null || _selectedBankName == null) {
      Helpers.showError(context, 'Please select a bank');
      return;
    }

    if (_accountNameController.text.isEmpty) {
      Helpers.showError(context, 'Please verify account number');
      return;
    }

    Helpers.unfocus(context);

    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);

    merchantProvider.updateOnboardingSection({
      'bankCode': _selectedBankCode,
      'bankName': _selectedBankName,
      'bankAccountNumber': _accountNumberController.text.trim(),
      'bankAccountName': _accountNameController.text.trim(),
    });

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bank account for settlements',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 8),
            Text(
              'Payments will be settled to this account after conversion',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            // Bank Selection
            CustomDropdown<String>(
              label: 'Bank Name',
              hint: 'Select bank',
              value: _selectedBankName,
              items: AppConstants.nigerianBanks,
              itemLabel: (item) => item,
              onChanged: (value) {
                setState(() {
                  _selectedBankName = value;
                  // Clear account name when bank changes
                  _accountNameController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            // Account Number
            CustomTextField(
              label: 'Account Number',
              hint: 'Enter 10-digit account number',
              controller: _accountNumberController,
              keyboardType: TextInputType.number,maxLength: 10,
              validator: Validators.accountNumber,
              onChanged: (_) {
                // Clear account name when number changes
                if (_accountNameController.text.isNotEmpty) {
                  setState(() {
                    _accountNameController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Verify Button
            CustomButton(
              text: 'Verify Account',
              onPressed: _isVerifying ? null : _verifyAccount,
              isLoading: _isVerifying,
              variant: ButtonType.secondary,
              fullWidth: true,
            ),
            const SizedBox(height: 16),
            // Account Name (read-only, populated after verification)
            CustomTextField(
              label: 'Account Name',
              hint: 'Account name will appear after verification',
              controller: _accountNameController,readOnly: true,
              validator: (value) => Validators.required(value, 'Account name'),
            ),
            if (_accountNameController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Account verified',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
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
                    text: 'Continue',
                    onPressed: _handleNext,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
