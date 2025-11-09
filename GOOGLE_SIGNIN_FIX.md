# Google Sign-In Setup - REQUIRED

## Current Issue

Google Sign-In is failing with error: `type 'List<Object?>' is not a subtype of type 'PigeonUserDetails'`

This happens because **Google Sign-In requires SHA-1 fingerprint configuration in Firebase Console**.

## Fix: Add SHA-1 Fingerprint to Firebase

### Step 1: Get Your SHA-1 Fingerprint

Open PowerShell and run:

```powershell
cd "C:\Program Files\Android\Android Studio\jbr\bin"
.\keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Look for these lines in the output:**
```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

**Copy both SHA-1 and SHA-256 values.**

### Step 2: Add Fingerprints to Firebase Console

1. Go to: https://console.firebase.google.com/project/adna-faa82/settings/general

2. Scroll down to **"Your apps"** section

3. Find your Android app: **com.adna.labs**

4. Click **"Add fingerprint"**

5. Paste your **SHA-1** fingerprint

6. Click **"Save"**

7. Click **"Add fingerprint"** again

8. Paste your **SHA-256** fingerprint

9. Click **"Save"**

### Step 3: Download Updated google-services.json

1. Still in Firebase Console, on the same page

2. Click the **download icon** or **"Download google-services.json"** button

3. Replace the existing file at:
   ```
   C:\Users\PC\adna\android\app\google-services.json
   ```

### Step 4: Rebuild the App

```bash
flutter clean
flutter pub get
flutter run
```

## Why This Is Required

Google Sign-In on Android uses:
- Your app's package name: `com.adna.labs`
- Your app's SHA-1 fingerprint: **Must be registered in Firebase**

Without the SHA-1 fingerprint, Firebase cannot verify your app and Google Sign-In will fail.

## Alternative: Disable Google Sign-In Temporarily

If you want to test the app without Google Sign-In for now, you can:

1. Remove the Google Sign-In buttons from Login and Register screens
2. Test with email/password authentication only
3. Add Google Sign-In back later after SHA-1 configuration

## Testing After Configuration

Once you've added the SHA-1 fingerprint:

1. Rebuild the app: `flutter clean && flutter run`
2. Tap "Sign in with Google"
3. You should see Google account picker
4. Select your account
5. Sign in should succeed

## Troubleshooting

### Still Getting Errors?

1. **Wait 5-10 minutes** after adding SHA-1 (Firebase needs time to propagate changes)
2. **Uninstall the app** from your phone and reinstall
3. **Clear app data**: Settings → Apps → Adna → Storage → Clear Data
4. Run `flutter clean` and rebuild

### How to Check If SHA-1 Is Added

1. Go to Firebase Console → Project Settings
2. Scroll to "Your apps" section
3. Under your Android app, you should see "SHA certificate fingerprints"
4. Your SHA-1 and SHA-256 should be listed there

---

**Without SHA-1 configuration, Google Sign-In WILL NOT WORK on Android.**

This is a Firebase security requirement to ensure only your app can use Google Sign-In.
