# Firebase Deployment Complete ✅

## Deployment Summary

All Firebase backend components have been successfully deployed to your project **adna-faa82**.

### What Was Deployed

#### ✅ Firestore Security Rules (`firestore.rules`)
- **Merchants Collection**: Users can only read/write their own merchant profile
- **Payment Requests Collection**: Merchants can only access their own payment requests
- **Transactions Collection**: Read-only for merchants (transactions created by system)
- **Security**: All data is protected by authentication and ownership checks

#### ✅ Firestore Indexes (`firestore.indexes.json`)
7 composite indexes deployed for efficient queries:
1. **Merchants by KYC Status**: Fast filtering of merchants by approval status
2. **Merchants by User ID**: Quick lookup of merchant profiles by user
3. **Payment Requests by Merchant**: List all payments for a specific merchant
4. **Payment Requests by Status**: Filter payments by status (pending, completed, etc.)
5. **Payment Requests by Merchant + Status**: Combined filtering for merchant dashboard
6. **Transactions by Merchant**: Transaction history for each merchant
7. **Transactions by Merchant + Status**: Filter transactions by status

#### ✅ Storage Security Rules (`storage.rules`)
- **KYC Documents**: Only the owning user can upload/read their documents
- **File Size Limit**: 5MB maximum per file
- **File Types**: Images (JPEG, PNG) and PDF documents only
- **No Deletion**: Documents preserved for audit trail

## Data Collections Structure

### 1. Merchants Collection (`/merchants/{merchantId}`)

**Document Structure:**
```javascript
{
  userId: string,              // Firebase Auth UID
  email: string,               // Merchant email
  kycStatus: string,           // 'pending' | 'approved' | 'rejected' | 'suspended'
  
  // Business Information
  businessName: string,
  businessType: string,
  rcNumber: string,
  industry: string,
  businessAddress: string,
  businessState: string,
  
  // Owner Information
  ownerFullName: string,
  ownerPhone: string,
  ownerBvn: string,
  ownerAddress: string,
  ownerState: string,
  ownerIdType: string,
  
  // Bank Account
  bankName: string,
  accountNumber: string,
  accountName: string,
  accountType: string,
  
  // Documents
  documents: {
    cac: string,              // URL to CAC document
    idFront: string,          // URL to ID front
    idBack: string,           // URL to ID back
    addressProof: string,     // URL to address proof
    bankStatement: string     // URL to bank statement
  },
  
  // Metadata
  tier: string,               // 'basic' | 'business' | 'enterprise'
  createdAt: timestamp,
  updatedAt: timestamp,
  
  // Optional
  rejectionReason?: string,
  suspensionReason?: string
}
```

### 2. Payment Requests Collection (`/paymentRequests/{paymentId}`)

**Document Structure:**
```javascript
{
  merchantId: string,         // Firebase Auth UID of merchant
  reference: string,          // Unique payment reference
  
  // Amounts
  amountNGN: number,         // Amount in Naira
  cryptoAmount: number,      // Amount in crypto
  cryptoType: string,        // 'BTC' | 'USDT' | 'USDC' | 'SOL'
  exchangeRate: number,      // Exchange rate at time of creation
  
  // Payment Details
  walletAddress: string,     // Generated crypto address
  qrCodeData: string,        // QR code data
  description: string,       // Payment description
  
  // Status
  status: string,            // 'pending' | 'awaiting_confirmation' | 'confirmed' | 
                            // 'converting' | 'settling' | 'completed' | 'failed' | 'expired'
  
  // Timestamps
  createdAt: timestamp,
  updatedAt: timestamp,
  expiresAt: timestamp,      // Payment expiry (30 minutes)
  completedAt?: timestamp,
  
  // Transaction details (after payment received)
  transactionHash?: string,
  confirmations?: number,
  receivedAmount?: number
}
```

### 3. Transactions Collection (`/transactions/{transactionId}`)

