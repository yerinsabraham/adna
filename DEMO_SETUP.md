# Demo Account Setup

## Overview
A demo login feature has been added to allow testing the dashboard and app features without completing KYC.

## Demo Account Details
- **Email**: demo@adna.com
- **Password**: demo123456

## Setup Instructions

### 1. Create Demo User in Firebase Console

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project: **adna-faa82**
3. Navigate to **Authentication** → **Users**
4. Click **Add User**
5. Enter:
   - Email: `demo@adna.com`
   - Password: `demo123456`
6. Click **Add User**

### 2. How Demo Login Works

When a user clicks "Demo Login":
1. App signs in with demo@adna.com credentials
2. Checks if merchant profile exists
3. If no profile exists, automatically creates a pre-approved merchant with:
   - **Business Name**: Demo Business Ltd
   - **Status**: Approved (skips KYC review)
   - **Tier**: Enterprise (highest tier for full testing)
   - **Daily Limit**: ₦100M
   - **Monthly Limit**: ₦1B
4. Navigates directly to dashboard

### 3. Demo Merchant Details

The auto-created demo merchant has:
- Business Name: Demo Business Ltd
- Trading Name: Demo Store
- Business Type: Limited Liability Company
- Industry: Technology
- CAC Number: RC1234567
- TIN: TIN9876543
- Bank: Access Bank
- Account Number: 0123456789
- Owner Name: Demo User
- Status: **Approved** (ready to use)
- Tier: Enterprise
- **Admin Access**: ✅ **Enabled** (special admin privileges)

### 4. Admin Dashboard Access

The demo user has **exclusive admin access** with the following capabilities:

#### Admin Features:
1. **Review Merchant Applications**
   - Approve or reject pending KYC applications
   - View detailed merchant information
   - Add rejection reasons

2. **View All Merchants**
   - See complete merchant list (approved, pending, rejected)
   - Filter by status
   - Monitor merchant activity

3. **Platform Statistics**
   - Total merchants count
   - Pending reviews count
   - Approved/rejected counts
   - Total transactions
   - Transaction volume

4. **Merchant Management**
   - Suspend merchant accounts
   - Reactivate suspended accounts
   - View merchant details

#### Accessing Admin Dashboard:
1. Login with demo account
2. Go to **Settings** screen
3. Look for **"Admin Dashboard"** button (red/warning colored)
4. Only visible to demo user
5. Click to enter admin panel

### 5. Features You Can Test with Demo Login

✅ **Dashboard**
- View balance and stats
- See transaction history
- Access quick actions

✅ **Create Payment**
- Generate QR codes
- Create payment links
- Test crypto payment flow

✅ **Transactions**
- View all transactions
- Filter and search
- Export transaction data

✅ **Settings**
- View profile
- Change password
- Update business information
- Access account settings
- **Admin Dashboard** (demo user only)

✅ **Admin Features** (demo user only)
- Review pending merchant applications
- Approve/reject KYC submissions
- View all merchants by status
- Monitor platform statistics
- Suspend/reactivate merchants
- View transaction volumes

✅ **Full App Navigation**
- All menu items
- All features unlocked
- No KYC restrictions

### 5. Testing Workflow

**Regular User Testing:**
1. Open app
2. Click "Demo Login" button (orange/warning colored)
3. Wait for sign-in and merchant creation
4. Dashboard opens automatically
5. Test all features freely

**Admin Testing:**
1. Login with demo account
2. Navigate to Settings
3. Click "Admin Dashboard" button (visible only to demo user)
4. Test admin features:
   - Review pending applications
   - Approve/reject merchants
   - View platform stats
   - Manage all merchants

### 6. Removing Demo Login for Production

Before releasing the app:

1. Remove demo button from `login_screen.dart`:
   - Delete the `_handleDemoLogin()` method
   - Remove the Demo Login button widget (lines ~216-247)

2. Remove demo merchant creation from `merchant_provider.dart`:
   - Delete the `createDemoMerchant()` method (lines ~253-314)

3. Delete demo user from Firebase:
   - Go to Firebase Console → Authentication
   - Find demo@adna.com
   - Click menu → Delete Account

4. Remove admin provider from `main.dart`:
   - Remove `ChangeNotifierProvider(create: (_) => AdminProvider())`
   - Remove admin provider import

