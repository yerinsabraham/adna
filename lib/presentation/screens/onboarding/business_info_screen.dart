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

/// Business information screen - Step 1 of onboarding
class BusinessInfoScreen extends StatefulWidget {
  final VoidCallback onNext;

  const BusinessInfoScreen({
    super.key,
    required this.onNext,
  });

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _tradingNameController = TextEditingController();
  final _cacNumberController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedBusinessType;
  String? _selectedIndustry;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _tradingNameController.dispose();
    _cacNumberController.dispose();
    _taxIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadSavedData() {
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    final data = merchantProvider.onboardingData;

    _businessNameController.text = data['businessName'] ?? '';
    _tradingNameController.text = data['tradingName'] ?? '';
    _cacNumberController.text = data['cacNumber'] ?? '';
    _taxIdController.text = data['taxId'] ?? '';
    _phoneController.text = data['businessPhone'] ?? '';
    _emailController.text = data['businessEmail'] ?? '';
    _websiteController.text = data['website'] ?? '';
    _descriptionController.text = data['businessDescription'] ?? '';
    _selectedBusinessType = data['businessType'];
    _selectedIndustry = data['industry'];
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBusinessType == null) {
      Helpers.showError(context, 'Please select business type');
      return;
    }

    if (_selectedIndustry == null) {
      Helpers.showError(context, 'Please select industry');
      return;
    }

    Helpers.unfocus(context);

    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);

    merchantProvider.updateOnboardingSection({
      'businessName': _businessNameController.text.trim(),
      'tradingName': _tradingNameController.text.trim(),
      'businessType': _selectedBusinessType,
      'industry': _selectedIndustry,
      'cacNumber': _cacNumberController.text.trim(),
      'taxId': _taxIdController.text.trim(),
      'businessPhone': _phoneController.text.trim(),
      'businessEmail': _emailController.text.trim(),
      'website': _websiteController.text.trim(),
      'businessDescription': _descriptionController.text.trim(),
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
              'Tell us about your business',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 24),
            // Business Name
            CustomTextField(
              label: 'Registered Business Name',
              hint: 'Enter registered business name',
              controller: _businessNameController,validator: (value) => Validators.required(value, 'Business name'),
            ),
            const SizedBox(height: 16),
            // Trading Name
            CustomTextField(
              label: 'Trading Name (Optional)',
              hint: 'Enter trading name if different',
              controller: _tradingNameController,),
            const SizedBox(height: 16),
            // Business Type
            CustomDropdown(
              label: 'Business Type',
              hint: 'Select business type',
              value: _selectedBusinessType,
              items: AppConstants.businessTypes,
              itemLabel: (item) => item,
              onChanged: (value) {
                setState(() {
                  _selectedBusinessType = value;
                });
              },),
            const SizedBox(height: 16),
            // Industry
            CustomDropdown(
              label: 'Industry',
              hint: 'Select industry',
              value: _selectedIndustry,
              items: AppConstants.industries,
              itemLabel: (item) => item,
              onChanged: (value) {
                setState(() {
                  _selectedIndustry = value;
                });
              },),
            const SizedBox(height: 16),
            // CAC Number
            CustomTextField(
              label: 'CAC Registration Number',
              hint: 'Enter CAC number',
              controller: _cacNumberController,validator: Validators.cacNumber,
            ),
            const SizedBox(height: 16),
            // Tax ID
            CustomTextField(
              label: 'Tax Identification Number (TIN)',
              hint: 'Enter TIN',
              controller: _taxIdController,validator: Validators.tin,
            ),
            const SizedBox(height: 16),
            // Business Phone
            CustomTextField(
              label: 'Business Phone',
              hint: 'Enter business phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,validator: Validators.phoneNumber,
            ),
            const SizedBox(height: 16),
            // Business Email
            CustomTextField(
              label: 'Business Email',
              hint: 'Enter business email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,validator: Validators.email,
            ),
            const SizedBox(height: 16),
            // Website
            CustomTextField(
              label: 'Website (Optional)',
              hint: 'Enter website URL',
              controller: _websiteController,
              keyboardType: TextInputType.url,),
            const SizedBox(height: 16),
            // Description
            CustomTextField(
              label: 'Business Description',
              hint: 'Describe your business and products/services',
              controller: _descriptionController,
              maxLines: 4,validator: (value) => Validators.required(value, 'Business description'),
            ),
            const SizedBox(height: 32),
            // Next Button
            CustomButton(
              text: 'Continue',
              onPressed: _handleNext,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
