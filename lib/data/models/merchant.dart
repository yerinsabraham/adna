import 'package:cloud_firestore/cloud_firestore.dart';

/// Address model for business and residential addresses
class Address {
  final String street;
  final String city;
  final String state;

  Address({
    required this.street,
    required this.city,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'state': state,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
    );
  }

  Address copyWith({
    String? street,
    String? city,
    String? state,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }

  @override
  String toString() => '$street, $city, $state';
}

/// Document model for KYC documents
class Document {
  final String type;
  final String url;
  final String fileName;
  final DateTime uploadedAt;

  Document({
    required this.type,
    required this.url,
    required this.fileName,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'url': url,
      'fileName': fileName,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      type: map['type'] ?? '',
      url: map['url'] ?? '',
      fileName: map['fileName'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Document copyWith({
    String? type,
    String? url,
    String? fileName,
    DateTime? uploadedAt,
  }) {
    return Document(
      type: type ?? this.type,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

/// Merchant model representing a business user
class Merchant {
  final String id;
  final String userId;
  final String email;

  // Business Information
  final String businessName;
  final String cacNumber;
  final String tin;
  final String category;
  final Address businessAddress;
  final String businessPhone;
  final String? businessEmail;

  // Owner Information
  final String ownerName;
  final String bvnOrNin;
  final String? dateOfBirth;
  final Address residentialAddress;
  final String ownerPhone;
  final String idType;

  // Bank Account
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String accountType;

  // KYC Status
  final String kycStatus;
  final String? rejectionReason;

  // Documents
  final List<Document> documents;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  // Tier System
  final String tier;
  final double dailyLimit;
  final double monthlyLimit;
  final String registrationType; // individual, business_name, limited_company
  
  // Admin Access
  final bool isAdmin;

  Merchant({
    required this.id,
    required this.userId,
    required this.email,
    required this.businessName,
    required this.cacNumber,
    required this.tin,
    required this.category,
    required this.businessAddress,
    required this.businessPhone,
    this.businessEmail,
    required this.ownerName,
    required this.bvnOrNin,
    this.dateOfBirth,
    required this.residentialAddress,
    required this.ownerPhone,
    required this.idType,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.accountType,
    required this.kycStatus,
    this.rejectionReason,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.approvedBy,
    required this.tier,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.registrationType,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'email': email,
      'businessName': businessName,
      'cacNumber': cacNumber,
      'tin': tin,
      'category': category,
      'businessAddress': businessAddress.toMap(),
      'businessPhone': businessPhone,
      'businessEmail': businessEmail,
      'ownerName': ownerName,
      'bvnOrNin': bvnOrNin,
      'dateOfBirth': dateOfBirth,
      'residentialAddress': residentialAddress.toMap(),
      'ownerPhone': ownerPhone,
      'idType': idType,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'accountType': accountType,
      'kycStatus': kycStatus,
      'rejectionReason': rejectionReason,
      'documents': documents.map((doc) => doc.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
      'tier': tier,
      'dailyLimit': dailyLimit,
      'monthlyLimit': monthlyLimit,
      'registrationType': registrationType,
      'isAdmin': isAdmin,
    };
  }

  factory Merchant.fromMap(Map<String, dynamic> map, String docId) {
    return Merchant(
      id: docId,
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      businessName: map['businessName'] ?? '',
      cacNumber: map['cacNumber'] ?? '',
      tin: map['tin'] ?? '',
      category: map['category'] ?? '',
      businessAddress: Address.fromMap(map['businessAddress'] ?? {}),
      businessPhone: map['businessPhone'] ?? '',
      businessEmail: map['businessEmail'],
      ownerName: map['ownerName'] ?? '',
      bvnOrNin: map['bvnOrNin'] ?? '',
      dateOfBirth: map['dateOfBirth'],
      residentialAddress: Address.fromMap(map['residentialAddress'] ?? {}),
      ownerPhone: map['ownerPhone'] ?? '',
      idType: map['idType'] ?? '',
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      accountName: map['accountName'] ?? '',
      accountType: map['accountType'] ?? '',
      kycStatus: map['kycStatus'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
      documents: (map['documents'] as List<dynamic>?)
              ?.map((doc) => Document.fromMap(doc as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
      approvedBy: map['approvedBy'],
      tier: map['tier'] ?? 'basic',
      dailyLimit: (map['dailyLimit'] ?? 5000000).toDouble(),
      monthlyLimit: (map['monthlyLimit'] ?? 50000000).toDouble(),
      registrationType: map['registrationType'] ?? 'individual',
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Merchant copyWith({
    String? id,
    String? userId,
    String? email,
    String? businessName,
    String? cacNumber,
    String? tin,
    String? category,
    Address? businessAddress,
    String? businessPhone,
    String? businessEmail,
    String? ownerName,
    String? bvnOrNin,
    String? dateOfBirth,
    Address? residentialAddress,
    String? ownerPhone,
    String? idType,
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? accountType,
    String? kycStatus,
    String? rejectionReason,
    List<Document>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? tier,
    double? dailyLimit,
    double? monthlyLimit,
    String? registrationType,
    bool? isAdmin,
  }) {
    return Merchant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      businessName: businessName ?? this.businessName,
      cacNumber: cacNumber ?? this.cacNumber,
      tin: tin ?? this.tin,
      category: category ?? this.category,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      ownerName: ownerName ?? this.ownerName,
      bvnOrNin: bvnOrNin ?? this.bvnOrNin,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      idType: idType ?? this.idType,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      kycStatus: kycStatus ?? this.kycStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      tier: tier ?? this.tier,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      registrationType: registrationType ?? this.registrationType,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  /// Check if KYC is approved
  bool get isApproved => kycStatus == 'approved';

  /// Check if KYC is pending
  bool get isPending => kycStatus == 'pending';

  /// Check if KYC is rejected
  bool get isRejected => kycStatus == 'rejected';
}
