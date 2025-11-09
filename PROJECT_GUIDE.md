# ADNA - Complete Project Guide

## Quick Reference

**Project Name:** Adna (Merchant B2B Crypto Payment Gateway)  
**Platform:** Flutter (Android)  
**Firebase Project:** adna-faa82  
**Primary Color:** #0f4e9d  
**Repository:** github.com/yerinsabraham/adna

## What is Adna?

Adna enables Nigerian B2B merchants (car dealers, real estate, luxury goods) to accept cryptocurrency payments (BTC/USDT/USDC) and receive Nigerian Naira in their bank accounts within 30-60 minutes.

### Payment Flow
1. Merchant creates payment request (amount in ₦)
2. System generates QR code with crypto payment address
3. Customer scans QR, pays with crypto wallet
4. Quidax converts crypto → Naira
5. Paystack transfers Naira to merchant bank account
6. Complete in ~30-60 minutes

## Technical Stack

- **Framework:** Flutter 3.x (Dart)
- **State Management:** Provider
- **UI:** Material Design 3 + Lucide Icons
- **Backend:** Firebase (Auth, Firestore, Storage)
- **External APIs:** Quidax (crypto), Paystack (bank transfers)

## Architecture Overview

```
Clean Architecture with Service Abstraction

lib/
├── main.dart
├── core/               # Configuration & Theme
├── data/               # Models, Repositories, Services
│   ├── models/
│   ├── repositories/
│   └── services/
├── presentation/       # UI Layer
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── utils/             # Helpers & Validators
```

### Key Architectural Principle: API Abstraction

All crypto operations use `PartnerApiService` interface:
- Development: `MockPartnerApiService` (no real API needed)
- Production: `QuidaxApiService` (real API implementation)
- App code never calls Quidax directly

## Data Models

### 1. Merchant (Collection: `merchants`)
```dart
{
  id, userId, email,
  businessName, cacNumber, tin, category,
  businessAddress, businessPhone, businessEmail,
  ownerName, bvnOrNin, dateOfBirth,
  residentialAddress, ownerPhone, idType,
  bankName, accountNumber, accountName, accountType,
  kycStatus ('pending' | 'approved' | 'rejected'),
  documents[], createdAt, updatedAt,
  tier, dailyLimit, monthlyLimit
}
```

### 2. PaymentRequest (Collection: `paymentRequests`)
```dart
{
  id, merchantId,
  amountNGN, cryptoAmount, cryptoType,
  exchangeRate, paymentAddress, paymentLink, qrCodeData,
  description, customerName,
  status ('pending' | 'awaiting_confirmation' | 'confirmed' | 
         'converting' | 'settling' | 'completed' | 'failed' | 'expired'),
  statusTimeline, feeBreakdown, settlementDetails,
  createdAt, expiresAt, completedAt
}
```

### 3. Transaction (Collection: `transactions`)
Same schema as PaymentRequest, created when status = 'completed'

## User Flows

### Authentication Flow
```
Splash → Check Auth State
  ├─ Not Logged In → Login/Register
  ├─ Email Not Verified → Email Verification
  ├─ No Merchant Doc → Onboarding
  ├─ KYC Pending → Pending Approval
  └─ KYC Approved → Dashboard
```

### Onboarding Flow (5 Steps)
1. **Business Info:** Name, CAC, TIN, Category, Address, Phone
2. **Owner Info:** Name, BVN/NIN, DOB, Residential Address, ID Type
3. **Bank Account:** Bank, Account Number, Account Name, Type
4. **Documents Upload:** CAC cert, ID (front/back), Address proof
5. **Review & Submit:** Confirm all info, submit for approval

### Payment Flow
```
Dashboard → Create Payment
  → Enter Amount (₦) + Select Crypto
  → Generate QR Code + Payment Address
  → Customer Pays
  → Status Updates (Real-time via Firestore)
  → Completed → Naira in Bank Account
```

## Screen Specifications

### Phase 1: Authentication (4 screens)
- **SplashScreen:** Logo + Auth state check
- **LoginScreen:** Email/Password + Forgot Password
- **RegisterScreen:** Email/Password/Confirm + Terms
- **EmailVerificationScreen:** Verify email prompt

### Phase 2: Onboarding (7 screens)
- **OnboardingWrapper:** Step container with progress indicator
- **BusinessInfoScreen:** Step 1 of 5
- **OwnerInfoScreen:** Step 2 of 5
- **BankAccountScreen:** Step 3 of 5
- **DocumentsUploadScreen:** Step 4 of 5 (Firebase Storage)
- **ReviewSubmitScreen:** Step 5 of 5 + Create Firestore doc
- **PendingApprovalScreen:** Wait for admin approval

### Phase 3: Dashboard & Payments (5 screens)
- **DashboardScreen:** Stats cards + Recent transactions + FAB
- **CreatePaymentScreen:** Amount input + Crypto selector
- **PaymentDisplayScreen:** QR code + Payment details + Status
- **TransactionsListScreen:** List with filters + Search
- **TransactionDetailScreen:** Full transaction info + Timeline

