# 🔐 Security and Secrets Management

## ⚠️ IMPORTANT: GitHub Secret Alert Resolution

If you received an email about "Valid secrets detected", follow these steps:

### What Happened
The `google-services.json` file contains Firebase API keys and was initially pushed to GitHub. While Firebase API keys are designed to be public (they're included in every mobile app), GitHub flagged them as potential secrets.

### ✅ Resolution Steps

#### 1. Files Now Protected
The following files are now in `.gitignore` and won't be pushed to GitHub:
- `google-services.json` (all locations)
- `.firebaserc`
- `firebase_options.dart`
- `GoogleService-Info.plist` (iOS)

#### 2. Template Files Created
- `android/app/google-services.json.template` - Template for team members

#### 3. What You Should Do

**For the exposed API key:**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `adna-faa82`
3. Go to Project Settings → General
4. Download a fresh `google-services.json` file
5. Replace the current file (it's now protected from being pushed)

**Optional - Regenerate API Key (Recommended):**
1. In Firebase Console → Project Settings → General
2. Scroll to "Web API Key"
3. Click on the key to go to Google Cloud Console
4. Create a new API key and restrict it to your app
5. Delete the old key
6. Download new `google-services.json` with the new key

**For GitHub Secret Alert:**
1. Go to your repository: https://github.com/yerinsabraham/adna
2. Click "Security" tab
3. Click "View alerts" under Secret scanning
4. Review and dismiss the alerts (since we've now protected the files)

### 🛡️ Firebase Security Best Practices

**Important Note:** Firebase API keys in `google-services.json` are safe to be public because:
- They're included in every Android/iOS app
- Firebase security is controlled by **Security Rules**, not API keys
- The API key just identifies your Firebase project

**However, you MUST:**
1. ✅ Set up proper Firestore Security Rules (already done in `firestore.rules`)
2. ✅ Set up proper Storage Security Rules (already done in `storage.rules`)
3. ✅ Restrict API keys in Google Cloud Console to your app's package name
4. ✅ Enable App Check for additional protection (optional)

### 🔒 Current Security Setup

**Firestore Rules (Deployed):**
```
- Merchants: Only authenticated users can read/write their own data
- Payments: Secure validation and access control
- Transactions: User-specific access only
```

**Storage Rules (Deployed):**
```
- Documents: Only authenticated merchants can upload
- Max file size: 5MB
- Restricted to authenticated users only
```

### 📝 For Team Members

If you're setting up this project:

1. **Get Firebase Configuration:**
   - Ask the project owner for `google-services.json`
   - Place it in `android/app/google-services.json`
   - Never commit this file to Git

2. **Or Download from Firebase:**
   - Get access to Firebase project
   - Download from Firebase Console
   - Place in correct location

### 🚀 Repository Configuration

The Git repository is now configured to:
- ✅ Automatically use the correct remote URL
- ✅ Use project-specific credentials (local config)
- ✅ Exclude sensitive files from commits
- ✅ Remember the repository: https://github.com/yerinsabraham/adna.git

### Future Commits

The repository will automatically:
```bash
# Simple workflow - no need to specify remote
git add .
git commit -m "Your message"
git push  # Automatically goes to the configured repository
```

### Additional Security Recommendations

1. **Never commit:**
   - Private keys (`.jks`, `.keystore`)
   - Environment files (`.env`)
   - Any file with "secret", "password", or "key" in the name

2. **Always use:**
   - Environment variables for sensitive data
   - Firebase Security Rules for access control
   - API key restrictions in Google Cloud Console

3. **Regular security checks:**
   - Review GitHub security alerts
   - Update dependencies regularly
   - Rotate keys periodically

---

## 🆘 If You Accidentally Commit Secrets

1. **Immediately rotate/revoke the secret**
2. **Remove from Git history:**
   ```bash
   git filter-branch --force --index-filter \
   "git rm --cached --ignore-unmatch path/to/file" \
   --prune-empty --tag-name-filter cat -- --all
   
   git push --force --all
   ```
3. **Add to `.gitignore`**
4. **Inform your team**

---

**Need Help?** 
- Firebase Security: https://firebase.google.com/docs/rules
- GitHub Secret Scanning: https://docs.github.com/en/code-security/secret-scanning
