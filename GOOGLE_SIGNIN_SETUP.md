# Google Sign-In Setup for Adna

## Firebase Console Configuration

To enable Google Sign-In in your Adna app, follow these steps:

### 1. Enable Google Sign-In in Firebase Console

1. Go to your [Firebase Console](https://console.firebase.google.com/)
2. Select your **Adna** project
3. In the left sidebar, click **Authentication**
4. Click on the **Sign-in method** tab
5. In the list of providers, find **Google** and click on it
6. Toggle **Enable** to ON
7. Enter your **Support email** (required)
8. Click **Save**

### 2. Get SHA-1 and SHA-256 Fingerprints

You need to add your app's SHA certificates to Firebase for Google Sign-In to work on Android.

#### For Debug Build (Development):

Open PowerShell and run:

```powershell
cd C:\Program Files\Android\Android Studio\jbr\bin
.\keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

#### For Release Build (Production):

```powershell
cd C:\Program Files\Android\Android Studio\jbr\bin
.\keytool -list -v -keystore "PATH_TO_YOUR_RELEASE_KEYSTORE" -alias YOUR_KEY_ALIAS
```

**Copy the SHA-1 and SHA-256 fingerprints from the output.**

### 3. Add SHA Fingerprints to Firebase

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Find your Android app (`com.adna.labs`)
4. Click **Add fingerprint**
5. Paste your **SHA-1** fingerprint
6. Click **Save**
7. Repeat for **SHA-256** fingerprint

### 4. Download Updated google-services.json

After adding the SHA fingerprints:

1. In the same **Project Settings** page
2. Click **Download google-services.json** button
3. Replace the existing file at `android/app/google-services.json`

### 5. Test Google Sign-In

1. Stop any running app instances
2. Rebuild the app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. On the Login or Register screen, tap **"Sign in with Google"**
4. Select your Google account
5. You should be signed in successfully

## Troubleshooting

### "Sign in failed" Error

- **Check SHA fingerprints**: Make sure you added the correct SHA-1 and SHA-256
- **Download new google-services.json**: After adding fingerprints, download the updated file
- **Rebuild**: Run `flutter clean` then `flutter run`

### "Error 10" or API not enabled

- Make sure you **enabled Google Sign-In** in Firebase Console Authentication settings
- Check that you entered a **Support email** in the Google provider settings

### Account already exists with different credentials

- This happens if you already registered with email/password and try to sign in with Google using the same email
- Firebase treats these as separate accounts by default
- Solution: Sign out and use the same method you registered with

## Testing Checklist

- [ ] Google Sign-In enabled in Firebase Console
- [ ] Support email configured
- [ ] SHA-1 fingerprint added to Firebase
- [ ] SHA-256 fingerprint added to Firebase
- [ ] Updated google-services.json downloaded and placed in `android/app/`
- [ ] App rebuilt with `flutter clean` and `flutter run`
- [ ] Tested sign-in on physical device or emulator
- [ ] Tested sign-out and sign-in again

## Notes

- **Email verification**: Google accounts are pre-verified, so users skip the email verification step
- **Account linking**: Email/password accounts and Google accounts are separate unless you implement account linking
- **iOS setup**: For iOS support later, you'll need to configure Google Sign-In in Xcode and update your iOS Firebase configuration

## Next Steps

After setting up Google Sign-In:
1. Test both email/password and Google sign-in flows
2. Test user navigation to onboarding (for new users) and dashboard (for existing users)
3. Ensure Firebase Firestore creates merchant records correctly for Google sign-in users
