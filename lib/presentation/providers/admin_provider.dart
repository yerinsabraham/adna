import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/merchant.dart';

/// Provider for admin operations
class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  List<Merchant> _pendingMerchants = [];
  List<Merchant> _allMerchants = [];
  Map<String, dynamic>? _platformStats;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Merchant> get pendingMerchants => _pendingMerchants;
  List<Merchant> get allMerchants => _allMerchants;
  Map<String, dynamic>? get platformStats => _platformStats;

  /// Load all pending merchant applications
  Future<void> loadPendingApplications() async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await _firestore
          .collection('merchants')
          .where('kycStatus', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      _pendingMerchants = querySnapshot.docs
          .map((doc) => Merchant.fromMap(doc.data(), doc.id))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Load all merchants (approved, pending, rejected)
  Future<void> loadAllMerchants() async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await _firestore
          .collection('merchants')
          .orderBy('createdAt', descending: true)
          .get();

      _allMerchants = querySnapshot.docs
          .map((doc) => Merchant.fromMap(doc.data(), doc.id))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Approve merchant application
  Future<bool> approveMerchant(String merchantId, String adminId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestore.collection('merchants').doc(merchantId).update({
        'kycStatus': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reload pending applications
      await loadPendingApplications();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Reject merchant application
  Future<bool> rejectMerchant(String merchantId, String reason, String adminId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestore.collection('merchants').doc(merchantId).update({
        'kycStatus': 'rejected',
        'rejectionReason': reason,
        'approvedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reload pending applications
      await loadPendingApplications();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Load platform statistics
  Future<void> loadPlatformStats() async {
    try {
      _setLoading(true);
      _clearError();

      // Get merchant counts
      final allMerchantsSnapshot = await _firestore.collection('merchants').get();
      final approvedMerchantsSnapshot = await _firestore
          .collection('merchants')
          .where('kycStatus', isEqualTo: 'approved')
          .get();
      final pendingMerchantsSnapshot = await _firestore
          .collection('merchants')
          .where('kycStatus', isEqualTo: 'pending')
          .get();
      final rejectedMerchantsSnapshot = await _firestore
          .collection('merchants')
          .where('kycStatus', isEqualTo: 'rejected')
          .get();

      // Get transaction counts (if transactions collection exists)
      int totalTransactions = 0;
      double totalVolume = 0;
      try {
        final transactionsSnapshot = await _firestore.collection('transactions').get();
        totalTransactions = transactionsSnapshot.size;
        
        for (var doc in transactionsSnapshot.docs) {
          final data = doc.data();
          totalVolume += (data['nairaAmount'] ?? 0).toDouble();
        }
      } catch (e) {
        // Transactions collection might not exist yet
        debugPrint('Transactions collection not found: $e');
      }

      _platformStats = {
        'totalMerchants': allMerchantsSnapshot.size,
        'approvedMerchants': approvedMerchantsSnapshot.size,
        'pendingMerchants': pendingMerchantsSnapshot.size,
        'rejectedMerchants': rejectedMerchantsSnapshot.size,
        'totalTransactions': totalTransactions,
        'totalVolume': totalVolume,
      };

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Suspend merchant account
  Future<bool> suspendMerchant(String merchantId, String reason) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestore.collection('merchants').doc(merchantId).update({
        'kycStatus': 'suspended',
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadAllMerchants();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Reactivate suspended merchant
  Future<bool> reactivateMerchant(String merchantId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestore.collection('merchants').doc(merchantId).update({
        'kycStatus': 'approved',
        'rejectionReason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadAllMerchants();

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
}
