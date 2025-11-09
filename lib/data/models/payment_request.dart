import 'package:cloud_firestore/cloud_firestore.dart';

/// Status timeline for tracking payment progress
class StatusTimeline {
  final DateTime created;
  final DateTime? received;
  final DateTime? confirmed;
  final DateTime? converted;
  final DateTime? settled;

  StatusTimeline({
    required this.created,
    this.received,
    this.confirmed,
    this.converted,
    this.settled,
  });

  Map<String, dynamic> toMap() {
    return {
      'created': Timestamp.fromDate(created),
      'received': received != null ? Timestamp.fromDate(received!) : null,
      'confirmed': confirmed != null ? Timestamp.fromDate(confirmed!) : null,
      'converted': converted != null ? Timestamp.fromDate(converted!) : null,
      'settled': settled != null ? Timestamp.fromDate(settled!) : null,
    };
  }

  factory StatusTimeline.fromMap(Map<String, dynamic> map) {
    return StatusTimeline(
      created: (map['created'] as Timestamp).toDate(),
      received: map['received'] != null ? (map['received'] as Timestamp).toDate() : null,
      confirmed: map['confirmed'] != null ? (map['confirmed'] as Timestamp).toDate() : null,
      converted: map['converted'] != null ? (map['converted'] as Timestamp).toDate() : null,
      settled: map['settled'] != null ? (map['settled'] as Timestamp).toDate() : null,
    );
  }

  StatusTimeline copyWith({
    DateTime? created,
    DateTime? received,
    DateTime? confirmed,
    DateTime? converted,
    DateTime? settled,
  }) {
    return StatusTimeline(
      created: created ?? this.created,
      received: received ?? this.received,
      confirmed: confirmed ?? this.confirmed,
      converted: converted ?? this.converted,
      settled: settled ?? this.settled,
    );
  }
}

/// Fee breakdown for transaction fees
class FeeBreakdown {
  final double grossAmount;
  final double adnaFee;
  final double partnerFee;
  final double netToMerchant;

  FeeBreakdown({
    required this.grossAmount,
    required this.adnaFee,
    required this.partnerFee,
    required this.netToMerchant,
  });

  Map<String, dynamic> toMap() {
    return {
      'grossAmount': grossAmount,
      'adnaFee': adnaFee,
      'partnerFee': partnerFee,
      'netToMerchant': netToMerchant,
    };
  }

  factory FeeBreakdown.fromMap(Map<String, dynamic> map) {
    return FeeBreakdown(
      grossAmount: (map['grossAmount'] ?? 0).toDouble(),
      adnaFee: (map['adnaFee'] ?? 0).toDouble(),
      partnerFee: (map['partnerFee'] ?? 0).toDouble(),
      netToMerchant: (map['netToMerchant'] ?? 0).toDouble(),
    );
  }

  FeeBreakdown copyWith({
    double? grossAmount,
    double? adnaFee,
    double? partnerFee,
    double? netToMerchant,
  }) {
    return FeeBreakdown(
      grossAmount: grossAmount ?? this.grossAmount,
      adnaFee: adnaFee ?? this.adnaFee,
      partnerFee: partnerFee ?? this.partnerFee,
      netToMerchant: netToMerchant ?? this.netToMerchant,
    );
  }

  double get totalFees => adnaFee + partnerFee;
}

/// Settlement details when payment is completed
class SettlementDetails {
  final String bankName;
  final String accountNumber;
  final double settledAmount;
  final DateTime settledAt;

  SettlementDetails({
    required this.bankName,
    required this.accountNumber,
    required this.settledAmount,
    required this.settledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'settledAmount': settledAmount,
      'settledAt': Timestamp.fromDate(settledAt),
    };
  }

  factory SettlementDetails.fromMap(Map<String, dynamic> map) {
    return SettlementDetails(
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      settledAmount: (map['settledAmount'] ?? 0).toDouble(),
      settledAt: (map['settledAt'] as Timestamp).toDate(),
    );
  }

  SettlementDetails copyWith({
    String? bankName,
    String? accountNumber,
    double? settledAmount,
    DateTime? settledAt,
  }) {
    return SettlementDetails(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      settledAmount: settledAmount ?? this.settledAmount,
      settledAt: settledAt ?? this.settledAt,
    );
  }
}

/// Payment request model
class PaymentRequest {
  final String id;
  final String merchantId;

  // Amounts
  final double amountNGN;
  final double cryptoAmount;
  final String cryptoType;
  final double exchangeRate;

  // Payment Details
  final String paymentAddress;
  final String paymentLink;
  final String qrCodeData;

  // Optional Info
  final String? description;
  final String? customerName;

