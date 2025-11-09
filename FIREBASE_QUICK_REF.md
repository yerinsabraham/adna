# Firebase Quick Reference - Adna Project

## ✅ Deployment Status

| Component | Status | Details |
|-----------|--------|---------|
| Firestore Rules | ✅ Deployed | Security rules active |
| Firestore Indexes | ✅ Deployed | 7 indexes building/active |
| Storage Rules | ✅ Deployed | File upload security active |
| Authentication | ✅ Enabled | Email/Password + Google Sign-In |

## 📊 Data Collections

### Collections in Your Firebase:
1. **merchants** - User/merchant profiles and KYC data
2. **paymentRequests** - Payment links and crypto payment details
3. **transactions** - Completed payment records

## 🔐 What's Protected

Your Firebase now has security rules that:
- ✅ Require authentication for all operations
- ✅ Allow users to only access their own data
- ✅ Prevent unauthorized data modification
- ✅ Protect file uploads (5MB limit, image/PDF only)
- ✅ Maintain audit trail (no deletions)

## 🚀 What Happens When Users Register

```
User Registers → Email Verification → Onboarding → Merchant Doc Created in Firestore
                                                   ↓
                                    {
                                      userId: "abc123",
                                      email: "user@example.com",
                                      businessName: "...",
                                      kycStatus: "pending",
                                      ...
                                    }
```

## 📱 Testing Your Deployment

1. **Open your app** and register a new account
2. **Complete onboarding** with all business details
3. **Check Firebase Console**: https://console.firebase.google.com/project/adna-faa82/firestore
4. **You should see**: New document in `merchants` collection

## 🔍 View Your Data

**Firebase Console Shortcuts:**
- Users: https://console.firebase.google.com/project/adna-faa82/authentication/users
- Firestore: https://console.firebase.google.com/project/adna-faa82/firestore/data
- Storage: https://console.firebase.google.com/project/adna-faa82/storage

## 🛠️ Common Commands

```bash
# View all Firebase projects
firebase projects:list

# Deploy all rules
firebase deploy

# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Check index status
firebase firestore:indexes

# Start local testing
firebase emulators:start
```

## ⚠️ Important Notes

1. **Indexes Building**: Firestore indexes may take 5-15 minutes to fully build
2. **First Login**: When testing, complete the full onboarding flow
3. **Data Validation**: All fields in onboarding are required
4. **File Uploads**: Must be < 5MB, images or PDF only
5. **Admin Approval**: KYC status starts as "pending", needs manual approval

## 🎯 Next Actions

- [ ] Test user registration
- [ ] Complete onboarding flow
- [ ] Verify data appears in Firebase Console
- [ ] Test payment creation
- [ ] Review uploaded documents in Storage

## 📞 Firebase Support

If you see permission errors:
1. Check user is logged in (`FirebaseAuth.instance.currentUser`)
2. Verify rules are deployed (`firebase deploy --only firestore:rules`)
3. Wait for indexes to build (check Console → Firestore → Indexes)

---

**Your Firebase backend is live! 🎉**
All user data, KYC details, and payment information will now be securely stored in Firebase.
