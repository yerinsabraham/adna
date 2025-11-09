import '../../core/constants/app_constants.dart';
import 'partner_api_service.dart';

/// Mock implementation of PartnerApiService for development
/// Returns test data without requiring real API credentials
class MockPartnerApiService implements PartnerApiService {
  // Simulate API delay
  static const Duration _apiDelay = Duration(milliseconds: 800);

  @override
  Future<double> getCryptoPrice(String cryptoType) async {
    // Simulate network delay
    await Future.delayed(_apiDelay);

    // Return mock exchange rates
    switch (cryptoType.toUpperCase()) {
      case AppConstants.cryptoBTC:
        return AppConstants.mockBTCRate; // ₦120,000,000 per BTC
      case AppConstants.cryptoUSDT:
        return AppConstants.mockUSDTRate; // ₦1,600 per USDT
      case AppConstants.cryptoUSDC:
        return AppConstants.mockUSDCRate; // ₦1,600 per USDC
      case AppConstants.cryptoSOL:
        return AppConstants.mockSOLRate; // ₦300,000 per SOL
      default:
        throw Exception('Unsupported crypto type: $cryptoType');
    }
  }

  @override
  Future<String> generatePaymentAddress(String cryptoType, double amount) async {
    // Simulate network delay
    await Future.delayed(_apiDelay);

    // Return test addresses based on crypto type
    switch (cryptoType.toUpperCase()) {
      case AppConstants.cryptoBTC:
        return AppConstants.testBTCAddress;
      case AppConstants.cryptoUSDT:
        return AppConstants.testUSDTAddress;
      case AppConstants.cryptoUSDC:
        return AppConstants.testUSDCAddress;
      case AppConstants.cryptoSOL:
        return AppConstants.testSOLAddress;
      default:
        throw Exception('Unsupported crypto type: $cryptoType');
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactionStatus(String transactionId) async {
    // Simulate network delay
    await Future.delayed(_apiDelay);

    // Return mock transaction status
    // In a real implementation, this would query the blockchain
    return {
      'transactionId': transactionId,
      'status': 'pending',
      'confirmations': 0,
      'requiredConfirmations': 3,
      'receivedAmount': 0.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<bool> validateAddress(String address, String cryptoType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Basic validation (not comprehensive, just for testing)
    switch (cryptoType.toUpperCase()) {
      case AppConstants.cryptoBTC:
        // BTC addresses can start with 1, 3, or bc1
        return address.startsWith('1') ||
            address.startsWith('3') ||
            address.startsWith('bc1');
      case AppConstants.cryptoUSDT:
      case AppConstants.cryptoUSDC:
        // TRC-20 addresses start with T
        return address.startsWith('T') && address.length == 34;
      case AppConstants.cryptoSOL:
        // Solana addresses are base58 encoded, typically 32-44 characters
        return address.length >= 32 && address.length <= 44;
      default:
        return false;
    }
  }

  /// Helper method to simulate different transaction statuses
  /// (for testing UI with different states)
  Future<Map<String, dynamic>> getMockTransactionStatus(String mockStatus) async {
    await Future.delayed(_apiDelay);

    switch (mockStatus) {
      case 'received':
        return {
          'status': 'received',
          'confirmations': 1,
          'requiredConfirmations': 3,
          'receivedAmount': 0.125,
        };
      case 'confirmed':
        return {
          'status': 'confirmed',
          'confirmations': 3,
          'requiredConfirmations': 3,
          'receivedAmount': 0.125,
        };
      case 'failed':
        return {
          'status': 'failed',
          'error': 'Insufficient amount received',
        };
      default:
        return {
          'status': 'pending',
          'confirmations': 0,
          'requiredConfirmations': 3,
        };
    }
  }
}
