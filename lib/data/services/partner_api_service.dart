/// Abstract interface for partner crypto API service
/// This abstraction allows us to swap between mock and real implementations
/// without changing any app code.
abstract class PartnerApiService {
  /// Gets the current exchange rate for a crypto type to NGN
  /// @param cryptoType - 'BTC', 'USDT', or 'USDC'
  /// @returns Exchange rate (e.g., 120000000.0 for BTC = ₦120M)
  Future<double> getCryptoPrice(String cryptoType);

  /// Generates a payment address for receiving crypto
  /// @param cryptoType - 'BTC', 'USDT', or 'USDC'
  /// @param amount - Amount of crypto to receive
  /// @returns Crypto wallet address
  Future<String> generatePaymentAddress(String cryptoType, double amount);

  /// Gets the status of a transaction
  /// @param transactionId - Unique transaction identifier
  /// @returns Map with status, confirmations, etc.
  Future<Map<String, dynamic>> getTransactionStatus(String transactionId);

  /// Validates a crypto address format
  /// @param address - Crypto wallet address
  /// @param cryptoType - 'BTC', 'USDT', or 'USDC'
  /// @returns true if address is valid
  Future<bool> validateAddress(String address, String cryptoType);
}
