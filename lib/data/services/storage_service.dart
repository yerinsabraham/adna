import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Service for handling Firebase Storage operations (document uploads)
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a KYC document
  /// @param file - File to upload
  /// @param userId - User ID for organizing files
  /// @param documentType - Type of document (cac, id_front, etc.)
  /// @returns Download URL of uploaded file
  Future<String> uploadKYCDocument({
    required File file,
    required String userId,
    required String documentType,
  }) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = '${documentType}_$timestamp$extension';

      // Create storage reference
      final ref = _storage.ref().child('kyc/$userId/$fileName');

      // Upload file with metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'userId': userId,
          'documentType': documentType,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(file, metadata);

      // Monitor upload progress (optional - can be used for progress indicator)
      // uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      //   double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      //   print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      // });

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    } catch (e) {
      throw 'An error occurred while uploading the document';
    }
  }

  /// Delete a KYC document
  /// @param fileUrl - Download URL of the file to delete
  Future<void> deleteKYCDocument(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    } catch (e) {
      throw 'An error occurred while deleting the document';
    }
  }

  /// Get file metadata
  /// @param fileUrl - Download URL of the file
  /// @returns Metadata object
  Future<FullMetadata> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    } catch (e) {
      throw 'An error occurred while getting file metadata';
    }
  }

  /// List all documents for a user
  /// @param userId - User ID
  /// @returns List of file references
  Future<List<Reference>> listUserDocuments(String userId) async {
    try {
      final ref = _storage.ref().child('kyc/$userId');
      final result = await ref.listAll();
      return result.items;
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    } catch (e) {
      throw 'An error occurred while listing documents';
    }
  }

  /// Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  /// Handle Firebase Storage exceptions
  String _handleStorageException(FirebaseException e) {
    switch (e.code) {
      case 'object-not-found':
        return 'File not found';
      case 'unauthorized':
        return 'You don\'t have permission to access this file';
      case 'canceled':
        return 'Upload was canceled';
      case 'unknown':
        return 'An unknown error occurred';
      case 'retry-limit-exceeded':
        return 'Maximum retry limit exceeded. Please try again';
      case 'invalid-checksum':
        return 'File integrity check failed. Please try again';
      case 'quota-exceeded':
        return 'Storage quota exceeded';
      default:
        return e.message ?? 'A storage error occurred';
    }
  }

  /// Upload file with progress tracking
  /// @param file - File to upload
  /// @param userId - User ID
  /// @param documentType - Document type
  /// @param onProgress - Callback for progress updates
  /// @returns Download URL
  Future<String> uploadWithProgress({
    required File file,
    required String userId,
    required String documentType,
    required Function(double progress) onProgress,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.path);
      final fileName = '${documentType}_$timestamp$extension';

      final ref = _storage.ref().child('kyc/$userId/$fileName');
      
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'userId': userId,
          'documentType': documentType,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(file, metadata);

      // Track progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw _handleStorageException(e);
    } catch (e) {
      throw 'An error occurred while uploading the document';
    }
  }
}
