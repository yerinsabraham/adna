import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/models/merchant.dart';
import '../../data/repositories/merchant_repository.dart';
import '../../data/services/storage_service.dart';
import '../../core/constants/app_constants.dart';

/// Provider for merchant/onboarding state management
class MerchantProvider extends ChangeNotifier {
  final MerchantRepository _merchantRepository = MerchantRepository();
  final StorageService _storageService = StorageService();

  Merchant? _merchant;
  bool _isLoading = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  // Onboarding form data (temporary storage during onboarding)
  Map<String, dynamic> _onboardingData = {};

  // Getters
  Merchant? get merchant => _merchant;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;
  Map<String, dynamic> get onboardingData => _onboardingData;

  /// Load merchant by user ID
  Future<void> loadMerchant(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _merchant = await _merchantRepository.getMerchantByUserId(userId);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Stream merchant data (real-time updates)
  Stream<Merchant?> streamMerchant(String userId) {
    return _merchantRepository.streamMerchantByUserId(userId);
  }

  /// Update onboarding form data
  void updateOnboardingData(String key, dynamic value) {
    _onboardingData[key] = value;
    notifyListeners();
  }

  /// Update multiple onboarding fields at once
  void updateOnboardingSection(Map<String, dynamic> data) {
    _onboardingData.addAll(data);
    notifyListeners();
  }

  /// Pick and upload document (for onboarding)
  Future<bool> pickAndUploadDocument(String documentType) async {
    try {
      _setLoading(true);
      _clearError();

      // In a real app, this would use image_picker or file_picker
      // For now, simulate document selection
      await Future.delayed(const Duration(seconds: 1));

      // Create a mock file
      final mockFile = File('/mock/path/${documentType}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Store in onboarding data based on document type
      String fieldKey;
      switch (documentType) {
        case 'cac_certificate':
          fieldKey = 'cacDocument';
          break;
        case 'utility_bill':
          fieldKey = 'utilityBill';
          break;
        case 'government_id':
          fieldKey = 'idCard';
          break;
        default:
          fieldKey = documentType;
      }

      _onboardingData[fieldKey] = mockFile;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Remove document from onboarding data
  void removeDocument(String fieldKey) {
    _onboardingData.remove(fieldKey);
    notifyListeners();
  }

  /// Submit onboarding (alias for submitMerchantApplication)
  Future<bool> submitOnboarding(String userId, String email) async {
    return submitMerchantApplication(userId: userId, email: email);
  }

  /// Clear onboarding data
  void clearOnboardingData() {
    _onboardingData = {};
    notifyListeners();
  }

  /// Upload KYC document
  Future<String?> uploadDocument({
    required File file,
    required String userId,
    required String documentType,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final url = await _storageService.uploadWithProgress(
        file: file,
        userId: userId,
        documentType: documentType,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      _uploadProgress = 0.0;
      _setLoading(false);
      return url;
    } catch (e) {
      _setError(e.toString());
      _uploadProgress = 0.0;
      _setLoading(false);
      return null;
    }
  }

  /// Submit merchant application
  Future<bool> submitMerchantApplication({
    required String userId,
    required String email,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Create Address objects
      final businessAddress = Address(
        street: _onboardingData['ownerAddress'] ?? '',
        city: _onboardingData['ownerCity'] ?? '',
        state: _onboardingData['ownerState'] ?? '',
      );

      final residentialAddress = Address(
        street: _onboardingData['ownerAddress'] ?? '',
        city: _onboardingData['ownerCity'] ?? '',
        state: _onboardingData['ownerState'] ?? '',
      );

      // Create Document objects from uploaded documents
      final documents = <Document>[];
      
      if (_onboardingData['cacDocument'] != null) {
        documents.add(Document(
          type: 'cac_certificate',
          url: 'mock_url_cac', // In production, upload to Firebase Storage
          fileName: 'cac_certificate.jpg',
          uploadedAt: DateTime.now(),
        ));
      }
      
      if (_onboardingData['utilityBill'] != null) {
        documents.add(Document(
          type: 'utility_bill',
          url: 'mock_url_utility', // In production, upload to Firebase Storage
          fileName: 'utility_bill.jpg',
          uploadedAt: DateTime.now(),
        ));
      }
      
      if (_onboardingData['idCard'] != null) {
        documents.add(Document(
          type: 'government_id',
          url: 'mock_url_id', // In production, upload to Firebase Storage
          fileName: 'government_id.jpg',
          uploadedAt: DateTime.now(),
        ));
      }

      // Create Merchant object with the data from onboarding screens
      final merchant = Merchant(
        id: '', // Will be set by Firestore
        userId: userId,
        email: email,
        businessName: _onboardingData['businessName'] ?? '',
        cacNumber: _onboardingData['cacNumber'] ?? '',
        tin: _onboardingData['taxId'] ?? '',
        category: _onboardingData['industry'] ?? '',
        businessAddress: businessAddress,
        businessPhone: _onboardingData['businessPhone'] ?? '',
        businessEmail: _onboardingData['businessEmail'],
        ownerName: '${_onboardingData['ownerFirstName'] ?? ''} ${_onboardingData['ownerLastName'] ?? ''}',
        bvnOrNin: _onboardingData['ownerBvn'] ?? '',
        dateOfBirth: _onboardingData['ownerDob'],
        residentialAddress: residentialAddress,
        ownerPhone: _onboardingData['ownerPhone'] ?? '',
        idType: 'bvn',
        bankName: _onboardingData['bankName'] ?? '',
        accountNumber: _onboardingData['bankAccountNumber'] ?? '',
        accountName: _onboardingData['bankAccountName'] ?? '',
        accountType: 'business',
        kycStatus: AppConstants.kycStatusPending,
        rejectionReason: null,
        documents: documents,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        approvedAt: null,
        approvedBy: null,
        tier: _onboardingData['tier'] ?? AppConstants.tierBasic,
        dailyLimit: (_onboardingData['dailyLimit'] ?? AppConstants.basicDailyLimit).toDouble(),
        monthlyLimit: (_onboardingData['monthlyLimit'] ?? AppConstants.basicMonthlyLimit).toDouble(),
        registrationType: _onboardingData['registrationType'] ?? AppConstants.regTypeIndividual,
      );

      // Save to Firestore
      final merchantId = await _merchantRepository.createMerchant(merchant);
      
      // Load the created merchant
      _merchant = await _merchantRepository.getMerchantById(merchantId);

      // Clear onboarding data
      clearOnboardingData();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Create demo merchant account (for testing only)
  Future<bool> createDemoMerchant(String userId, String email) async {
    try {
      print('🔵 Creating demo merchant for userId: $userId');
      _setLoading(true);
      _clearError();

      // Create a pre-approved demo merchant
      final demoMerchant = Merchant(
        id: userId,
        userId: userId,
        email: email,
        businessName: 'Demo Business Ltd',
        cacNumber: 'RC1234567',
        tin: 'TIN9876543',
        category: 'Technology',
        businessAddress: Address(
          street: '123 Demo Street',
          city: 'Lagos',
          state: 'Lagos',
        ),
        businessPhone: '+2348012345678',
        businessEmail: email,
        ownerName: 'Demo User',
        bvnOrNin: '12345678901',
        dateOfBirth: '1990-01-01',
        residentialAddress: Address(
          street: '123 Demo Street',
          city: 'Lagos',
          state: 'Lagos',
        ),
        ownerPhone: '+2348012345678',
        idType: 'BVN',
        bankName: 'Access Bank',
        accountNumber: '0123456789',
        accountName: 'DEMO BUSINESS LTD',
        accountType: 'Current',
        kycStatus: 'approved', // Pre-approved for demo
        documents: [
          Document(
            type: 'cac_certificate',
            url: 'demo_url',
            fileName: 'demo_cac.pdf',
            uploadedAt: DateTime.now(),
          ),
        ],
        tier: AppConstants.tierEnterprise, // Highest tier for testing
        dailyLimit: AppConstants.getTierDetails(AppConstants.tierEnterprise)['dailyLimit'] as double,
        monthlyLimit: AppConstants.getTierDetails(AppConstants.tierEnterprise)['monthlyLimit'] as double,
        registrationType: 'limited_company',
        isAdmin: true, // Grant admin access
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('🔵 Saving demo merchant to Firestore...');
      // Save to Firestore
      await _merchantRepository.createMerchant(demoMerchant);
      _merchant = demoMerchant;

      print('🟢 Demo merchant created successfully!');
      _setLoading(false);
      return true;
    } catch (e) {
      print('🔴 Error creating demo merchant: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update merchant profile
  Future<bool> updateMerchant(String merchantId, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _clearError();

      await _merchantRepository.updateMerchant(merchantId, data);
      
      // Reload merchant data
      _merchant = await _merchantRepository.getMerchantById(merchantId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if onboarding is complete
  bool get isOnboardingComplete {
    return _onboardingData.containsKey('businessName') &&
        _onboardingData.containsKey('ownerName') &&
        _onboardingData.containsKey('accountNumber') &&
        (_onboardingData['documents'] as List?)?.isNotEmpty == true;
  }

  /// Get current onboarding step (0-4)
  int getCurrentStep() {
    if (!_onboardingData.containsKey('businessName')) return 0;
    if (!_onboardingData.containsKey('ownerName')) return 1;
    if (!_onboardingData.containsKey('accountNumber')) return 2;
    if ((_onboardingData['documents'] as List?)?.isEmpty ?? true) return 3;
    return 4; // Review step
  }
}
