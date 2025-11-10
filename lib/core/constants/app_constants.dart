/// App-wide constants for Adna
class AppConstants {
  AppConstants._(); // Private constructor

  // App Info
  static const String appName = 'Adna';
  static const String appTagline = 'Accept Crypto, Receive Naira';

  // Firebase
  static const String firebaseProjectId = 'adna-faa82';

  // Transaction Limits (in Naira)
  static const double minTransactionAmount = 100000; // ₦100,000
  static const double basicDailyLimit = 5000000; // ₦5M
  static const double basicMonthlyLimit = 50000000; // ₦50M
  static const double businessDailyLimit = 50000000; // ₦50M
  static const double businessMonthlyLimit = 500000000; // ₦500M
  static const double enterpriseDailyLimit = 500000000; // ₦500M
  static const double enterpriseMonthlyLimit = 5000000000; // ₦5B

  // Fees
  static const double adnaFeePercentage = 2.5; // 2.5%
  static const double partnerFeePercentage = 0.5; // 0.5% (example)

  // Payment Expiry
  static const int paymentExpiryMinutes = 30;

  // Crypto Types
  static const String cryptoBTC = 'BTC';
  static const String cryptoUSDT = 'USDT';
  static const String cryptoUSDC = 'USDC';
  static const String cryptoSOL = 'SOL';
  static const List<String> supportedCryptos = [cryptoBTC, cryptoUSDT, cryptoUSDC, cryptoSOL];
  static const List<String> cryptoTypes = [cryptoBTC, cryptoUSDT, cryptoUSDC, cryptoSOL];

  // Crypto Icon Paths
  static const Map<String, String> cryptoIcons = {
    cryptoBTC: 'assets/icons/bitcoin-logo.png',
    cryptoUSDT: 'assets/icons/usdt-logo.png',
    cryptoUSDC: 'assets/icons/usdc-logo.png',
    cryptoSOL: 'assets/icons/solana-logo.png',
  };

  // Crypto Full Names
  static const Map<String, String> cryptoNames = {
    cryptoBTC: 'Bitcoin',
    cryptoUSDT: 'Tether USD',
    cryptoUSDC: 'USD Coin',
    cryptoSOL: 'Solana',
  };

  /// Get icon path for crypto type
  static String getCryptoIcon(String cryptoType) {
    return cryptoIcons[cryptoType] ?? 'assets/icons/bitcoin-logo.png';
  }

  /// Get full name for crypto type
  static String getCryptoName(String cryptoType) {
    return cryptoNames[cryptoType] ?? cryptoType;
  }

  // Business Types
  static const List<String> businessTypes = [
    'Sole Proprietorship',
    'Partnership',
    'Limited Liability Company (LLC)',
    'Public Limited Company (PLC)',
    'Non-Governmental Organization (NGO)',
  ];

  // Industries
  static const List<String> industries = [
    'Automotive',
    'Real Estate',
    'Luxury Goods',
    'Electronics',
    'Technology',
    'Retail',
    'Wholesale/Import',
    'Financial Services',
    'Healthcare',
    'Education',
    'Hospitality',
    'Manufacturing',
    'Other',
  ];

  // KYC Status
  static const String kycStatusPending = 'pending';
  static const String kycStatusApproved = 'approved';
  static const String kycStatusRejected = 'rejected';
  static const String kycStatusSuspended = 'suspended';

  // Payment Status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusAwaitingConfirmation = 'awaiting_confirmation';
  static const String paymentStatusConfirmed = 'confirmed';
  static const String paymentStatusConverting = 'converting';
  static const String paymentStatusSettling = 'settling';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusExpired = 'expired';

  // Business Categories
  static const List<String> businessCategories = [
    'Automotive',
    'Real Estate',
    'Luxury Goods',
    'Electronics',
    'Wholesale/Import',
    'Other',
  ];

  // ID Types
  static const List<String> idTypes = [
    'International Passport',
    'Driver\'s License',
    'National ID Card',
    'Voter\'s Card',
  ];

  // Account Types
  static const List<String> accountTypes = [
    'Savings',
    'Current',
    'Corporate',
  ];

  // Nigerian Banks
  static const List<String> nigerianBanks = [
    'Access Bank',
    'Ecobank',
    'Fidelity Bank',
    'First Bank',
    'First City Monument Bank (FCMB)',
    'GTBank',
    'Keystone Bank',
    'Polaris Bank',
    'Stanbic IBTC',
    'Sterling Bank',
    'Union Bank',
    'United Bank for Africa (UBA)',
    'Unity Bank',
    'Wema Bank',
    'Zenith Bank',
  ];

  // Nigerian Banks with Paystack Bank Codes
  static const Map<String, String> nigerianBankCodes = {
    'Access Bank': '044',
    'Ecobank': '050',
    'Fidelity Bank': '070',
    'First Bank': '011',
    'First City Monument Bank (FCMB)': '214',
    'GTBank': '058',
    'Keystone Bank': '082',
    'Polaris Bank': '076',
    'Stanbic IBTC': '221',
    'Sterling Bank': '232',
    'Union Bank': '032',
    'United Bank for Africa (UBA)': '033',
    'Unity Bank': '215',
    'Wema Bank': '035',
    'Zenith Bank': '057',
  };

