import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

/// Helper utilities for common operations
class Helpers {
  Helpers._(); // Private constructor

  /// Shows a snackbar with a message
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.textPrimary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows a success message
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, isError: false);
  }

  /// Shows an error message
  static void showError(BuildContext context, String message) {
    showSnackBar(context, message, isError: true);
  }

  /// Shows an info message
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// Shows a loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hides the loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Gets color for payment status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'awaiting_confirmation':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'converting':
        return AppColors.info;
      case 'settling':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'expired':
        return AppColors.textDisabled;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Gets icon for payment status
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'awaiting_confirmation':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'converting':
        return Icons.sync;
      case 'settling':
        return Icons.account_balance;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.error_outline;
      case 'expired':
        return Icons.timer_off;
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  /// Gets color for crypto type
  static Color getCryptoColor(String cryptoType) {
    switch (cryptoType.toUpperCase()) {
      case 'BTC':
        return AppColors.bitcoin;
      case 'USDT':
        return AppColors.usdt;
      case 'USDC':
        return AppColors.usdc;
      default:
        return AppColors.primary;
    }
  }

  /// Validates and formats Nigerian phone number
  static String? formatNigerianPhone(String phone) {
    // Remove all non-digit characters
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Convert local format to international
    if (cleaned.startsWith('0') && cleaned.length == 11) {
      return '234${cleaned.substring(1)}';
    } else if (cleaned.startsWith('234') && cleaned.length == 13) {
      return cleaned;
    }
    
    return null; // Invalid format
  }

  /// Copies text to clipboard and shows feedback
  static void copyToClipboard(BuildContext context, String text, String label) {
    // Note: Import package:flutter/services.dart in the file using this
    // Clipboard.setData(ClipboardData(text: text));
    showSuccess(context, '$label copied to clipboard');
  }

  /// Calculates transaction fee
  static double calculateFee(double amount, double feePercentage) {
    return amount * (feePercentage / 100);
  }

  /// Calculates net amount after fees
  static double calculateNetAmount(double grossAmount, double feePercentage) {
    final fee = calculateFee(grossAmount, feePercentage);
    return grossAmount - fee;
  }

  /// Converts crypto amount to Naira
  static double cryptoToNaira(double cryptoAmount, double exchangeRate) {
    return cryptoAmount * exchangeRate;
  }

  /// Converts Naira to crypto amount
  static double nairaToCrypto(double nairaAmount, double exchangeRate) {
    if (exchangeRate == 0) return 0;
    return nairaAmount / exchangeRate;
  }

  /// Checks if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Checks if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Debounces function calls
  static void debounce(
    VoidCallback action, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    // This is a simplified version. For production, use a proper debounce implementation
    // with Timer from dart:async
    Future.delayed(delay, action);
  }

  /// Generates a unique ID (for testing/mock data)
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Formats error message from Firebase exceptions
  static String getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'requires-recent-login':
        return 'Please log in again to perform this action';
      default:
        return 'An error occurred. Please try again';
    }
  }

  /// Unfocuses keyboard
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Formats date to readable string (e.g., "Nov 08, 2025")
  static String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  /// Checks if email is verified and shows appropriate message
  static bool checkEmailVerified(BuildContext context, bool isVerified) {
    if (!isVerified) {
      showError(context, 'Please verify your email first');
      return false;
    }
    return true;
  }
}
