# Adna - B2B Crypto Payment Gateway

Accept cryptocurrency payments, receive Nigerian Naira in your bank account.

## Overview

Adna is a mobile payment gateway for Nigerian B2B merchants (car dealers, real estate, luxury goods retailers) to accept cryptocurrency payments (BTC/USDT/USDC) and receive Nigerian Naira in their bank accounts within 30-60 minutes.

## Features

- ✅ **Merchant Registration & KYC** - Complete onboarding with document verification
- ✅ **Multi-Crypto Support** - Accept Bitcoin, USDT, and USDC
- ✅ **QR Code Payments** - Generate payment QR codes for customers
- ✅ **Real-time Status Updates** - Track payment status from crypto to Naira
- ✅ **Transaction History** - View and filter all transactions
- ✅ **Bank Settlement** - Automatic Naira transfer to merchant bank account
- ✅ **Fee Transparency** - Clear fee breakdown for every transaction

## Tech Stack

- **Framework:** Flutter 3.x (Dart)
- **State Management:** Provider
- **Backend:** Firebase (Authentication, Firestore, Storage)
- **UI:** Material Design 3 with Lucide Icons
- **APIs:** Quidax (crypto operations), Paystack (bank transfers)

## Project Structure

```
lib/
├── core/              # Configuration, constants, theme
│   ├── config/
│   ├── constants/
│   └── theme/
├── data/              # Data layer
│   ├── models/
│   ├── repositories/
│   └── services/
├── presentation/      # UI layer
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── utils/            # Utilities
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Android Studio / VS Code
- Firebase account
- Android device/emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yerinsabraham/adna.git
cd adna
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/`

4. Run the app:
```bash
flutter run
```

## Firebase Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Enable the following services:
   - **Authentication** (Email/Password provider)
   - **Cloud Firestore** (Native mode)
   - **Cloud Storage**

3. Set up Firestore security rules (see `PROJECT_GUIDE.md`)

4. Set up Storage security rules (see `PROJECT_GUIDE.md`)

## Architecture

The app follows **Clean Architecture** with separation of concerns:

- **Presentation Layer:** UI components, screens, state management
- **Data Layer:** Models, repositories, external services
- **Core Layer:** Configuration, constants, theme

### Key Design Pattern: API Abstraction

All crypto operations use the `PartnerApiService` interface:
- Development: `MockPartnerApiService` (no real API needed)
- Production: `QuidaxApiService` (real implementation)

This allows development and testing without external API dependencies.

## Development Phases

### Phase 1: Authentication ✅
- Splash screen
- Login/Register
- Email verification

### Phase 2: Onboarding (KYC) ✅
- Business information
- Owner information
- Bank account details
- Document uploads
- Review & submit

### Phase 3: Dashboard & Payments ✅
- Dashboard with stats
- Create payment requests
- QR code generation
- Transaction list
- Transaction details

### Phase 4: Settings ✅
- Profile management
- Change password
- App settings

## Environment Variables

Currently using mock data for development. To connect to real APIs:

1. Create `lib/core/config/env.dart`:
```dart
class Environment {
  static const String quidaxApiKey = 'YOUR_QUIDAX_API_KEY';
  static const String quidaxApiSecret = 'YOUR_QUIDAX_SECRET';
  static const String paystackSecretKey = 'YOUR_PAYSTACK_SECRET';
}
```

2. Swap `MockPartnerApiService` → `QuidaxApiService` in `main.dart`

## Testing

Run tests:
```bash
flutter test
```

## Documentation

- **`PROJECT_GUIDE.md`** - Comprehensive project documentation
- **`AI_INSTRUCTIONS.md`** - AI agent development guide
- **Firebase Project:** adna-faa82

## User Flow

1. **Register** → Verify email
2. **Complete KYC** → Submit business documents
3. **Wait for Approval** → Admin reviews (24-48 hours)
4. **Create Payment** → Enter amount, select crypto
5. **Show QR Code** → Customer scans and pays
6. **Receive Naira** → Money in bank account (30-60 min)

## Transaction Limits

- **Basic Tier:** ₦5M daily, ₦50M monthly
- **Business Tier:** ₦50M daily, ₦500M monthly
- **Enterprise Tier:** ₦500M daily, ₦5B monthly

## Fees

- **Adna Fee:** 2.5% (merchant-paid)
- **Partner Fee:** Varies (Quidax/Paystack fees)
- **Net to Merchant:** Gross amount - all fees

## Supported Cryptocurrencies

- **Bitcoin (BTC)**
- **Tether (USDT)** - TRC-20
- **USD Coin (USDC)** - TRC-20

## Security

- Email verification required
- KYC document verification
- Firestore security rules
- Firebase Storage access control
- No direct crypto wallet management (handled by Quidax)

## Support

For issues or questions:
- GitHub Issues: https://github.com/yerinsabraham/adna/issues
- Email: support@adna.ng (when available)

## License

Copyright © 2025 Adna. All rights reserved.

## Contributing

This is a private project. Contributions are not currently accepted.

---

**Built with Flutter** 💙 **for Nigerian Merchants** 🇳🇬