**Document Structure:**
```javascript
{
  merchantId: string,        // Firebase Auth UID of merchant
  paymentRequestId: string,  // Reference to payment request
  reference: string,         // Payment reference
  
  // Amounts
  cryptoAmount: number,
  cryptoType: string,
  nairaAmount: number,
  exchangeRate: number,
  
  // Fees
  adnaFee: number,
  partnerFee: number,
  netAmount: number,         // Amount credited to merchant
  
  // Status
  status: string,            // 'completed' | 'failed' | 'refunded'
  
  // Settlement
  settlementStatus: string,  // 'pending' | 'processing' | 'completed' | 'failed'
  settledAt?: timestamp,
  
  // Blockchain details
  transactionHash: string,
  confirmations: number,
  
  // Timestamps
  createdAt: timestamp,
  updatedAt: timestamp
}
```

## Security Rules Summary

### Firestore Rules
- ✅ **Authentication Required**: All operations require Firebase Authentication
- ✅ **Owner-Only Access**: Users can only access their own data
- ✅ **Immutable Transactions**: Transaction records cannot be modified or deleted
- ✅ **Protected Metadata**: Critical fields like `userId` and `email` cannot be changed
- ✅ **Status Validation**: Payment status updates follow proper flow

### Storage Rules
- ✅ **User Isolation**: Each user can only access files in their `/kyc/{userId}/` folder
- ✅ **File Size Limits**: 5MB maximum per upload
- ✅ **Type Restrictions**: Only images and PDFs allowed
- ✅ **No Deletion**: Documents cannot be deleted (audit trail)

## Firestore Indexes

All necessary indexes are deployed and building. They enable:
- Fast merchant lookup by user ID
- Efficient filtering by KYC status
- Quick payment history retrieval
- Transaction filtering by status
- Dashboard performance optimization

## Testing Your Deployment

### 1. Test Authentication
```dart
// Register a new user
final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: 'merchant@example.com',
  password: 'SecurePass123!',
);
```

### 2. Test Merchant Profile Creation
```dart
// Create merchant profile
await FirebaseFirestore.instance.collection('merchants').doc(userId).set({
  'userId': userId,
  'email': userEmail,
  'businessName': 'Test Business',
  'kycStatus': 'pending',
  'createdAt': FieldValue.serverTimestamp(),
  // ... other fields
});
```

### 3. Test Security Rules
```dart
// Try to read another user's data (should fail)
try {
  await FirebaseFirestore.instance.collection('merchants').doc(otherUserId).get();
} catch (e) {
  print('Access denied: $e'); // Expected: Permission denied
}
```

### 4. Test File Upload
```dart
// Upload KYC document
final storageRef = FirebaseStorage.instance.ref('kyc/$userId/cac.pdf');
await storageRef.putFile(file);
final downloadUrl = await storageRef.getDownloadURL();
```

## Current App Data Flow

### Registration → Onboarding → Dashboard

1. **User Registers** (`RegisterScreen`)
   - Firebase Auth creates user account
   - Email verification sent
   - No Firestore data yet

2. **User Verifies Email** (`EmailVerificationScreen`)
   - Email link clicked
   - User can now proceed

3. **User Completes Onboarding** (`OnboardingWrapper`)
   - Business Info → Owner Info → Bank Account → Documents Upload → Review
   - On submit: Merchant document created in Firestore
   - KYC status: `'pending'`

4. **Admin Reviews KYC** (Manual Process)
   - Admin reviews in Firebase Console or Admin Panel
   - Updates `kycStatus` to `'approved'` or `'rejected'`

5. **Approved User Accesses Dashboard** (`DashboardScreen`)
   - Creates payment requests
   - Views transactions
   - All data stored in Firestore

## Firebase Console Access

**Project URL**: https://console.firebase.google.com/project/adna-faa82

### Quick Links:
- **Authentication**: https://console.firebase.google.com/project/adna-faa82/authentication/users
- **Firestore**: https://console.firebase.google.com/project/adna-faa82/firestore/data
- **Storage**: https://console.firebase.google.com/project/adna-faa82/storage
- **Rules**: https://console.firebase.google.com/project/adna-faa82/firestore/rules

