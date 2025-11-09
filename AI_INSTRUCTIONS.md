# AI Agent Instructions for Adna Development

## Context

You are building **Adna**, a Flutter mobile app (Android) that enables Nigerian B2B merchants to accept cryptocurrency payments and receive Naira in their bank accounts. This is a payment gateway, NOT a crypto wallet or trading platform.

**Firebase Project:** adna-faa82  
**Primary Color:** #0f4e9d  
**State Management:** Provider  
**Target Users:** Car dealers, real estate agents, luxury goods retailers

## Core Principles

### 1. API Abstraction Pattern
**CRITICAL:** All crypto operations MUST go through `PartnerApiService` interface.

```dart
// ✅ CORRECT
abstract class PartnerApiService {
  Future<double> getCryptoPrice(String cryptoType);
  Future<String> generatePaymentAddress(String cryptoType, double amount);
  Future<Map<String, dynamic>> getTransactionStatus(String txId);
}

// Use MockPartnerApiService for development
// Swap to QuidaxApiService later (NO changes to app code needed)
```

**Why:** Enables development without real API, easy testing, seamless API swap later.

### 2. Clean Architecture Structure
```
lib/
├── core/          # Config, constants, theme (NO business logic)
├── data/          # Models, repositories, services (DATA layer)
├── presentation/  # Screens, widgets, providers (UI layer)
└── utils/         # Pure functions (formatters, validators, helpers)
```

**Rules:**
- Screens call Providers
- Providers call Repositories
- Repositories call Services
- Services call Firebase/APIs
- NO direct Firebase calls from screens

### 3. State Management with Provider
```dart
// Provider pattern
class MyProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> doSomething() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Do work
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => MerchantProvider()),
    ChangeNotifierProvider(create: (_) => PaymentProvider()),
  ],
  child: AdnaApp(),
)
```

## Development Workflow

### Phase 1: Authentication (Days 1-2)
**Files to Create:**
```
presentation/screens/auth/
  ├── splash_screen.dart
  ├── login_screen.dart
  ├── register_screen.dart
  └── email_verification_screen.dart

presentation/providers/
  └── auth_provider.dart

data/services/
  └── auth_service.dart
```

**Key Logic:**
1. **SplashScreen:** Check auth state → Route to correct screen
2. **Email verification REQUIRED** before any app access
3. **Error handling:** Display user-friendly messages for Firebase errors

**Navigation from Splash:**
```dart
if (user == null) → LoginScreen
else if (!user.emailVerified) → EmailVerificationScreen
else if (merchant == null) → Onboarding
else if (merchant.kycStatus == 'pending') → PendingApprovalScreen
else if (merchant.kycStatus == 'approved') → DashboardScreen
```

### Phase 2: Onboarding (Days 3-5)
**Files to Create:**
```
presentation/screens/onboarding/
  ├── onboarding_wrapper.dart       # Step container
  ├── business_info_screen.dart     # Step 1/5
  ├── owner_info_screen.dart        # Step 2/5
  ├── bank_account_screen.dart      # Step 3/5
  ├── documents_upload_screen.dart  # Step 4/5
  ├── review_submit_screen.dart     # Step 5/5
  └── pending_approval_screen.dart

presentation/providers/
  └── merchant_provider.dart

data/models/
  └── merchant.dart

data/repositories/
  └── merchant_repository.dart

data/services/
  └── storage_service.dart
```

**Key Requirements:**
1. **Multi-step form** with progress indicator (1 of 5, 2 of 5, etc.)
2. **Validation on each step** before allowing "Next"
3. **Document upload** to Firebase Storage: `kyc/{userId}/{docType}_{timestamp}.ext`
4. **Final submission** creates Firestore document in `merchants` collection
5. **Default values:** `kycStatus: 'pending'`, `tier: 'basic'`, `dailyLimit: 5000000`

**Document Types Required:**
- CAC Certificate (required)
- Government ID Front (required)
- Government ID Back (optional)
- Proof of Address (required)
- Bank Statement (optional)

**Validation Rules:**
- CAC Number: Format `RC123456` or `RC1234567`
- BVN/NIN: Exactly 11 digits
- Account Number: Exactly 10 digits
- Phone: Nigerian format (start with +234 or 0)
- File size: Max 5MB

