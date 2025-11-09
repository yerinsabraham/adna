import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../utils/helpers.dart';
import '../../providers/merchant_provider.dart';
import '../../widgets/common/custom_button.dart';

/// Documents upload screen - Step 4 of onboarding
class DocumentsUploadScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DocumentsUploadScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<DocumentsUploadScreen> createState() => _DocumentsUploadScreenState();
}

class _DocumentsUploadScreenState extends State<DocumentsUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, _) {
        final cacDocument = merchantProvider.onboardingData['cacDocument'];
        final utilityBill = merchantProvider.onboardingData['utilityBill'];
        final idCard = merchantProvider.onboardingData['idCard'];

        final allDocumentsUploaded = cacDocument != null &&
            utilityBill != null &&
            idCard != null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload required documents',
                style: AppTextStyles.subtitle1,
              ),
              const SizedBox(height: 8),
              Text(
                'All documents must be clear and legible',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 24),
              // CAC Certificate
              _DocumentUploadCard(
                title: 'CAC Registration Certificate',
                description: 'Upload your company registration certificate',
                documentType: 'cac_certificate',
                file: cacDocument,
                onUpload: () => _handleUpload(context, 'cac_certificate'),
                onRemove: () => _handleRemove(context, 'cacDocument'),
              ),
              const SizedBox(height: 16),
              // Utility Bill
              _DocumentUploadCard(
                title: 'Utility Bill',
                description: 'Upload recent utility bill (not older than 3 months)',
                documentType: 'utility_bill',
                file: utilityBill,
                onUpload: () => _handleUpload(context, 'utility_bill'),
                onRemove: () => _handleRemove(context, 'utilityBill'),
              ),
              const SizedBox(height: 16),
              // ID Card
              _DocumentUploadCard(
                title: 'Government-Issued ID',
                description: 'Upload valid ID (National ID, Driver\'s License, or Passport)',
                documentType: 'government_id',
                file: idCard,
                onUpload: () => _handleUpload(context, 'government_id'),
                onRemove: () => _handleRemove(context, 'idCard'),
              ),
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
                      onPressed: allDocumentsUploaded ? widget.onNext : null,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleUpload(BuildContext context, String documentType) async {
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);

    final success = await merchantProvider.pickAndUploadDocument(documentType);

    if (!mounted) return;

    if (!success) {
      Helpers.showError(
        context,
        merchantProvider.errorMessage ?? 'Failed to upload document',
      );
    }
  }

  void _handleRemove(BuildContext context, String fieldKey) {
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);
    merchantProvider.removeDocument(fieldKey);
  }
}

/// Document upload card widget
class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String description;
  final String documentType;
  final File? file;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const _DocumentUploadCard({
    required this.title,
    required this.description,
    required this.documentType,
    required this.file,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isUploaded = file != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? AppColors.success : AppColors.borderLight,
          width: isUploaded ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUploaded ? Icons.check_circle : Icons.upload_file,
                color: isUploaded ? AppColors.success : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isUploaded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      file!.path.split('/').last,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.error,
                      size: 20,
                    ),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          CustomButton(
            text: isUploaded ? 'Replace Document' : 'Upload Document',
            onPressed: onUpload,
            variant: ButtonType.secondary,
            fullWidth: true,
            icon: Icons.upload,
          ),
        ],
      ),
    );
  }
}
