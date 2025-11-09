import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/payment_request.dart';
import '../../../utils/formatters.dart';
import '../../../utils/helpers.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/status_badge.dart';
import '../dashboard/dashboard_screen.dart';

/// Payment display screen - shows QR code and payment details
class PaymentDisplayScreen extends StatefulWidget {
  final PaymentRequest paymentRequest;

  const PaymentDisplayScreen({
    super.key,
    required this.paymentRequest,
  });

  @override
  State<PaymentDisplayScreen> createState() => _PaymentDisplayScreenState();
}

class _PaymentDisplayScreenState extends State<PaymentDisplayScreen> {
  Timer? _statusCheckTimer;
  late PaymentRequest _currentPayment;

  @override
  void initState() {
    super.initState();
    _currentPayment = widget.paymentRequest;
    _startStatusCheck();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusCheck() {
    // Check payment status every 10 seconds
    _statusCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkPaymentStatus(),
    );
  }

  Future<void> _checkPaymentStatus() async {
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    final updatedPayment = await paymentProvider.getPaymentRequest(_currentPayment.id);

    if (updatedPayment != null && mounted) {
      setState(() {
        _currentPayment = updatedPayment;
      });

      // If completed, show success and navigate back
      if (updatedPayment.status == 'completed') {
        _statusCheckTimer?.cancel();
        Helpers.showSuccess(context, 'Payment received successfully!');
        
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Helpers.showSuccess(context, '$label copied to clipboard');
  }

  void _sharePayment() {
    // In production, this would use share_plus package
    final paymentInfo = '''
Payment Request

Amount: ${Formatters.formatNaira(_currentPayment.nairaAmount)}
Pay with: ${Formatters.formatCrypto(_currentPayment.cryptoAmount, _currentPayment.cryptoType)}

Wallet Address: ${_currentPayment.walletAddress}

Reference: ${_currentPayment.reference}
''';

    _copyToClipboard(paymentInfo, 'Payment details');
  }

  void _handleDone() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = _currentPayment.status == 'completed';
    final isPending = _currentPayment.status == 'pending';

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation, must use Done button
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: _handleDone,
          ),
          title: Text(
            'Payment Request',
            style: AppTextStyles.h5,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.primary),
              onPressed: _sharePayment,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Badge
              Center(
                child: StatusBadge(status: _currentPayment.status),
              ),
              const SizedBox(height: 24),
              // Amount Display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    // Crypto Icon
                    Image.asset(
                      AppConstants.getCryptoIcon(_currentPayment.cryptoType),
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Customer Pays',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.formatCrypto(
                        _currentPayment.cryptoAmount,
                        _currentPayment.cryptoType,
                      ),
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You Receive',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.formatNaira(_currentPayment.nairaAmount),
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // QR Code
              if (isPending) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Scan QR Code',
                        style: AppTextStyles.h6,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: QrImageView(
                          data: _currentPayment.walletAddress,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Or copy wallet address below',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Payment Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: AppTextStyles.h6,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Reference',
                      _currentPayment.reference,
                      canCopy: true,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Wallet Address',
                      _currentPayment.walletAddress,
                      canCopy: true,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Exchange Rate',
                      '1 ${_currentPayment.cryptoType} = ${Formatters.formatNaira(_currentPayment.exchangeRate)}',
                    ),
                    if (_currentPayment.description?.isNotEmpty ?? false) ...[
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Description',
                        _currentPayment.description!,
                      ),
                    ],
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Created',
                      Formatters.formatDateFull(_currentPayment.createdAt),
                    ),
                    if (_currentPayment.expiresAt != null) ...[
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Expires',
                        Formatters.formatDateFull(_currentPayment.expiresAt!),
                      ),
                    ],
                  ],
                ),
              ),
              if (isPending) ...[
                const SizedBox(height: 24),
                // Status Check Indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.warning,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Waiting for payment confirmation...',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Done Button
              CustomButton(
                text: isCompleted ? 'Done' : 'Close',
                onPressed: _handleDone,
                variant: ButtonType.secondary,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool canCopy = false}) {
    return Row(
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (canCopy)
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () => _copyToClipboard(value, label),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