### Phase 3: Dashboard & Payments (Days 6-8)
**Files to Create:**
```
presentation/screens/dashboard/
  ├── dashboard_screen.dart
  └── widgets/
      ├── stats_card.dart
      ├── recent_transactions_list.dart
      └── quick_action_button.dart

presentation/screens/payments/
  ├── create_payment_screen.dart
  ├── payment_display_screen.dart
  └── payment_link_screen.dart

presentation/screens/transactions/
  ├── transactions_list_screen.dart
  └── transaction_detail_screen.dart

presentation/providers/
  └── payment_provider.dart

data/models/
  ├── payment_request.dart
  └── transaction.dart

data/repositories/
  └── payment_repository.dart

data/services/
  ├── partner_api_service.dart      # Abstract interface
  └── mock_partner_api_service.dart # Mock implementation
```

**Mock API Implementation:**
```dart
class MockPartnerApiService implements PartnerApiService {
  @override
  Future<double> getCryptoPrice(String cryptoType) async {
    await Future.delayed(Duration(seconds: 1));
    switch (cryptoType) {
      case 'BTC': return 120000000.0; // ₦120M per BTC
      case 'USDT': return 1600.0;
      case 'USDC': return 1600.0;
      default: throw Exception('Unsupported');
    }
  }
  
  @override
  Future<String> generatePaymentAddress(String type, double amount) async {
    await Future.delayed(Duration(seconds: 1));
    return type == 'BTC' 
      ? 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh'
      : 'TXYZeZKtHkBJRUMsFKyKqNn6uyedMJ7J7Z';
  }
}
```

**Payment Flow Logic:**
1. **CreatePaymentScreen:** 
   - Input: Amount (₦), Crypto Type, Description, Customer Name
   - Validation: Amount ≥ ₦100,000, ≤ merchant daily limit
   - Calculate crypto amount in real-time using `getCryptoPrice()`
   - On submit: Generate address, create PaymentRequest in Firestore

2. **PaymentDisplayScreen:**
   - Display QR code (from payment address + amount)
   - Show payment details (amount, address, countdown timer)
   - Real-time status updates via Firestore listener
   - Status flow: pending → awaiting_confirmation → confirmed → converting → settling → completed

3. **TransactionsList:**
   - Query: `firestore.collection('transactions').where('merchantId', '==', userId).orderBy('createdAt', descending: true)`
   - Filters: Status dropdown, Date range
   - Search: By customer name or transaction ID

**Dashboard Stats (Use Mock Data):**
- Total Transactions: 47
- Total Volume: ₦685,000,000
- Pending Payments: 3
- This Week Volume: ₦125,000,000

**Mock Transactions:**
Create 10-15 mock transactions with varied statuses, amounts, dates for testing UI.

### Phase 4: Settings & Polish (Days 9-10)
**Files to Create:**
```
presentation/screens/settings/
  ├── settings_screen.dart
  ├── profile_screen.dart
  └── change_password_screen.dart

utils/
  ├── validators.dart
  ├── formatters.dart
  └── helpers.dart
```

**Settings Menu:**
- View Profile (read-only for approved merchants)
- Change Password (Firebase Auth)
- Notification Preferences
- Terms & Conditions (link)
- Privacy Policy (link)
- Logout

## Code Patterns to Follow

### 1. Error Handling
```dart
try {
  await operation();
} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    return 'No account found';
  } else if (e.code == 'wrong-password') {
    return 'Incorrect password';
  }
  return e.message ?? 'Authentication error';
} on FirebaseException catch (e) {
  return 'Database error: ${e.message}';
} catch (e) {
  return 'Unexpected error: $e';
}
```

### 2. Loading States
```dart
// In Provider
bool _isLoading = false;
bool get isLoading => _isLoading;

// In Screen
if (provider.isLoading) return LoadingIndicator();

// Always use try/finally
try {
  _isLoading = true;
  notifyListeners();
  await operation();
} finally {
  _isLoading = false;
  notifyListeners();
}
```

