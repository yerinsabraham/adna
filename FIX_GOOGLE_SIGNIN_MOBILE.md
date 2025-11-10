# Fix Google Sign-In on Mobile (adna.app)

## Problem
Getting error: **"Firebase Error: Unauthorized domain authentication"** when signing in with Google on mobile via `adna.app`

## Solution
You need to add `adna.app` to Firebase Authentication authorized domains.

---

## Step-by-Step Fix

### 1. Go to Firebase Console
Open: https://console.firebase.google.com/project/adna-faa82/authentication/settings

### 2. Navigate to Authorized Domains
- Click on **"Authentication"** in the left sidebar
- Click on **"Settings"** tab
- Scroll down to **"Authorized domains"** section

### 3. Add Your Custom Domain
Click **"Add domain"** button and add:

```
adna.app
```

### 4. Current Authorized Domains Should Include:
- ✅ `localhost` (for local development)
- ✅ `adna-faa82.web.app` (Firebase default domain)
- ✅ `adna-faa82.firebaseapp.com` (Firebase app domain)
- ✅ `adna.app` ← **ADD THIS**

### 5. If You Added www Subdomain
Also add:
```
www.adna.app
```

### 6. Save Changes
Click **"Save"** or changes auto-save

---

## Verification

After adding the domain:

1. **Wait 1-2 minutes** for changes to propagate
2. **Open your mobile browser** to `https://adna.app`
3. **Try signing in with Google** again
4. **Should work immediately!** ✅

---

## Why This Happened

Firebase Authentication requires all domains to be explicitly whitelisted for security reasons. When you:
- Deploy to default Firebase domains → They're auto-whitelisted
- Add a custom domain → You must manually whitelist it

This prevents unauthorized websites from using your Firebase authentication.

---

## Additional Check: Enable Email/Password Auth

While you're in the Firebase Console, also enable Email/Password authentication if not already done:

1. Go to: https://console.firebase.google.com/project/adna-faa82/authentication/providers
2. Click on **"Email/Password"**
3. Enable **"Email/Password"** (first toggle)
4. Click **"Save"**

This will enable the email/password login option on your login page.

---

## Summary

✅ Add `adna.app` to Firebase Authentication → Settings → Authorized domains
✅ Wait 1-2 minutes for propagation
✅ Try Google Sign-In again on mobile

Should be working immediately after adding the domain!
