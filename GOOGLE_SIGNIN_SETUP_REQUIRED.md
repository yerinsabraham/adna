# Google Sign-In Setup Required

## Current Status

Google Sign-In is **configured in the app** but requires Firebase Console setup to work.

### The Warning You're Seeing

```
Error getting App Check token; using placeholder token instead.
Error: com.google.firebase.FirebaseException: No AppCheckProvider installed.
```

**This is NOT critical** - App Check is an optional security feature. Your app will work without it.

### Why Google Sign-In Isn't Working

Google Sign-In requires SHA-1 and SHA-256 fingerprints to be added to Firebase.

## Quick Setup (5 minutes)

### Step 1: Get Your SHA-1 Fingerprint

Open PowerShell and run:

```powershell
cd "C:\Program Files\Android\Android Studio\jbr\bin"
.\keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Copy both:**
- SHA1: (a long string like `D7:A3:84:45:18:D5:7E:37...`)
- SHA256: (another long string)

### Step 2: Add to Firebase

1. Go to: https://console.firebase.google.com/project/adna-faa82/settings/general
2. Scroll to **Your apps** → **Android app (com.adna.labs)**
3. Click **"Add fingerprint"**
4. Paste your **SHA-1**
5. Click **Save**
6. Click **"Add fingerprint"** again
7. Paste your **SHA-256**
8. Click **Save**

### Step 3: Download Updated google-services.json

1. On the same page, click **"Download google-services.json"**
2. Replace the file at: `android\app\google-services.json`

### Step 4: Rebuild App

```bash
flutter clean
flutter pub get
flutter run
```

### Step 5: Enable Google Sign-In Provider

1. Go to: https://console.firebase.google.com/project/adna-faa82/authentication/providers
2. Click on **Google**
3. Toggle **Enable** to ON
4. Enter your **Support email** (your email address)
5. Click **Save**

## After Setup

Once you complete these steps, the "Sign in with Google" button will work properly!

---

**Note**: For now, you can use **Email/Password sign-in** which works immediately without additional setup.