  /// Get bank code for bank name
  static String getBankCode(String bankName) {
    return nigerianBankCodes[bankName] ?? '000';
  }

  // Nigerian States
  static const List<String> nigerianStates = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'FCT',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];

  // Document Types
  static const String docTypeCAC = 'cac';
  static const String docTypeIDFront = 'id_front';
  static const String docTypeIDBack = 'id_back';
  static const String docTypeAddressProof = 'address_proof';
  static const String docTypeBankStatement = 'bank_statement';

  // File Upload
  static const int maxFileSizeBytes = 5242880; // 5MB
  static const List<String> allowedFileExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  // Firestore Collections
  static const String collectionMerchants = 'merchants';
  static const String collectionPaymentRequests = 'paymentRequests';
  static const String collectionTransactions = 'transactions';

  // Storage Paths
  static const String storageKYCPath = 'kyc';

  // Pagination
  static const int transactionsPerPage = 20;

  // Merchant Tiers
  static const String tierBasic = 'basic';
  static const String tierBusiness = 'business';
  static const String tierEnterprise = 'enterprise';

  // Merchant Tier Details with Limits
  static const Map<String, Map<String, dynamic>> merchantTiers = {
    tierBasic: {
      'name': 'Basic (Individual)',
      'description': 'For individuals without registered business',
      'dailyLimit': 1000000, // ₦1M daily
      'monthlyLimit': 10000000, // ₦10M monthly
      'requiresCAC': false,
      'requiresBusinessInfo': false,
      'verificationLevel': 'basic',
    },
    tierBusiness: {
      'name': 'Business (BN)',
      'description': 'For registered business names',
      'dailyLimit': 20000000, // ₦20M daily
      'monthlyLimit': 200000000, // ₦200M monthly
      'requiresCAC': true,
      'requiresBusinessInfo': true,
      'verificationLevel': 'business',
    },
    tierEnterprise: {
      'name': 'Enterprise (RC)',
      'description': 'For registered companies (Limited)',
      'dailyLimit': 100000000, // ₦100M daily
      'monthlyLimit': 1000000000, // ₦1B monthly
      'requiresCAC': true,
      'requiresBusinessInfo': true,
      'verificationLevel': 'enterprise',
    },
  };

  // Business Registration Types
  static const String regTypeIndividual = 'individual';
  static const String regTypeBusinessName = 'business_name';
  static const String regTypeLimitedCompany = 'limited_company';

  static const Map<String, Map<String, dynamic>> businessRegistrationTypes = {
    regTypeIndividual: {
      'label': 'Individual (No Business Registration)',
      'description': 'I don\'t have a registered business',
      'tier': tierBasic,
      'icon': '👤',
    },
    regTypeBusinessName: {
      'label': 'Business Name (BN)',
      'description': 'Registered business name with CAC',
      'tier': tierBusiness,
      'icon': '🏪',
    },
    regTypeLimitedCompany: {
      'label': 'Limited Company (RC)',
      'description': 'Registered company (Ltd, PLC, etc)',
      'tier': tierEnterprise,
      'icon': '🏢',
    },
  };

  /// Get tier details
  static Map<String, dynamic> getTierDetails(String tier) {
    return merchantTiers[tier] ?? merchantTiers[tierBasic]!;
  }

  /// Get daily limit for tier
  static double getDailyLimit(String tier) {
    return (merchantTiers[tier]?['dailyLimit'] ?? basicDailyLimit).toDouble();
  }

  /// Get monthly limit for tier
  static double getMonthlyLimit(String tier) {
    return (merchantTiers[tier]?['monthlyLimit'] ?? basicMonthlyLimit).toDouble();
  }

  // Test Crypto Addresses (for mock service)
  static const String testBTCAddress = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';
  static const String testUSDTAddress = 'TXYZeZKtHkBJRUMsFKyKqNn6uyedMJ7J7Z';
  static const String testUSDCAddress = 'TXYZeZKtHkBJRUMsFKyKqNn6uyedMJ7J7Z';
  static const String testSOLAddress = 'DYw8jCTfwHNRJhhmFcbXvVDTqWMEVFBX6ZKUmG5CNSKK';

  // Mock Exchange Rates (for development)
  static const double mockBTCRate = 120000000.0; // ₦120M per BTC
  static const double mockUSDTRate = 1600.0; // ₦1,600 per USDT
  static const double mockUSDCRate = 1600.0; // ₦1,600 per USDC
  static const double mockSOLRate = 300000.0; // ₦300K per SOL

  // API Timeouts
  static const int apiTimeoutSeconds = 30;

  // Date Formats
  static const String dateFormatFull = 'MMM dd, yyyy hh:mm a';
  static const String dateFormatShort = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
}
