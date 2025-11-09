import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../utils/validators.dart';
import '../../../utils/formatters.dart';
import '../../../utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_dropdown.dart';
import 'payment_display_screen.dart';

/// Create payment screen - generate crypto payment request
class CreatePaymentScreen extends StatefulWidget {
  const CreatePaymentScreen({super.key});

  @override
  State<CreatePaymentScreen> createState() => _CreatePaymentScreenState();
}

class _CreatePaymentScreenState extends State<CreatePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCryptoType;
  double? _cryptoAmount;
  double? _exchangeRate;
  bool _isCalculating = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _calculateCryptoAmount() async {
    if (_selectedCryptoType == null || _amountController.text.isEmpty) {
      return;
    }

    final nairaAmount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (nairaAmount == null || nairaAmount <= 0) {
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    final price = await paymentProvider.getCryptoPrice(_selectedCryptoType!);

    if (mounted) {
      final cryptoAmt = await paymentProvider.calculateCryptoAmount(
        nairaAmount: nairaAmount,
        cryptoType: _selectedCryptoType!,
      );
      
      setState(() {
        _exchangeRate = price;
        _cryptoAmount = cryptoAmt;
        _isCalculating = false;
      });
    }
  }

  Future<void> _handleCreatePayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCryptoType == null) {
      Helpers.showError(context, 'Please select a cryptocurrency');
      return;
    }

    if (_cryptoAmount == null || _exchangeRate == null) {
      Helpers.showError(context, 'Please wait for amount calculation');
      return;
    }

    Helpers.unfocus(context);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    final nairaAmount = double.parse(_amountController.text.replaceAll(',', ''));

    final paymentRequest = await paymentProvider.createPaymentRequest(
      merchantId: authProvider.merchant!.id,
      amountNGN: nairaAmount,
      cryptoType: _selectedCryptoType!,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (paymentRequest != null) {
      // Navigate to payment display screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentDisplayScreen(paymentRequest: paymentRequest),
        ),
      );
    } else {
      Helpers.showError(
        context,
        paymentProvider.errorMessage ?? 'Failed to create payment',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Payment',
          style: AppTextStyles.h5,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Create a payment request for your customer to pay with crypto',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Amount Field
              CustomTextField(
                label: 'Amount (Naira)',
                hint: 'Enter amount to receive',
                controller: _amountController,
                keyboardType: TextInputType.number,validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value.replaceAll(',', ''));
                  if (amount == null || amount <= 0) {
                    return 'Please enter valid amount';
                  }
                  if (amount < 100) {
                    return 'Minimum amount is ₦100';
                  }
                  return null;
                },
                onChanged: (_) => _calculateCryptoAmount(),
              ),
              const SizedBox(height: 16),
              // Crypto Type Selection
              CustomDropdown(
                label: 'Cryptocurrency',
                hint: 'Select crypto type',
                value: _selectedCryptoType,
                items: AppConstants.cryptoTypes,
                itemLabel: (item) => item,
                onChanged: (value) {
                  setState(() {
                    _selectedCryptoType = value;
                    _cryptoAmount = null;
                    _exchangeRate = null;
                  });
                  _calculateCryptoAmount();
                },
                prefixIcon: _selectedCryptoType != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          AppConstants.getCryptoIcon(_selectedCryptoType!),
                          width: 24,
                          height: 24,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              // Description Field
              CustomTextField(
                label: 'Description (Optional)',
                hint: 'Payment purpose or note',
                controller: _descriptionController,
                maxLines: 3,),
              if (_isCalculating) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 8),
                Text(
                  'Calculating exchange rate...',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_cryptoAmount != null && _exchangeRate != null && !_isCalculating) ...[
                const SizedBox(height: 24),
                // Exchange Rate Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Exchange Rate',
                        '1 $_selectedCryptoType = ${Formatters.formatNaira(_exchangeRate!)}',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Customer Pays',
                        Formatters.formatCrypto(_cryptoAmount!, _selectedCryptoType!),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'You Receive',
                        Formatters.formatNaira(
                          double.parse(_amountController.text.replaceAll(',', '')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Create Button
              Consumer<PaymentProvider>(
                builder: (context, paymentProvider, _) {
                  return CustomButton(
                    text: 'Create Payment Request',
                    onPressed: _handleCreatePayment,
                    isLoading: paymentProvider.isLoading,
                    fullWidth: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
