# Firebase Setup Guide for Adna

## Prerequisites
- Flutter SDK installed
- Android Studio or VS Code with Flutter extension
- Firebase account (free tier is sufficient)

## Firebase Project Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Project name: `Adna` (or your preferred name)
4. Enable Google Analytics (optional)
5. Create project

### 2. Add Android App to Firebase
1. In Firebase Console, click "Add app" → Android
2. Register app with package name: `ng.adna.app`
3. App nickname: `Adna Android`
4. Download `google-services.json`
5. Place the file in `android/app/google-services.json` (already done)

### 3. Add iOS App to Firebase (Future)
1. In Firebase Console, click "Add app" → iOS
2. Register app with bundle ID: `ng.adna.app`
3. App nickname: `Adna iOS`
4. Download `GoogleService-Info.plist`
5. Place the file in `ios/Runner/GoogleService-Info.plist`

## Firebase Services Configuration

### 1. Authentication
1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Email/Password** sign-in method
4. Email link (passwordless sign-in): Keep disabled
5. Save

### 2. Firestore Database
1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Start in **Test mode** (for development)
4. Choose location: `us-central1` or closest to your region
5. Create database

#### Firestore Security Rules (Development)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own merchant data
    match /merchants/{merchantId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Allow authenticated users to read/write their own payment requests
    match /paymentRequests/{requestId} {
      allow read, write: if request.auth != null;
    }
    
    // Allow authenticated users to read/write their own transactions
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Firestore Security Rules (Production)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Merchant collection - users can only access their own data
    match /merchants/{merchantId} {
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && request.auth.uid == resource.data.userId;
      allow delete: if false; // No deletion allowed
    }
    
    // Payment requests - merchants can only access their own
    match /paymentRequests/{requestId} {
      allow read: if request.auth != null && 
                     get(/databases/$(database)/documents/merchants/$(resource.data.merchantId)).data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                       get(/databases/$(database)/documents/merchants/$(resource.data.merchantId)).data.userId == request.auth.uid;
      allow delete: if false;
    }
    
    // Transactions - merchants can only access their own
    match /transactions/{transactionId} {
      allow read: if request.auth != null && 
                     get(/databases/$(database)/documents/merchants/$(resource.data.merchantId)).data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if false; // Transactions are immutable
      allow delete: if false;
    }
  }
}
```

### 3. Storage
1. In Firebase Console, go to **Storage**
2. Click "Get started"
3. Start in **Test mode** (for development)
4. Choose location: Same as Firestore
5. Create bucket

#### Storage Security Rules (Development)
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /kyc_documents/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Storage Security Rules (Production)
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /kyc_documents/{userId}/{allPaths=**} {
      // Only allow authenticated users to upload to their own folder
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                      request.resource.contentType.matches('image/.*'); // Images only
    }
  }
}
```

## Project Configuration Files

All necessary configuration files have been created:

### Android Configuration
✅ `android/app/build.gradle` - Firebase dependencies added
✅ `android/build.gradle` - Google Services plugin added
✅ `android/app/src/main/AndroidManifest.xml` - Permissions configured
✅ `android/app/src/main/kotlin/ng/adna/app/MainActivity.kt` - Main activity
✅ `android/gradle.properties` - Gradle settings
✅ `android/settings.gradle` - Project settings
✅ `android/app/google-services.json` - Firebase config (your actual file)

### iOS Configuration (Future)
✅ `ios/Podfile` - CocoaPods dependencies

## Running the App

### First Time Setup
```bash
# Get Flutter dependencies
flutter pub get

# For Android
cd android
./gradlew clean
cd ..

# Run on Android emulator or device
flutter run
```

### Build Commands
```bash
# Debug build (development)
flutter run

# Release build (production)
flutter build apk --release
flutter build appbundle --release

# Install on device
flutter install
```

## Testing Firebase Connection

### 1. Test Authentication
1. Run the app
2. Try to register a new account
3. Check Firebase Console → Authentication → Users
4. Verify email verification email is sent

### 2. Test Firestore
1. Complete onboarding after registration
2. Check Firebase Console → Firestore Database
3. Verify `merchants` collection has your data

### 3. Test Storage (Future when document upload is implemented)
1. Upload documents during onboarding
2. Check Firebase Console → Storage
3. Verify files are in `kyc_documents/{userId}/` folder

## Environment Variables (Optional)

For multiple environments (dev/staging/prod), create separate Firebase projects:

### Development
- Project: `adna-dev`
- Use `google-services-dev.json`

### Staging
- Project: `adna-staging`
- Use `google-services-staging.json`

### Production
- Project: `adna-prod`
- Use `google-services-prod.json`

## Troubleshooting

### "Default FirebaseApp is not initialized"
- Ensure `google-services.json` is in `android/app/`
- Verify `apply plugin: 'com.google.gms.google-services'` is at the bottom of `android/app/build.gradle`
- Run `flutter clean` and `flutter pub get`

### "FirebaseException: PERMISSION_DENIED"
- Check Firestore/Storage security rules
- Verify user is authenticated
- Check user ID matches document path

### Build Errors
- Update Google Services plugin: `classpath 'com.google.gms:google-services:4.4.0'`
- Update Firebase BOM: `implementation platform('com.google.firebase:firebase-bom:32.7.0')`
- Run `cd android && ./gradlew clean && cd ..`

### Email Not Sending
- Check Firebase Console → Authentication → Templates
- Verify email provider is configured
- Check spam folder

## Next Steps

1. ✅ Firebase project created and configured
2. ✅ Android app registered with Firebase
3. ✅ Authentication enabled (Email/Password)
4. ✅ Firestore database created with security rules
5. ✅ Storage bucket created with security rules
6. ⏳ Test app with Firebase (run `flutter run`)
7. ⏳ Configure production security rules before launch
8. ⏳ Set up Firebase Cloud Functions for payment webhooks (future)
9. ⏳ Configure Firebase Analytics for metrics (optional)
10. ⏳ Set up Crashlytics for error tracking (optional)

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules to production version
- [ ] Update Storage security rules to production version
- [ ] Enable App Check for additional security
- [ ] Set up email templates in Firebase Console
- [ ] Configure password policies
- [ ] Set up backup strategy for Firestore
- [ ] Configure billing alerts
- [ ] Enable Firebase Performance Monitoring
- [ ] Set up proper error tracking
- [ ] Test all authentication flows
- [ ] Test data persistence and retrieval
- [ ] Verify file uploads work correctly
- [ ] Test on multiple devices and Android versions

## Support

For issues:
- Check [FlutterFire documentation](https://firebase.flutter.dev/)
- Review [Firebase Console](https://console.firebase.google.com/)
- Check app logs: `flutter logs`
