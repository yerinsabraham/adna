import '../core/constants/app_constants.dart';

/// Form validation utilities
class Validators {
  Validators._(); // Private constructor

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    
    if (!hasLetter || !hasNumber) {
      return 'Password must contain letters and numbers';
    }
    
    return null;
  }

  /// Validates password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates required field
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int minLen, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLen) {
      return '$fieldName must be at least $minLen characters';
    }
    
    return null;
  }

  /// Validates Nigerian phone number
  static String? nigerianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    
    // Check if starts with 234 (international) or 0 (local)
    if (!cleaned.startsWith('234') && !cleaned.startsWith('0')) {
      return 'Phone must start with +234 or 0';
    }
    
    // Check length (234XXXXXXXXXX = 13 digits, 0XXXXXXXXXX = 11 digits)
    if (cleaned.startsWith('234') && cleaned.length != 13) {
      return 'Invalid phone number format';
    }
    
    if (cleaned.startsWith('0') && cleaned.length != 11) {
      return 'Invalid phone number format';
    }
    
    return null;
  }

  /// Alias for nigerianPhone
  static String? phoneNumber(String? value) => nigerianPhone(value);

  /// Validates BVN or NIN (11 digits)
  static String? bvnOrNin(String? value) {
    if (value == null || value.isEmpty) {
      return 'BVN or NIN is required';
    }
    
    // Remove all non-digit characters
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.length != 11) {
      return 'BVN/NIN must be exactly 11 digits';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'BVN/NIN must contain only digits';
    }
    
    return null;
  }

  /// Alias for bvnOrNin
  static String? bvn(String? value) => bvnOrNin(value);

  /// Validates Nigerian bank account number (10 digits)
  static String? accountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account number is required';
    }
    
    // Remove all non-digit characters
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.length != 10) {
      return 'Account number must be exactly 10 digits';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Account number must contain only digits';
    }
    
    return null;
  }

  /// Validates CAC number format (RC + 6-7 digits)
  static String? cacNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'CAC number is required';
    }
    
    // Remove spaces and convert to uppercase
    final cleaned = value.replaceAll(' ', '').toUpperCase();
    
    if (!RegExp(r'^RC\d{6,7}$').hasMatch(cleaned)) {
      return 'CAC format: RC123456 or RC1234567';
    }
    
    return null;
  }

  /// Validates TIN (Tax Identification Number)
  static String? tin(String? value) {
    if (value == null || value.isEmpty) {
      return 'TIN is required';
    }
    
    // Basic validation - TIN format can vary
    if (value.trim().length < 8) {
      return 'Please enter a valid TIN';
    }
    
    return null;
  }

  /// Validates amount
  static String? amount(String? value, {double? minAmount, double? maxAmount}) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    // Remove commas and non-digit characters except decimal point
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    final amount = double.tryParse(cleaned);
    
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (minAmount != null && amount < minAmount) {
      return 'Amount must be at least ₦${_formatNumber(minAmount)}';
    }
    
    if (maxAmount != null && amount > maxAmount) {
      return 'Amount cannot exceed ₦${_formatNumber(maxAmount)}';
    }
    
    return null;
  }

  /// Validates dropdown selection
  static String? dropdown(dynamic value, [String fieldName = 'This field']) {
    if (value == null || (value is String && value.isEmpty)) {
      return 'Please select $fieldName';
    }
    return null;
  }

  /// Validates file size
  static String? fileSize(int sizeInBytes) {
    if (sizeInBytes > AppConstants.maxFileSizeBytes) {
      return 'File size must not exceed 5MB';
    }
    return null;
  }

  /// Validates file extension
  static String? fileExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    if (!AppConstants.allowedFileExtensions.contains(extension)) {
      return 'Only PDF, JPG, and PNG files are allowed';
    }
    
    return null;
  }

  /// Helper function to format numbers
  static String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}