  // Status
  final String status;
  final StatusTimeline statusTimeline;

  // Fees
  final FeeBreakdown feeBreakdown;

  // Settlement (populated when complete)
  final SettlementDetails? settlementDetails;

  // Error handling
  final String? errorMessage;

  // Timestamps
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? completedAt;

  PaymentRequest({
    required this.id,
    required this.merchantId,
    required this.amountNGN,
    required this.cryptoAmount,
    required this.cryptoType,
    required this.exchangeRate,
    required this.paymentAddress,
    required this.paymentLink,
    required this.qrCodeData,
    this.description,
    this.customerName,
    required this.status,
    required this.statusTimeline,
    required this.feeBreakdown,
    this.settlementDetails,
    this.errorMessage,
    required this.createdAt,
    required this.expiresAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchantId': merchantId,
      'amountNGN': amountNGN,
      'cryptoAmount': cryptoAmount,
      'cryptoType': cryptoType,
      'exchangeRate': exchangeRate,
      'paymentAddress': paymentAddress,
      'paymentLink': paymentLink,
      'qrCodeData': qrCodeData,
      'description': description,
      'customerName': customerName,
      'status': status,
      'statusTimeline': statusTimeline.toMap(),
      'feeBreakdown': feeBreakdown.toMap(),
      'settlementDetails': settlementDetails?.toMap(),
      'errorMessage': errorMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory PaymentRequest.fromMap(Map<String, dynamic> map, String docId) {
    return PaymentRequest(
      id: docId,
      merchantId: map['merchantId'] ?? '',
      amountNGN: (map['amountNGN'] ?? 0).toDouble(),
      cryptoAmount: (map['cryptoAmount'] ?? 0).toDouble(),
      cryptoType: map['cryptoType'] ?? '',
      exchangeRate: (map['exchangeRate'] ?? 0).toDouble(),
      paymentAddress: map['paymentAddress'] ?? '',
      paymentLink: map['paymentLink'] ?? '',
      qrCodeData: map['qrCodeData'] ?? '',
      description: map['description'],
      customerName: map['customerName'],
      status: map['status'] ?? 'pending',
      statusTimeline: StatusTimeline.fromMap(map['statusTimeline'] ?? {}),
      feeBreakdown: FeeBreakdown.fromMap(map['feeBreakdown'] ?? {}),
      settlementDetails: map['settlementDetails'] != null
          ? SettlementDetails.fromMap(map['settlementDetails'])
          : null,
      errorMessage: map['errorMessage'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  PaymentRequest copyWith({
    String? id,
    String? merchantId,
    double? amountNGN,
    double? cryptoAmount,
    String? cryptoType,
    double? exchangeRate,
    String? paymentAddress,
    String? paymentLink,
    String? qrCodeData,
    String? description,
    String? customerName,
    String? status,
    StatusTimeline? statusTimeline,
    FeeBreakdown? feeBreakdown,
    SettlementDetails? settlementDetails,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? completedAt,
  }) {
    return PaymentRequest(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      amountNGN: amountNGN ?? this.amountNGN,
      cryptoAmount: cryptoAmount ?? this.cryptoAmount,
      cryptoType: cryptoType ?? this.cryptoType,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      paymentAddress: paymentAddress ?? this.paymentAddress,
      paymentLink: paymentLink ?? this.paymentLink,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      description: description ?? this.description,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      statusTimeline: statusTimeline ?? this.statusTimeline,
      feeBreakdown: feeBreakdown ?? this.feeBreakdown,
      settlementDetails: settlementDetails ?? this.settlementDetails,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Backward compatibility aliases
  double get nairaAmount => amountNGN;
  String get walletAddress => paymentAddress;
  String get reference => id;

  /// Check if payment is pending
  bool get isPending => status == 'pending';

  /// Check if payment is completed
  bool get isCompleted => status == 'completed';

  /// Check if payment has failed
  bool get isFailed => status == 'failed';

  /// Check if payment has expired
  bool get isExpired => status == 'expired' || DateTime.now().isAfter(expiresAt);

  /// Get remaining time until expiry in seconds
  int get remainingSeconds {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inSeconds;
  }

  /// Check if awaiting confirmation
  bool get isAwaitingConfirmation => status == 'awaiting_confirmation';

  /// Check if confirmed
  bool get isConfirmed => status == 'confirmed';

  /// Check if converting
  bool get isConverting => status == 'converting';

  /// Check if settling
  bool get isSettling => status == 'settling';
}

/// Transaction model (completed payments)
/// Uses the same structure as PaymentRequest
typedef Transaction = PaymentRequest;
