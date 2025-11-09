import 'package:intl/intl.dart';

/// Formatting utilities for displaying data
class Formatters {
  Formatters._(); // Private constructor

  /// Formats amount in Naira currency
  /// Example: 15000000 → ₦15,000,000.00
  static String formatNaira(double amount, {bool showDecimals = true}) {
    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: showDecimals ? 2 : 0,
    );
    
    return formatter.format(amount);
  }

  /// Formats amount without currency symbol
  /// Example: 15000000 → 15,000,000.00
  static String formatNumber(double number, {int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '',
      decimalDigits: decimalDigits,
    );
    
    return formatter.format(number).trim();
  }

  /// Formats crypto amount with appropriate decimal places
  /// BTC: 8 decimals, USDT/USDC: 2 decimals
  static String formatCrypto(double amount, String cryptoType) {
    int decimals = cryptoType == 'BTC' ? 8 : 2;
    
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: decimals,
    );
    
    return '${formatter.format(amount).trim()} $cryptoType';
  }

  /// Formats date in full format
  /// Example: Nov 08, 2025 02:30 PM
  static String formatDateFull(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  /// Formats date in short format
  /// Example: Nov 08, 2025
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Formats time only
  /// Example: 02:30 PM
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// Formats date relative to now
  /// Example: "2 hours ago", "Yesterday", "3 days ago"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Masks account number
  /// Example: 0123456789 → ****6789
  static String maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '****$lastFour';
  }

  /// Masks crypto address
  /// Example: bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh → bc1q...x0wlh
  static String maskCryptoAddress(String address) {
    if (address.length <= 10) return address;
    
    final start = address.substring(0, 6);
    final end = address.substring(address.length - 5);
    return '$start...$end';
  }

  /// Formats phone number
  /// Example: 2348012345678 → +234 801 234 5678
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.startsWith('234')) {
      // International format
      if (cleaned.length == 13) {
        return '+234 ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
      }
    } else if (cleaned.startsWith('0')) {
      // Local format
      if (cleaned.length == 11) {
        return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
      }
    }
    
    return phone; // Return original if format not recognized
  }

  /// Formats percentage
  /// Example: 0.025 → 2.5%
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Formats file size
  /// Example: 1048576 → 1.0 MB
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Capitalizes first letter of each word
  /// Example: "john doe" → "John Doe"
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formats duration in minutes and seconds
  /// Example: 125 → "2:05"
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Converts crypto type to display name with icon
  /// Example: BTC → Bitcoin (BTC)
  static String getCryptoDisplayName(String cryptoType) {
    switch (cryptoType) {
      case 'BTC':
        return 'Bitcoin (BTC)';
      case 'USDT':
        return 'Tether (USDT)';
      case 'USDC':
        return 'USD Coin (USDC)';
      default:
        return cryptoType;
    }
  }

  /// Gets status display text with proper formatting
  static String getStatusDisplayText(String status) {
    return status
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
