import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Check if user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register new user with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email immediately after registration
      await sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during registration';
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during sign in';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'An error occurred while signing out';
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      print('🔵 DEBUG: Starting Google Sign-In process...');
      
      // Sign out from previous session
      print('🔵 DEBUG: Signing out from previous Google session...');
      await _googleSignIn.signOut();
      print('🔵 DEBUG: Previous session signed out successfully');
      
      // Trigger the authentication flow
      print('🔵 DEBUG: Triggering Google Sign-In UI...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('🔵 DEBUG: Google Sign-In UI returned: ${googleUser != null ? "User selected" : "User cancelled"}');

      if (googleUser == null) {
        print('🔴 DEBUG: Google sign-in was cancelled by user');
        throw 'Google sign-in was cancelled';
      }

      print('🔵 DEBUG: Google user email: ${googleUser.email}');
      print('🔵 DEBUG: Google user ID: ${googleUser.id}');

      // Obtain the auth details from the request
      print('🔵 DEBUG: Getting authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      
      print('🔵 DEBUG: Access token present: ${googleAuth.accessToken != null}');
      print('🔵 DEBUG: ID token present: ${googleAuth.idToken != null}');

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('🔴 DEBUG: Failed to get tokens - accessToken: ${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}');
        throw 'Failed to get authentication tokens from Google';
      }

      // Create a new credential
      print('🔵 DEBUG: Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('🔵 DEBUG: Firebase credential created successfully');

      // Sign in to Firebase with the Google credential
      print('🔵 DEBUG: Signing in to Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);
      print('✅ DEBUG: Google Sign-In successful! User: ${userCredential.user?.email}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('🔴 DEBUG: FirebaseAuthException - Code: ${e.code}, Message: ${e.message}');
      throw _handleAuthException(e);
    } on Exception catch (e) {
      print('🔴 DEBUG: Exception during Google Sign-In: ${e.toString()}');
      if (e.toString().contains('sign_in_canceled')) {
        throw 'Google sign-in was cancelled';
      }
      if (e.toString().contains('network_error')) {
        throw 'Network error. Please check your internet connection';
      }
      throw 'Failed to sign in with Google. Please try again';
    } catch (e) {
      print('🔴 DEBUG: Unexpected error during Google sign-in: ${e.toString()}');
      print('🔴 DEBUG: Error type: ${e.runtimeType}');
      
      // If Firebase auth succeeded (user is logged in), don't throw error
      if (_auth.currentUser != null) {
        print('✅ DEBUG: Firebase auth succeeded despite error. User: ${_auth.currentUser?.email}');
        // Create a fake UserCredential to return since the real one failed
        throw e.toString(); // Still throw to trigger the provider workaround
      }
      
      throw 'An unexpected error occurred during Google sign-in: ${e.toString()}';
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw 'Too many verification emails sent. Please try again later';
      }
      throw 'Failed to send verification email';
    } catch (e) {
      throw 'An error occurred while sending verification email';
    }
  }

  /// Reload current user to get updated data (e.g., email verification status)
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw 'Failed to reload user data';
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred while sending password reset email';
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in';
      }

      // Re-authenticate user before changing password
      final email = user.email;
      if (email == null) {
        throw 'User email not found';
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred while changing password';
    }
  }

  /// Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in';
      }

      await user.updateEmail(newEmail);
      await sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred while updating email';
    }
  }

  /// Delete user account
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in';
      }

      // Re-authenticate before deleting
      final email = user.email;
      if (email == null) {
        throw 'User email not found';
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred while deleting account';
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters with letters and numbers';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'requires-recent-login':
        return 'Please log in again to perform this action';
      case 'invalid-credential':
        return 'Invalid credentials provided';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}
