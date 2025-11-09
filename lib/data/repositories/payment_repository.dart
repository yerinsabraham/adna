import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_request.dart';
import '../../core/constants/app_constants.dart';

/// Repository for managing payment requests and transactions in Firestore
class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Payment requests collection reference
  CollectionReference get _paymentRequestsCollection =>
      _firestore.collection(AppConstants.collectionPaymentRequests);

  /// Transactions collection reference
  CollectionReference get _transactionsCollection =>
      _firestore.collection(AppConstants.collectionTransactions);

  /// Create a new payment request
  Future<String> createPaymentRequest(PaymentRequest request) async {
    try {
      final docRef = await _paymentRequestsCollection.add(request.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while creating payment request';
    }
  }

  /// Get payment request by ID
  Future<PaymentRequest?> getPaymentRequestById(String requestId) async {
    try {
      final doc = await _paymentRequestsCollection.doc(requestId).get();

      if (!doc.exists) {
        return null;
      }

      return PaymentRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while fetching payment request';
    }
  }

  /// Update payment request status
  Future<void> updatePaymentStatus({
    required String requestId,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update status timeline based on new status
      if (status == AppConstants.paymentStatusAwaitingConfirmation) {
        data['statusTimeline.received'] = FieldValue.serverTimestamp();
      } else if (status == AppConstants.paymentStatusConfirmed) {
        data['statusTimeline.confirmed'] = FieldValue.serverTimestamp();
      } else if (status == AppConstants.paymentStatusConverting) {
        data['statusTimeline.converted'] = FieldValue.serverTimestamp();
      } else if (status == AppConstants.paymentStatusSettling) {
        data['statusTimeline.settled'] = FieldValue.serverTimestamp();
      } else if (status == AppConstants.paymentStatusCompleted) {
        data['completedAt'] = FieldValue.serverTimestamp();
      }

      if (additionalData != null) {
        data.addAll(additionalData);
      }

      await _paymentRequestsCollection.doc(requestId).update(data);

      // If completed, create transaction record
      if (status == AppConstants.paymentStatusCompleted) {
        await _createTransaction(requestId);
      }
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while updating payment status';
    }
  }

  /// Create transaction record from completed payment request
  Future<void> _createTransaction(String requestId) async {
    try {
      // Get the payment request
      final request = await getPaymentRequestById(requestId);
      if (request == null) return;

      // Copy to transactions collection with same ID
      await _transactionsCollection.doc(requestId).set(request.toMap());
    } catch (e) {
      // Log error but don't throw - transaction creation is not critical
      print('Error creating transaction record: $e');
    }
  }

  /// Get payment requests by merchant ID
  Future<List<PaymentRequest>> getPaymentRequestsByMerchant({
    required String merchantId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _paymentRequestsCollection
          .where('merchantId', isEqualTo: merchantId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              PaymentRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while fetching payment requests';
    }
  }

  /// Get transactions by merchant ID
  Future<List<PaymentRequest>> getTransactionsByMerchant({
    required String merchantId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _transactionsCollection
          .where('merchantId', isEqualTo: merchantId);

      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              PaymentRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while fetching transactions';
    }
  }

  /// Search transactions by customer name or description
  Future<List<PaymentRequest>> searchTransactions({
    required String merchantId,
    required String searchQuery,
    int limit = 20,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple prefix search. For production, use Algolia or similar
      final snapshot = await _transactionsCollection
          .where('merchantId', isEqualTo: merchantId)
          .where('customerName', isGreaterThanOrEqualTo: searchQuery)
          .where('customerName', isLessThan: searchQuery + 'z')
          .orderBy('customerName')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              PaymentRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while searching transactions';
    }
  }

  /// Get transaction statistics for merchant
  Future<Map<String, dynamic>> getTransactionStats({
    required String merchantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _transactionsCollection
          .where('merchantId', isEqualTo: merchantId);

      if (startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();

      double totalVolume = 0;
      int totalCount = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalVolume += (data['amountNGN'] ?? 0).toDouble();
      }

      return {
        'totalCount': totalCount,
        'totalVolume': totalVolume,
      };
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while calculating transaction stats';
    }
  }

  /// Get pending payments count
  Future<int> getPendingPaymentsCount(String merchantId) async {
    try {
      final snapshot = await _paymentRequestsCollection
          .where('merchantId', isEqualTo: merchantId)
          .where('status', whereIn: [
            AppConstants.paymentStatusPending,
            AppConstants.paymentStatusAwaitingConfirmation,
            AppConstants.paymentStatusConfirmed,
            AppConstants.paymentStatusConverting,
            AppConstants.paymentStatusSettling,
          ])
          .get();

      return snapshot.docs.length;
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while counting pending payments';
    }
  }

  /// Stream payment request (for real-time updates)
  Stream<PaymentRequest?> streamPaymentRequest(String requestId) {
    return _paymentRequestsCollection.doc(requestId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return PaymentRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  /// Stream recent transactions
  Stream<List<PaymentRequest>> streamRecentTransactions({
    required String merchantId,
    int limit = 5,
  }) {
    return _transactionsCollection
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentRequest.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Update settlement details
  Future<void> updateSettlementDetails({
    required String requestId,
    required SettlementDetails settlementDetails,
  }) async {
    try {
      await _paymentRequestsCollection.doc(requestId).update({
        'settlementDetails': settlementDetails.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while updating settlement details';
    }
  }

  /// Mark payment as expired
  Future<void> markAsExpired(String requestId) async {
    try {
      await _paymentRequestsCollection.doc(requestId).update({
        'status': AppConstants.paymentStatusExpired,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while marking payment as expired';
    }
  }

  /// Mark payment as failed with error message
  Future<void> markAsFailed(String requestId, String errorMessage) async {
    try {
      await _paymentRequestsCollection.doc(requestId).update({
        'status': AppConstants.paymentStatusFailed,
        'errorMessage': errorMessage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while marking payment as failed';
    }
  }

  /// Handle Firestore exceptions
  String _handleFirestoreException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action';
      case 'not-found':
        return 'Payment request not found';
      case 'already-exists':
        return 'Payment request already exists';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later';
      case 'unauthenticated':
        return 'Please log in to continue';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again';
      case 'deadline-exceeded':
        return 'Request timeout. Please check your connection';
      default:
        return e.message ?? 'A database error occurred';
    }
  }
}
