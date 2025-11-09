import 'package:flutter/foundation.dart';
import '../../data/models/payment_request.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/services/partner_api_service.dart';
import '../../core/constants/app_constants.dart';
import '../../utils/helpers.dart';

/// Provider for payment state management
class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _paymentRepository = PaymentRepository();
  final PartnerApiService _partnerApi;

  PaymentRequest? _currentPaymentRequest;
  List<PaymentRequest> _recentTransactions = [];
  List<PaymentRequest> _payments = [];
  Map<String, double> _cryptoPrices = {};
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Statistics
  int _totalTransactions = 0;
  double _totalVolume = 0;
  int _pendingPayments = 0;
  double _weekVolume = 0;

  PaymentProvider(this._partnerApi);

  // Getters
  PaymentRequest? get currentPaymentRequest => _currentPaymentRequest;
  List<PaymentRequest> get recentTransactions => _recentTransactions;
  List<PaymentRequest> get payments => _payments;
  List<PaymentRequest> get recentPayments => _payments.take(5).toList();
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalTransactions => _totalTransactions;
  double get totalVolume => _totalVolume;
  int get pendingPayments => _pendingPayments;
  double get weekVolume => _weekVolume;

  /// Get crypto price
  Future<double?> getCryptoPrice(String cryptoType) async {
    try {
      // Check cache first
      if (_cryptoPrices.containsKey(cryptoType)) {
        final cachedPrice = _cryptoPrices[cryptoType]!;
        // Cache for 1 minute in production, return immediately for mock
        return cachedPrice;
      }

      final price = await _partnerApi.getCryptoPrice(cryptoType);
      _cryptoPrices[cryptoType] = price;
      return price;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Calculate crypto amount from Naira
  Future<double?> calculateCryptoAmount({
    required double nairaAmount,
    required String cryptoType,
  }) async {
    try {
      final price = await getCryptoPrice(cryptoType);
      if (price == null) return null;

      return Helpers.nairaToCrypto(nairaAmount, price);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Create payment request
  Future<PaymentRequest?> createPaymentRequest({
    required String merchantId,
    required double amountNGN,
    required String cryptoType,
    String? description,
    String? customerName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Get exchange rate
      final exchangeRate = await getCryptoPrice(cryptoType);
      if (exchangeRate == null) {
        throw 'Failed to get exchange rate';
      }

      // Calculate crypto amount
      final cryptoAmount = Helpers.nairaToCrypto(amountNGN, exchangeRate);

      // Generate payment address
      final paymentAddress = await _partnerApi.generatePaymentAddress(
        cryptoType,
        cryptoAmount,
      );

      // Calculate fees
      final adnaFee = Helpers.calculateFee(amountNGN, AppConstants.adnaFeePercentage);
      final partnerFee = Helpers.calculateFee(amountNGN, AppConstants.partnerFeePercentage);
      final netAmount = amountNGN - adnaFee - partnerFee;

      final feeBreakdown = FeeBreakdown(
        grossAmount: amountNGN,
        adnaFee: adnaFee,
        partnerFee: partnerFee,
        netToMerchant: netAmount,
      );

      // Create QR code data (payment address + amount)
      final qrCodeData = '$cryptoType:$paymentAddress?amount=$cryptoAmount';

      // Create payment link (can be enhanced to include domain)
      final paymentLink = 'adna://payment/$paymentAddress';

      // Set expiry time
      final expiresAt = DateTime.now().add(
        Duration(minutes: AppConstants.paymentExpiryMinutes),
      );

      // Create payment request object
      final paymentRequest = PaymentRequest(
        id: '', // Will be set by Firestore
        merchantId: merchantId,
        amountNGN: amountNGN,
        cryptoAmount: cryptoAmount,
        cryptoType: cryptoType,
        exchangeRate: exchangeRate,
        paymentAddress: paymentAddress,
        paymentLink: paymentLink,
        qrCodeData: qrCodeData,
        description: description,
        customerName: customerName,
        status: AppConstants.paymentStatusPending,
        statusTimeline: StatusTimeline(
          created: DateTime.now(),
        ),
        feeBreakdown: feeBreakdown,
        settlementDetails: null,
        errorMessage: null,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        completedAt: null,
      );

      // Save to Firestore
      final requestId = await _paymentRepository.createPaymentRequest(paymentRequest);
      
      // Load the created payment request
      _currentPaymentRequest = await _paymentRepository.getPaymentRequestById(requestId);

      _setLoading(false);
      return _currentPaymentRequest;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Load payment request by ID
  Future<void> loadPaymentRequest(String requestId) async {
    try {
      _setLoading(true);
      _clearError();

      _currentPaymentRequest = await _paymentRepository.getPaymentRequestById(requestId);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Get payment request by ID (returns the payment request)
  Future<PaymentRequest?> getPaymentRequest(String requestId) async {
    try {
      return await _paymentRepository.getPaymentRequestById(requestId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Stream payment request (real-time updates)
  Stream<PaymentRequest?> streamPaymentRequest(String requestId) {
    return _paymentRepository.streamPaymentRequest(requestId);
  }

  /// Load recent transactions
  Future<void> loadRecentTransactions(String merchantId, {int limit = 5}) async {
    try {
      _recentTransactions = await _paymentRepository.getTransactionsByMerchant(
        merchantId: merchantId,
        limit: limit,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Stream recent transactions
  Stream<List<PaymentRequest>> streamRecentTransactions(String merchantId) {
    return _paymentRepository.streamRecentTransactions(merchantId: merchantId);
  }

  /// Load dashboard statistics
  Future<void> loadDashboardStats(String merchantId) async {
    try {
      _setLoading(true);
      
      // Get today's stats
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final todayPayments = await _paymentRepository.getPaymentRequestsByMerchant(
        merchantId: merchantId,
        startDate: todayStart,
      );

      final completedToday = todayPayments.where((p) => p.status == 'completed').toList();
      final pendingToday = todayPayments.where((p) => p.status == 'pending').toList();

      final totalReceived = completedToday.fold<double>(
        0,
        (sum, payment) => sum + payment.nairaAmount,
      );

      _dashboardStats = {
        'totalReceived': totalReceived,
        'transactionCount': todayPayments.length,
        'pendingCount': pendingToday.length,
        'completedCount': completedToday.length,
      };

      // Load recent transactions
      _recentTransactions = todayPayments;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Load all payments for merchant
  Future<void> loadPayments(String merchantId) async {
    try {
      _setLoading(true);
      
      _payments = await _paymentRepository.getPaymentRequestsByMerchant(
        merchantId: merchantId,
        limit: 100,
      );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Search transactions
  Future<List<PaymentRequest>> searchTransactions({
    required String merchantId,
    required String query,
  }) async {
    try {
      return await _paymentRepository.searchTransactions(
        merchantId: merchantId,
        searchQuery: query,
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Get transactions with filters
  Future<List<PaymentRequest>> getFilteredTransactions({
    required String merchantId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    try {
      return await _paymentRepository.getPaymentRequestsByMerchant(
        merchantId: merchantId,
        status: status,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Clear current payment request
  void clearCurrentPaymentRequest() {
    _currentPaymentRequest = null;
    notifyListeners();
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

  /// Refresh crypto prices
  Future<void> refreshCryptoPrices() async {
    _cryptoPrices.clear();
    for (var cryptoType in AppConstants.supportedCryptos) {
      await getCryptoPrice(cryptoType);
    }
  }

  /// Get cached crypto price (if available)
  double? getCachedPrice(String cryptoType) {
    return _cryptoPrices[cryptoType];
  }
}
