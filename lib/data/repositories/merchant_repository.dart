import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/merchant.dart';
import '../../core/constants/app_constants.dart';

/// Repository for managing merchant data in Firestore
class MerchantRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference
  CollectionReference get _merchantsCollection =>
      _firestore.collection(AppConstants.collectionMerchants);

  /// Create a new merchant document
  Future<String> createMerchant(Merchant merchant) async {
    try {
      final docRef = await _merchantsCollection.add(merchant.toMap());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while creating merchant profile';
    }
  }

  /// Get merchant by user ID
  Future<Merchant?> getMerchantByUserId(String userId) async {
    try {
      final querySnapshot = await _merchantsCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return Merchant.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while fetching merchant profile';
    }
  }

  /// Get merchant by document ID
  Future<Merchant?> getMerchantById(String merchantId) async {
    try {
      final doc = await _merchantsCollection.doc(merchantId).get();

      if (!doc.exists) {
        return null;
      }

      return Merchant.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while fetching merchant profile';
    }
  }

  /// Update merchant document
  Future<void> updateMerchant(String merchantId, Map<String, dynamic> data) async {
    try {
      // Always update the updatedAt timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _merchantsCollection.doc(merchantId).update(data);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while updating merchant profile';
    }
  }

  /// Update KYC status
  Future<void> updateKYCStatus({
    required String merchantId,
    required String status,
    String? rejectionReason,
    String? approvedBy,
  }) async {
    try {
      final data = <String, dynamic>{
        'kycStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == AppConstants.kycStatusApproved) {
        data['approvedAt'] = FieldValue.serverTimestamp();
        data['approvedBy'] = approvedBy;
        data['rejectionReason'] = null;
      } else if (status == AppConstants.kycStatusRejected) {
        data['rejectionReason'] = rejectionReason;
        data['approvedAt'] = null;
        data['approvedBy'] = null;
      }

      await _merchantsCollection.doc(merchantId).update(data);
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while updating KYC status';
    }
  }

  /// Add document to merchant's documents array
  Future<void> addDocument({
    required String merchantId,
    required Document document,
  }) async {
    try {
      await _merchantsCollection.doc(merchantId).update({
        'documents': FieldValue.arrayUnion([document.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while adding document';
    }
  }

  /// Remove document from merchant's documents array
  Future<void> removeDocument({
    required String merchantId,
    required Document document,
  }) async {
    try {
      await _merchantsCollection.doc(merchantId).update({
        'documents': FieldValue.arrayRemove([document.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while removing document';
    }
  }

  /// Update merchant tier and limits
  Future<void> updateTier({
    required String merchantId,
    required String tier,
    required double dailyLimit,
    required double monthlyLimit,
  }) async {
    try {
      await _merchantsCollection.doc(merchantId).update({
        'tier': tier,
        'dailyLimit': dailyLimit,
        'monthlyLimit': monthlyLimit,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while updating merchant tier';
    }
  }

  /// Stream merchant by user ID (for real-time updates)
  Stream<Merchant?> streamMerchantByUserId(String userId) {
    return _merchantsCollection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      final doc = snapshot.docs.first;
      return Merchant.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  /// Stream merchant by document ID (for real-time updates)
  Stream<Merchant?> streamMerchantById(String merchantId) {
    return _merchantsCollection.doc(merchantId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return Merchant.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  /// Get all merchants (admin only - for future use)
  Future<List<Merchant>> getAllMerchants({
    String? status,
    int limit = 50,
  }) async {
    try {
      Query query = _merchantsCollection;

      if (status != null) {
        query = query.where('kycStatus', isEqualTo: status);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) =>
              Merchant.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while fetching merchants';
    }
  }

  /// Delete merchant (soft delete - update status instead)
  Future<void> suspendMerchant(String merchantId, String reason) async {
    try {
      await _merchantsCollection.doc(merchantId).update({
        'kycStatus': AppConstants.kycStatusSuspended,
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while suspending merchant';
    }
  }

  /// Check if merchant exists by user ID
  Future<bool> merchantExists(String userId) async {
    try {
      final snapshot = await _merchantsCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      throw _handleFirestoreException(e);
    } catch (e) {
      throw 'An error occurred while checking merchant existence';
    }
  }

  /// Handle Firestore exceptions
  String _handleFirestoreException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action';
      case 'not-found':
        return 'Merchant not found';
      case 'already-exists':
        return 'Merchant already exists';
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
