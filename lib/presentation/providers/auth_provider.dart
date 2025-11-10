import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/merchant_repository.dart';
import '../../data/models/merchant.dart';

/// Provider for authentication state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final MerchantRepository _merchantRepository = MerchantRepository();

  User? _user;
  Merchant? _merchant;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  Merchant? get merchant => _merchant;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    _initializeAuthListener();
  }

  /// Initialize authentication state listener
  void _initializeAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadMerchantData(user.uid);
      } else {
        _merchant = null;
      }
      notifyListeners();
    });
  }

  /// Load merchant data for current user
  Future<void> _loadMerchantData(String userId) async {
    try {
      _merchant = await _merchantRepository.getMerchantByUserId(userId);
      notifyListeners();
    } catch (e) {
      // Merchant data might not exist yet (during onboarding)
      _merchant = null;
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign up (alias for register)
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    return register(email: email, password: password);
  }

  /// Sign in user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      print('🔵 AuthProvider: Calling signInWithEmailAndPassword...');
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('🟢 AuthProvider: Sign in successful!');
      _setLoading(false);
      return true;
    } catch (e) {
      print('🔴 AuthProvider: Sign in error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signInWithGoogle();

      _setLoading(false);
      return true;
    } catch (e) {
      // Check if user is authenticated despite the error (type casting bug workaround)
      if (e.toString().contains('PigeonUserDetails') && _authService.isLoggedIn) {
        print('✅ AuthProvider: Google Sign-In succeeded despite error');
        _setLoading(false);
        return true;
      }
      
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      _merchant = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendEmailVerification();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Reload user to check email verification status
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      _user = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendPasswordResetEmail(email);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Refresh merchant data
  Future<void> refreshMerchantData() async {
    if (_user != null) {
      await _loadMerchantData(_user!.uid);
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

  /// Check if merchant exists for current user
  Future<bool> checkMerchantExists() async {
    if (_user == null) return false;
    return await _merchantRepository.merchantExists(_user!.uid);
  }

  /// Get KYC status
  String? get kycStatus => _merchant?.kycStatus;

  /// Check if KYC is approved
  bool get isKYCApproved => _merchant?.isApproved ?? false;

  /// Check if KYC is pending
  bool get isKYCPending => _merchant?.isPending ?? false;

  /// Check if KYC is rejected
  bool get isKYCRejected => _merchant?.isRejected ?? false;
}