### 3. Real-time Firestore Updates
```dart
StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
    .collection('paymentRequests')
    .doc(requestId)
    .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingIndicator();
    }
    if (snapshot.hasError) {
      return ErrorMessage(snapshot.error.toString());
    }
    if (!snapshot.hasData) {
      return ErrorMessage('Payment request not found');
    }
    
    final request = PaymentRequest.fromMap(snapshot.data!.data()!);
    return PaymentStatusWidget(request);
  },
)
```

### 4. Naira Formatting
```dart
import 'package:intl/intl.dart';

String formatNaira(double amount) {
  return NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 2,
  ).format(amount);
}

// Usage: formatNaira(15000000) → "₦15,000,000.00"
```

### 5. Form Validation
```dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email required';
    if (!value.contains('@')) return 'Invalid email format';
    return null;
  }
  
  static String? nigerianPhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone required';
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (!cleaned.startsWith('234') && !cleaned.startsWith('0')) {
      return 'Must start with +234 or 0';
    }
    if (cleaned.length < 11) return 'Invalid phone number';
    return null;
  }
  
  static String? bvnOrNin(String? value) {
    if (value == null || value.isEmpty) return 'BVN/NIN required';
    if (value.length != 11) return 'Must be exactly 11 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'Must contain only digits';
    return null;
  }
  
  static String? accountNumber(String? value) {
    if (value == null || value.isEmpty) return 'Account number required';
    if (value.length != 10) return 'Must be exactly 10 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'Must contain only digits';
    return null;
  }
  
  static String? cacNumber(String? value) {
    if (value == null || value.isEmpty) return 'CAC number required';
    if (!RegExp(r'^RC\d{6,7}$').hasMatch(value)) {
      return 'Format: RC123456 or RC1234567';
    }
    return null;
  }
}
```

### 6. Data Model Pattern
```dart
class MyModel {
  final String id;
  final String field1;
  final DateTime createdAt;
  
  MyModel({
    required this.id,
    required this.field1,
    required this.createdAt,
  });
  
  // Firestore → Dart
  factory MyModel.fromMap(Map<String, dynamic> map) {
    return MyModel(
      id: map['id'] ?? '',
      field1: map['field1'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
  
  // Dart → Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'field1': field1,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  // For updating existing documents (exclude auto-generated fields)
  Map<String, dynamic> toUpdateMap() {
    return {
      'field1': field1,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
```

## UI Component Guidelines

### CustomButton
```dart
CustomButton(
  text: 'Login',
  onPressed: () {},
  isLoading: false,
  variant: ButtonVariant.primary, // primary, secondary, text
  fullWidth: true,
)
```

### CustomTextField
```dart
CustomTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  validator: Validators.email,
  prefixIcon: Icons.email,
  obscureText: false,
)
```

### Status Badges
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: _getStatusColor(status),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    status.toUpperCase(),
    style: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  ),
)

Color _getStatusColor(String status) {
  switch (status) {
    case 'pending': return Color(0xFFFBBC04);
    case 'confirmed': return Color(0xFF1a73e8);
    case 'completed': return Color(0xFF34A853);
    case 'failed': return Color(0xFFEA4335);
    case 'expired': return Colors.grey;
    default: return Colors.grey;
  }
}
```

## Firebase Configuration

### main.dart Setup
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Use mock API for development
  final partnerApi = MockPartnerApiService();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<PartnerApiService>.value(value: partnerApi),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MerchantProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider(partnerApi)),
      ],
      child: AdnaApp(),
    ),
  );
}
```

