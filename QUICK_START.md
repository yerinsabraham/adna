# Adna - Quick Start Guide

## Prerequisites

- **Flutter SDK**: Version 3.0 or higher
- **Android Studio** or **VS Code** with Flutter extension
- **Java Development Kit (JDK)**: Version 11 or higher
- **Android SDK**: API level 21 (Android 5.0) or higher
- **Physical device or emulator** for testing

## Installation Steps

### 1. Install Dependencies

```bash
# Navigate to project directory
cd C:\Users\PC\adna

# Get all Flutter dependencies
flutter pub get
```

### 2. Configure Flutter SDK Path

Edit `android/local.properties` and set your Flutter SDK path:
```properties
flutter.sdk=C:\\path\\to\\flutter
```

### 3. Verify Flutter Setup

```bash
# Check Flutter installation
flutter doctor

# Fix any issues reported
flutter doctor -v
```

### 4. Set Up Firebase

Follow the detailed instructions in `FIREBASE_SETUP.md`:
1. Create Firebase project
2. Add Android app with package name: `ng.adna.app`
3. Download and place `google-services.json` in `android/app/`
4. Enable Authentication (Email/Password)
5. Create Firestore database
6. Create Storage bucket

### 5. Run the App

```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release
```

## Project Structure

```
adna/
├── lib/
│   ├── core/               # Core constants, theme, configs
│   │   ├── constants/      # Colors, text styles, app constants
│   │   └── theme/          # App theme configuration
│   ├── data/              # Data layer
│   │   ├── models/        # Data models (Merchant, PaymentRequest, etc.)
│   │   ├── repositories/  # Data repositories
│   │   └── services/      # Firebase & API services
│   ├── presentation/      # UI layer
│   │   ├── providers/     # State management (Provider pattern)
│   │   ├── screens/       # All app screens
│   │   └── widgets/       # Reusable widgets
│   ├── utils/            # Utilities (validators, formatters, helpers)
│   └── main.dart         # App entry point
├── android/              # Android configuration
├── ios/                  # iOS configuration (future)
├── assets/               # Images, icons, etc.
└── test/                 # Unit and widget tests (future)
```

## App Flow

### 1. Authentication Flow
- **Splash Screen** → Checks auth state
- **Login/Register** → Email/password authentication
- **Email Verification** → Auto-checks verification status
- **Onboarding** or **Dashboard** → Based on KYC status

### 2. Onboarding Flow (5 Steps)
1. **Business Information** - Company details, CAC, TIN
2. **Owner Information** - KYC with BVN, DOB, address
3. **Bank Account** - Settlement account with verification
4. **Documents Upload** - CAC cert, utility bill, government ID
5. **Review & Submit** - Review all data before submission

### 3. Main App Flow
- **Dashboard** → View stats and recent transactions
- **Create Payment** → Generate crypto payment request with QR code
- **Transactions** → View all payment history
- **Settings** → Profile, change password, sign out

## Default Test Data

The app uses **mock data** for development (no real API credentials needed):

### Mock Exchange Rates (MockPartnerApiService)
- Bitcoin (BTC): ₦120,000,000 per BTC
- Tether (USDT): ₦1,600 per USDT
- USD Coin (USDC): ₦1,600 per USDC

### Mock Wallet Addresses
- BTC: `bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh`
- USDT (TRC20): `TN3W4H6rK2ce4vX9YnFxx6HjzuSXfGLjnr`
- USDC (ERC20): `0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb`

## Key Features

### ✅ Completed Features
- Email/password authentication with verification
- Multi-step merchant onboarding with KYC
- Dashboard with transaction statistics
- Create crypto payment requests with QR codes
- Real-time payment status monitoring
- Transaction history with filtering
- Profile management and settings
- Change password functionality
- Mock API integration (swappable with real APIs)

### 🔄 Mock Features (Development Mode)
- Document uploads (simulated, not uploaded to storage yet)
- Bank account verification (simulated response)
- Payment status updates (manual simulation)

### ⏳ Future Features
- Real crypto API integration (Quidax)
- Actual document upload to Firebase Storage
- Real bank account verification (Paystack)
- Payment webhooks for automatic status updates
- Push notifications
- Transaction export (PDF/CSV)
- Multi-currency support
- Analytics dashboard
- Admin panel for KYC approval

## Testing the App

### 1. Create Account
```
Email: test@example.com
Password: Test1234
```

### 2. Complete Onboarding
Use any valid-looking data:
- CAC Number: RC1234567
- TIN: 12345678-0001
- BVN: 12345678901
- Phone: 08012345678

### 3. Create Payment
- Amount: ₦10,000
- Crypto: BTC
- System calculates: 0.00008333 BTC
- QR code and wallet address displayed

### 4. View Transactions
- All transactions appear in Transaction List
- Filter by: All, Pending, Completed, Expired

## Development Tips

### Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debug Mode
```bash
# Run with debug logging
flutter run --verbose

# View logs
flutter logs
```

### Clear Cache
```bash
# Clean build files
flutter clean

# Re-get dependencies
flutter pub get

# Rebuild
flutter run
```

### Common Commands
```bash
# Format code
dart format lib/

# Analyze code
flutter analyze

# Run tests (when added)
flutter test

# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle
```

## Troubleshooting

### "Waiting for another flutter command to release the startup lock"
```bash
# Kill lock file
del .flutter-plugins-dependencies
flutter clean
flutter pub get
```

### "SDK location not found"
- Edit `android/local.properties`
- Set `flutter.sdk` path correctly
- Restart IDE

### "Firebase not initialized"
- Verify `google-services.json` is in `android/app/`
- Run `flutter clean` and `flutter pub get`
- Check Firebase setup in `FIREBASE_SETUP.md`

### "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

### App Crashes on Startup
- Check `flutter logs` for error details
- Verify all dependencies are installed: `flutter pub get`
- Check Firebase configuration
- Ensure minSdkVersion is 21 or higher

## Building for Release

### 1. Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

### 2. Build APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### 3. Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### 4. Sign APK (Production)
1. Generate keystore:
```bash
keytool -genkey -v -keystore adna-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias adna
```

2. Create `android/key.properties`:
```properties
storePassword=<your_password>
keyPassword=<your_password>
keyAlias=adna
storeFile=<path_to_keystore>/adna-key.jks
```

3. Update `android/app/build.gradle` with signing config

## Support & Documentation

- **Project Guide**: `PROJECT_GUIDE.md` - Complete development guide
- **AI Instructions**: `AI_INSTRUCTIONS.md` - Agent development guide
- **Firebase Setup**: `FIREBASE_SETUP.md` - Detailed Firebase configuration
- **README**: `README.md` - Project overview

## Next Steps

1. ✅ Run `flutter pub get` to install dependencies
2. ✅ Configure Firebase (see `FIREBASE_SETUP.md`)
3. ✅ Run the app: `flutter run`
4. ⏳ Test authentication flow
5. ⏳ Complete onboarding with test data
6. ⏳ Create test payment and view QR code
7. ⏳ Explore dashboard and transactions
8. ⏳ Update mock services to real APIs when ready

## Quick Test Script

```bash
# Complete setup
flutter pub get
flutter clean

# Run app
flutter run

# In another terminal, view logs
flutter logs
```

Happy coding! 🚀