5. Delete admin screens (optional):
   - `lib/presentation/screens/admin/admin_dashboard_screen.dart`
   - `lib/presentation/screens/admin/merchant_review_screen.dart`
   - `lib/presentation/screens/admin/all_merchants_screen.dart`
   - `lib/presentation/providers/admin_provider.dart`

### 7. Security Notes

⚠️ **IMPORTANT**:
- Demo login is for DEVELOPMENT/TESTING ONLY
- Do NOT release to production with demo login enabled
- Demo account has full enterprise access + **ADMIN PRIVILEGES**
- Anyone with demo credentials can approve/reject merchants
- Can suspend any merchant account
- Remove before public release

### 8. Alternative: Environment-Based Demo

To keep demo login only in development builds, wrap the button in:

```dart
// Only show in debug mode
if (kDebugMode) ...[
  const SizedBox(height: 16),
  // Demo Login Button
  OutlinedButton(...)
],
```

This ensures demo login only appears in development builds, not in release builds.

## Troubleshooting

**Problem**: "Demo account not found"
**Solution**: Create the demo user in Firebase Console first

**Problem**: "Failed to create demo account"
**Solution**: Check Firestore rules allow merchant creation

**Problem**: Demo merchant shows as pending
**Solution**: Status should be set to `approved` in the code

**Problem**: Admin Dashboard button not showing
**Solution**: Check merchant.isAdmin is true, reload merchant data

**Problem**: Can't approve/reject merchants
**Solution**: Check Firestore rules allow merchant updates

## Files Modified

1. `lib/presentation/screens/auth/login_screen.dart`
   - Added `_handleDemoLogin()` method
   - Added Demo Login button UI
   - Import MerchantProvider

2. `lib/presentation/providers/merchant_provider.dart`
   - Added `createDemoMerchant()` method
   - Creates pre-approved demo merchant with `isAdmin: true`

3. `lib/presentation/screens/onboarding/review_submit_screen.dart`
   - Changed "Submit Application" to "Submit" (fixed overflow)

4. `lib/data/models/merchant.dart`
   - Added `isAdmin` field
   - Updated toMap(), fromMap(), copyWith()

5. `lib/presentation/providers/admin_provider.dart` **(NEW)**
   - Manages admin operations
   - Approve/reject merchants
   - Load platform stats
   - Suspend/reactivate merchants

6. `lib/presentation/screens/admin/admin_dashboard_screen.dart` **(NEW)**
   - Main admin dashboard
   - Platform overview stats
   - Quick actions
   - Pending applications list

7. `lib/presentation/screens/admin/merchant_review_screen.dart` **(NEW)**
   - List all pending applications
   - Detailed merchant view
   - Approve/reject actions
   - Add rejection reasons

8. `lib/presentation/screens/admin/all_merchants_screen.dart` **(NEW)**
   - View all merchants
   - Filter by status
   - Merchant management

9. `lib/presentation/screens/settings/settings_screen.dart`
   - Added Admin Dashboard button
   - Only visible when `merchant.isAdmin == true`
   - Red/warning colored for visibility

10. `lib/main.dart`
    - Added AdminProvider to MultiProvider
    - Import admin_provider.dart

## Next Steps

1. ✅ Create demo@adna.com user in Firebase Console
2. ✅ Test demo login flow
3. ✅ Verify dashboard access
4. ✅ Test admin dashboard access
5. ✅ Test merchant approval/rejection
6. ✅ Test all app features
7. ⚠️ Remove demo login & admin access before production release

## Admin Dashboard UI Flow

```
Settings Screen
    └─> Admin Dashboard Button (only for demo user)
            └─> Admin Dashboard
                    ├─> Platform Overview (stats cards)
                    ├─> Quick Actions
                    │       ├─> Review Applications
                    │       ├─> All Merchants
                    │       └─> Platform Settings
                    └─> Recent Pending Applications
                            └─> Click merchant → Full details
                                    ├─> Business Info
                                    ├─> Owner Info
                                    ├─> Bank Account
                                    ├─> Tier & Limits
                                    ├─> Documents
                                    └─> [Reject] [Approve] buttons
```

## Platform Statistics Tracked

- Total Merchants
- Approved Merchants
- Pending Merchants
- Rejected Merchants
- Total Transactions
- Total Transaction Volume (₦)

All statistics auto-update when merchants are approved/rejected.