### Firestore Security Rules (Set in Firebase Console)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /merchants/{merchantId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    match /paymentRequests/{requestId} {
      allow read: if true; // Public read for customer payment
      allow write: if request.auth != null && 
        resource.data.merchantId == request.auth.uid;
      allow create: if request.auth != null;
    }
    
    match /transactions/{transactionId} {
      allow read: if request.auth != null && 
        resource.data.merchantId == request.auth.uid;
      allow write: if false; // Only backend writes
    }
  }
}
```

## Testing Checklist

Before marking each phase complete:

**Phase 1 - Auth:**
- [ ] Register new account
- [ ] Receive verification email
- [ ] Login fails if email not verified
- [ ] Login succeeds after verification
- [ ] Forgot password sends reset email
- [ ] Error messages display correctly

**Phase 2 - Onboarding:**
- [ ] All 5 steps validate input
- [ ] Can navigate back/forward
- [ ] Documents upload to Firebase Storage
- [ ] Merchant document created in Firestore
- [ ] Pending approval screen displays

**Phase 3 - Dashboard/Payments:**
- [ ] Dashboard displays mock stats
- [ ] Recent transactions list shows
- [ ] Create payment calculates crypto amount
- [ ] QR code generates correctly
- [ ] Payment address displays (from mock API)
- [ ] Transaction list filters work
- [ ] Transaction detail shows all info

**Phase 4 - Settings:**
- [ ] Profile displays merchant data
- [ ] Change password works
- [ ] Logout returns to login screen

## Common Pitfalls to Avoid

1. **❌ Direct API calls from screens**
   - ✅ Always go through Provider → Repository → Service

2. **❌ Hardcoding crypto prices**
   - ✅ Always call `partnerApi.getCryptoPrice()` even with mock

3. **❌ Not handling loading states**
   - ✅ Every async operation needs loading indicator

4. **❌ Generic error messages**
   - ✅ User-friendly, specific error messages

5. **❌ Not validating forms**
   - ✅ Inline validation on all input fields

6. **❌ Ignoring email verification**
   - ✅ Block app access until email verified

7. **❌ Missing null checks**
   - ✅ Check for null before accessing Firestore data

8. **❌ Not using real-time listeners for payment status**
   - ✅ Use StreamBuilder for PaymentDisplayScreen

9. **❌ Forgetting to format Naira amounts**
   - ✅ Always use `formatNaira()` helper

10. **❌ Not setting default values in Firestore**
    - ✅ Set `kycStatus`, `tier`, limits on merchant creation

## Required Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  
  # State Management
  provider: ^6.1.1
  
  # UI
  lucide_icons: ^0.263.0
  qr_flutter: ^4.1.0
  image_picker: ^1.0.5
  file_picker: ^6.1.1
  
  # Utilities
  intl: ^0.18.1
  shared_preferences: ^2.2.2
  url_launcher: ^6.2.2
```

## Nigerian-Specific Data

### Banks List (for dropdown)
```dart
const nigerianBanks = [
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
```

### Nigerian States (for dropdown)
```dart
const nigerianStates = [
  'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa',
  'Benue', 'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo',
  'Ekiti', 'Enugu', 'FCT', 'Gombe', 'Imo', 'Jigawa', 'Kaduna',
  'Kano', 'Katsina', 'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa',
  'Niger', 'Ogun', 'Ondo', 'Osun', 'Oyo', 'Plateau', 'Rivers',
  'Sokoto', 'Taraba', 'Yobe', 'Zamfara',
];
```

### Business Categories
```dart
const businessCategories = [
  'Automotive',
  'Real Estate',
  'Luxury Goods',
  'Electronics',
  'Wholesale/Import',
  'Other',
];
```

## Success Criteria

The MVP is complete when:
1. ✅ Merchant can register and verify email
2. ✅ Merchant can complete 5-step KYC onboarding
3. ✅ Documents upload to Firebase Storage successfully
4. ✅ Merchant document created in Firestore with correct schema
5. ✅ Dashboard displays with mock data
6. ✅ Merchant can create payment request
7. ✅ QR code generates and displays
8. ✅ Payment address retrieved from mock API
9. ✅ Transaction list displays with filters
10. ✅ Transaction detail shows complete info
11. ✅ Settings/profile screens functional
12. ✅ All screens follow design system (colors, spacing, typography)
13. ✅ Error handling and loading states everywhere
14. ✅ Can test entire flow end-to-end without crashes

## Next Steps After MVP

1. Swap `MockPartnerApiService` → `QuidaxApiService`
2. Integrate real Quidax API (payment generation, status monitoring)
3. Add Firebase Cloud Functions for webhook handling
4. Implement Paystack bank transfer integration
5. Add push notifications for payment status updates
6. Implement admin panel for KYC approval
7. Add analytics and monitoring

---

**Remember:** Build incrementally, test frequently, use mock data, follow the patterns. The architecture is designed for easy API swap later.