### Phase 4: Settings (3 screens)
- **SettingsScreen:** Menu with logout
- **ProfileScreen:** Display merchant info
- **ChangePasswordScreen:** Update password

## UI Design System

### Colors
```dart
Primary: #0f4e9d (Adna Blue)
Secondary: #1a73e8
Success: #34A853
Warning: #FBBC04
Error: #EA4335
Background: #FFFFFF
Surface: #F5F5F5
Text Primary: #202124
Text Secondary: #5F6368
```

### Typography
- **Headings:** Inter Bold
- **Body:** Inter Regular
- **Monospace:** Roboto Mono (addresses, IDs)

### Components
- **Buttons:** 48px height, 16px border radius
- **Cards:** 8px border radius, subtle shadow
- **Spacing:** 8px grid (8, 16, 24, 32, 40px)
- **Status Badges:** Color-coded (pending=orange, completed=green, etc.)

## Firebase Configuration

### Project Setup
- **Project ID:** adna-faa82
- **Region:** us-central1
- **Services:** Auth (Email/Password), Firestore, Storage

### Firestore Security Rules
```javascript
// Merchants can read/write their own documents
// PaymentRequests readable by public (for customer payment page)
// Transactions read-only for merchants, write-only by backend
```

### Storage Rules
```javascript
// KYC documents at kyc/{userId}/{document}
// User can read/write their own documents only
```

## Development Strategy

### Build Phases (10 Days)
1. **Days 1-2:** Authentication flow
2. **Days 3-5:** Onboarding (KYC)
3. **Days 6-8:** Dashboard + Payments (with mock API)
4. **Days 9-10:** Settings + Polish

### Testing Approach
- Use `MockPartnerApiService` for all crypto operations
- Create 10-15 mock transactions for UI testing
- Test complete user journey: Register → Onboard → Create Payment → View Transactions
- Verify Firestore documents created correctly
- Test document uploads to Firebase Storage

### Key Implementation Patterns

**Error Handling:**
```dart
try {
  await operation();
} on FirebaseAuthException catch (e) {
  // Handle specific errors
} catch (e) {
  // Generic error handling
}
```

**Loading States:**
```dart
bool _isLoading = false;
// Set true before async, false in finally block
// Show LoadingIndicator widget when true
```

**Real-time Updates:**
```dart
StreamBuilder<DocumentSnapshot>(
  stream: firestore.collection('paymentRequests').doc(id).snapshots(),
  builder: (context, snapshot) {
    // Update UI based on document changes
  },
)
```

**Naira Formatting:**
```dart
NumberFormat.currency(
  locale: 'en_NG',
  symbol: '₦',
  decimalDigits: 2,
).format(amount);
// Result: ₦15,000,000.00
```

## Critical Implementation Notes

1. **Email Verification Required:** Users must verify email before proceeding
2. **KYC Status Flow:** pending → approved/rejected (affects navigation)
3. **Payment Expiry:** 30 minutes from creation
4. **Transaction Limits:** Based on merchant tier (basic/business/enterprise)
5. **Fee Structure:** 2.5% Adna fee + partner fee
6. **Document Upload:** Max 5MB, PDF/JPG/PNG only
7. **Nigerian Banks:** Provide dropdown list of major banks
8. **Phone Format:** Nigerian (+234 or 0...)
9. **BVN/NIN:** Exactly 11 digits
10. **Account Number:** Exactly 10 digits

## Asset Requirements

Located in: `C:\Users\PC\adna\assets\icons\`
- adna_logo.png (app logo)
- bitcoin_logo.png
- usdt_logo.png
- usdc_logo.png

## Future Enhancements (Post-MVP)

- [ ] Swap MockPartnerApiService → QuidaxApiService
- [ ] Integrate Paystack Account Verification API
- [ ] Add Firebase Cloud Functions for webhooks
- [ ] Implement push notifications
- [ ] Add transaction export (CSV/PDF)
- [ ] Receipt generation
- [ ] Third-party KYC integration
- [ ] iOS version
- [ ] Multi-currency support
- [ ] Analytics dashboard

## Target Metrics

- **Average Transaction:** ₦15,000,000
- **Transaction Fee:** 2.5% (merchant-paid)
- **Settlement Time:** 30-60 minutes
- **Year 1 Volume Target:** ₦1.5B-3B
- **KYC Approval Time:** 24-48 hours

## Support Contacts

- **Repository:** github.com/yerinsabraham/adna
- **Firebase Project:** adna-faa82
- **Target Market:** Nigerian B2B merchants
- **Primary Use Cases:** Automotive, Real Estate, Luxury Goods

---

**Last Updated:** November 8, 2025  
**Version:** 1.0 (MVP Specification)