## Monitoring & Debugging

### Check Firestore Rules
```bash
firebase firestore:rules:list
```

### Check Indexes Status
```bash
firebase firestore:indexes
```

### View Storage Rules
```bash
firebase storage:rules:list
```

### Test Rules Locally
```bash
# Start Firebase Emulators
firebase emulators:start

# Access Emulator UI
http://localhost:4000
```

## Admin Tasks

### Approve Merchant KYC
```javascript
// In Firebase Console or Admin SDK
await admin.firestore().collection('merchants').doc(merchantId).update({
  kycStatus: 'approved',
  updatedAt: admin.firestore.FieldValue.serverTimestamp()
});
```

### Reject Merchant KYC
```javascript
await admin.firestore().collection('merchants').doc(merchantId).update({
  kycStatus: 'rejected',
  rejectionReason: 'Invalid BVN verification',
  updatedAt: admin.firestore.FieldValue.serverTimestamp()
});
```

### View All Pending Merchants
```javascript
const pendingMerchants = await admin.firestore()
  .collection('merchants')
  .where('kycStatus', '==', 'pending')
  .orderBy('createdAt', 'desc')
  .get();
```

## Next Steps

1. ✅ **Firebase deployed** - Rules, indexes, and storage configured
2. ✅ **App connected** - Using Firebase SDK in Flutter app
3. 🔄 **Test registration** - Create a test account and complete onboarding
4. 🔄 **Verify data** - Check Firestore console to see merchant data
5. 🔄 **Test payments** - Create a payment request and verify it's stored
6. ⏳ **Build admin panel** - Create interface for KYC approval (future)
7. ⏳ **Set up Cloud Functions** - Automate payment processing (future)

## Troubleshooting

### "Permission Denied" Errors
- **Check**: User is authenticated (`FirebaseAuth.instance.currentUser != null`)
- **Check**: User is accessing their own data (userId matches)
- **Check**: Rules are deployed (`firebase deploy --only firestore:rules`)

### Indexes Not Working
- **Wait**: Indexes can take 5-15 minutes to build after deployment
- **Check**: Index status in Firebase Console → Firestore → Indexes
- **Build**: Indexes build automatically when queries are executed

### File Upload Fails
- **Check**: File size < 5MB
- **Check**: File type is image/jpeg, image/png, or application/pdf
- **Check**: User is uploading to their own folder (`kyc/{userId}/`)

### Data Not Appearing in App
- **Check**: Internet connection
- **Check**: Firebase initialization in `main.dart`
- **Check**: Query is correct (check merchantId == userId)
- **Refresh**: Call `await merchantProvider.refreshMerchantData()`

## Deployment Commands Reference

```bash
# Deploy everything
firebase deploy

# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Deploy only Firestore indexes
firebase deploy --only firestore:indexes

# Deploy only Storage rules
firebase deploy --only storage

# View current project
firebase projects:list

# Switch projects
firebase use <project-id>

# Test locally with emulators
firebase emulators:start
```

## Files Created/Updated

### New Files Created:
1. `firebase.json` - Firebase configuration
2. `.firebaserc` - Project selection
3. `firestore.rules` - Firestore security rules
4. `firestore.indexes.json` - Firestore indexes
5. `storage.rules` - Storage security rules
6. `FIREBASE_DEPLOYMENT.md` - This documentation

### Firebase Project:
- **Project ID**: adna-faa82
- **Project Number**: 802704810729
- **Storage Bucket**: adna-faa82.firebasestorage.app

---

## 🎉 Your Firebase backend is now fully deployed and secure!

All user data (emails, passwords, names, KYC details) will now be stored in Firebase when users:
1. Register an account
2. Complete onboarding
3. Create payment requests
4. Upload documents

Test the app now and check the Firebase Console to see your data being stored in real-time!
