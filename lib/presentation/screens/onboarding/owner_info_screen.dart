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

/// Owner information screen - Step 2 of onboarding
class OwnerInfoScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OwnerInfoScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OwnerInfoScreen> createState() => _OwnerInfoScreenState();
}

class _OwnerInfoScreenState extends State<OwnerInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bvnController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  String? _selectedState;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bvnController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _loadSavedData() {
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    final data = merchantProvider.onboardingData;

    _firstNameController.text = data['ownerFirstName'] ?? '';
    _lastNameController.text = data['ownerLastName'] ?? '';
    _phoneController.text = data['ownerPhone'] ?? '';
    _emailController.text = data['ownerEmail'] ?? '';
    _bvnController.text = data['ownerBvn'] ?? '';
    _dobController.text = data['ownerDob'] ?? '';
    _addressController.text = data['ownerAddress'] ?? '';
    _cityController.text = data['ownerCity'] ?? '';
    _selectedState = data['ownerState'];
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Must be 18+
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = Helpers.formatDate(pickedDate);
      });
    }
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedState == null) {
      Helpers.showError(context, 'Please select state');
      return;
    }

    if (_dobController.text.isEmpty) {
      Helpers.showError(context, 'Please select date of birth');
      return;
    }

    Helpers.unfocus(context);

    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);

    merchantProvider.updateOnboardingSection({
      'ownerFirstName': _firstNameController.text.trim(),
      'ownerLastName': _lastNameController.text.trim(),
      'ownerPhone': _phoneController.text.trim(),
      'ownerEmail': _emailController.text.trim(),
      'ownerBvn': _bvnController.text.trim(),
      'ownerDob': _dobController.text,
      'ownerAddress': _addressController.text.trim(),
      'ownerCity': _cityController.text.trim(),
      'ownerState': _selectedState,
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
              'Business owner or director information',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 24),
            // First Name
            CustomTextField(
              label: 'First Name',
              hint: 'Enter first name',
              controller: _firstNameController,validator: (value) => Validators.required(value, 'First name'),
            ),
            const SizedBox(height: 16),
            // Last Name
            CustomTextField(
              label: 'Last Name',
              hint: 'Enter last name',
              controller: _lastNameController,validator: (value) => Validators.required(value, 'Last name'),
            ),
            const SizedBox(height: 16),
            // Phone
            CustomTextField(
              label: 'Phone Number',
              hint: 'Enter phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,validator: Validators.phoneNumber,
            ),
            const SizedBox(height: 16),
            // Email
            CustomTextField(
              label: 'Email Address',
              hint: 'Enter email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,validator: Validators.email,
            ),
            const SizedBox(height: 16),
            // BVN
            CustomTextField(
              label: 'Bank Verification Number (BVN)',
              hint: 'Enter 11-digit BVN',
              controller: _bvnController,
              keyboardType: TextInputType.number,validator: Validators.bvn,
              maxLength: 11,
            ),
            const SizedBox(height: 8),
            Text(
              'Your BVN is required for identity verification and is kept secure',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            // Date of Birth
            CustomTextField(
              label: 'Date of Birth',
              hint: 'Select date of birth',
              controller: _dobController,readOnly: true,
              onTap: _selectDate,
              validator: (value) => Validators.required(value, 'Date of birth'),
            ),
            const SizedBox(height: 16),
            // Address
            CustomTextField(
              label: 'Residential Address',
              hint: 'Enter street address',
              controller: _addressController,
              maxLines: 2,validator: (value) => Validators.required(value, 'Address'),
            ),
            const SizedBox(height: 16),
            // City
            CustomTextField(
              label: 'City',
              hint: 'Enter city',
              controller: _cityController,validator: (value) => Validators.required(value, 'City'),
            ),
            const SizedBox(height: 16),
            // State
            CustomDropdown(
              label: 'State',
              hint: 'Select state',
              value: _selectedState,
              items: AppConstants.nigerianStates,
              itemLabel: (item) => item,
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                });
              },),
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
