# Web Admin Dashboard - Technical Specification

## Overview
A React-based web admin dashboard hosted on Firebase to manage the Adna merchant platform. This separates admin functionality from the merchant mobile app for better security and scalability.

---

## Technology Stack

### Frontend
- **Framework**: React 18+ with TypeScript
- **UI Library**: Material-UI (MUI) or Ant Design
- **State Management**: React Context API + React Query
- **Routing**: React Router v6
- **Forms**: React Hook Form + Yup validation
- **Charts**: Recharts or Chart.js
- **Build Tool**: Vite

### Backend/Database
- **Authentication**: Firebase Authentication (Google Sign-In)
- **Database**: Cloud Firestore (existing collections)
- **Storage**: Firebase Storage (for documents)
- **Hosting**: Firebase Hosting
- **Functions**: Firebase Cloud Functions (for admin operations)

---

## Authentication

### Admin Access
- **Single Admin User**: `yerinssaibs@gmail.com`
- **Method**: Google Sign-In via Firebase Auth
- **Security Rules**: Firestore rules check if authenticated user email matches admin email
- **Session**: Persistent login with Firebase Auth tokens

### Security Implementation
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
             request.auth.token.email == 'yerinssaibs@gmail.com';
    }
    
    // Merchants collection - admin can read/write all
    match /merchants/{merchantId} {
      allow read: if isAdmin() || request.auth.uid == merchantId;
      allow write: if isAdmin();
    }
    
    // Transactions - admin can read all
    match /transactions/{transactionId} {
      allow read: if isAdmin() || 
                     resource.data.merchantId == request.auth.uid;
      allow create, update: if request.auth.uid == resource.data.merchantId;
      allow delete: if isAdmin();
    }
  }
}
```

---

## Core Features

### 1. Dashboard Home
**Purpose**: Platform overview with key metrics

**Components**:
- Total merchants count (all, pending, approved, rejected)
- Total transaction volume (today, week, month)
- Revenue metrics
- Recent activity feed
- Quick action buttons

**API/Data**:
- Query Firestore `merchants` collection for counts
- Aggregate `transactions` collection for volumes
- Real-time listeners for live updates

---

### 2. Merchant Management

#### 2.1 Pending Applications
**Purpose**: Review and process new merchant applications

**UI Elements**:
- List view with filters (date, category, tier)
- Search by business name, email, CAC number
- Merchant detail modal/page showing:
  - Business information
  - Owner details
  - KYC documents (viewable/downloadable)
  - Bank account info
  - Registration type

**Actions**:
- **Approve**: Set `kycStatus: 'approved'`, assign tier, set limits
- **Reject**: Set `kycStatus: 'rejected'`, add rejection reason
- **Request More Info**: Send notification to merchant

**Data Structure**:
```typescript
interface Merchant {
  id: string;
  userId: string;
  email: string;
  businessName: string;
  cacNumber: string;
  tin: string;
  category: string;
  businessAddress: string;
  businessPhone: string;
  ownerName: string;
  bvnOrNin: string;
  dateOfBirth: string;
  residentialAddress: string;
  ownerPhone: string;
  idType: 'bvn' | 'nin';
  bankName: string;
  accountNumber: string;
  accountName: string;
  accountType: string;
  kycStatus: 'pending' | 'approved' | 'rejected';
  documents: {
    cacCertificate?: string;
    utilityBill?: string;
    idDocument?: string;
  };
  tier: 'starter' | 'growth' | 'enterprise';
  dailyLimit: number;
  monthlyLimit: number;
  registrationType: 'individual' | 'business';
  isAdmin: boolean;
  createdAt: Date;
  updatedAt: Date;
  rejectionReason?: string;
}
```

#### 2.2 All Merchants
**Purpose**: View and manage all merchants

**Features**:
- Filterable table (status, tier, category)
- Search functionality
- Export to CSV
- Bulk actions (suspend, reactivate)
- Individual merchant actions:
  - View details
  - Edit tier/limits
  - Suspend/Reactivate
  - View transaction history

---

### 3. Transaction Monitoring

**Purpose**: Monitor all platform transactions

**Features**:
- Real-time transaction list
- Filters: date range, status, merchant, amount range
- Search by transaction ID, customer info
- Transaction details modal
- Export reports

**Data Display**:
- Transaction ID
- Merchant name
- Customer details
- Amount
- Status (pending, completed, failed)
- Timestamp
- Payment method

---

### 4. Analytics & Reports

**Purpose**: Platform insights and reporting

**Dashboards**:
- **Revenue Analytics**: Daily/weekly/monthly revenue charts
- **Merchant Growth**: New signups, approval rate, churn
- **Transaction Analytics**: Volume trends, success rates
- **Top Performers**: Top merchants by transaction volume

**Export Options**:
- CSV/Excel export
- PDF reports
- Date range selection

---

### 5. Settings & Configuration

**Purpose**: Platform configuration

**Features**:
- Tier limits configuration
- Fee structure management
- Notification templates
- Platform announcements
- Admin profile

---

## Page Structure

```
/
├── /login                    # Admin login (Google Sign-In)
├── /dashboard                # Main dashboard
├── /merchants
│   ├── /pending              # Pending applications
│   ├── /all                  # All merchants
│   └── /[id]                 # Merchant detail page
├── /transactions             # Transaction monitoring
├── /analytics                # Analytics & reports
└── /settings                 # Platform settings
```

---

## Firebase Firestore Collections

### Merchants Collection
```
merchants/{merchantId}
- All merchant data fields
- Subcollections:
  - transactions/{transactionId}
  - notifications/{notificationId}
```

### Transactions Collection
```
transactions/{transactionId}
- merchantId
- amount
- status
- customerDetails
- timestamp
- paymentMethod
- metadata
```

### Platform Settings Collection
```
settings/config
- tierLimits: { starter, growth, enterprise }
- feeStructure: { percentage, fixedFee }
- notifications: { templates }
```

---

## Development Phases

### Phase 1: Setup & Authentication (Week 1)
- Initialize React project with Vite + TypeScript
- Set up Firebase SDK (Auth, Firestore, Storage)
- Implement Google Sign-In
- Create protected routes
- Deploy to Firebase Hosting

### Phase 2: Core Admin Features (Week 2-3)
- Dashboard home with metrics
- Pending applications review screen
- Approve/reject functionality
- Document viewer
- All merchants list

### Phase 3: Transaction Monitoring (Week 4)
- Transaction list view
- Filters and search
- Transaction details modal
- Export functionality

### Phase 4: Analytics & Polish (Week 5)
- Analytics dashboards
- Charts and reports
- Settings page
- UI/UX refinements
- Testing

---

## Security Considerations

1. **Admin-Only Access**: Only `yerinssaibs@gmail.com` can access
2. **Firestore Rules**: Enforce admin email check at database level
3. **HTTPS Only**: Firebase Hosting enforces HTTPS
4. **Audit Logs**: Log all admin actions (approve/reject) with timestamps
5. **Document Access**: Secure URLs for KYC documents with expiry
6. **Environment Variables**: Store sensitive config in `.env`

---

## Deployment

### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project
firebase init hosting

# Build and deploy
npm run build
firebase deploy --only hosting
```

### CI/CD (Optional)
- GitHub Actions workflow
- Auto-deploy on push to `main` branch
- Preview deployments for pull requests

---

## Next Steps

1. **Create React project**: `npm create vite@latest adna-admin -- --template react-ts`
2. **Set up Firebase**: Initialize Firebase project, enable Google Auth
3. **Install dependencies**: MUI, React Router, React Query, Firebase SDK
4. **Implement authentication**: Google Sign-In flow
5. **Build dashboard home**: Fetch and display metrics
6. **Create merchant review UI**: List, detail view, approve/reject
7. **Deploy to Firebase Hosting**: Initial deployment
8. **Iterate**: Add features incrementally

---

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [React + Vite](https://vitejs.dev/guide/)
- [Material-UI](https://mui.com/)
- [React Query](https://tanstack.com/query/latest)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)

---

## Questions to Address

1. Do you want a separate Firebase project for admin, or use the existing one?
2. Should merchants receive email notifications when approved/rejected?
3. Do you need 2FA for admin login for extra security?
4. Should there be an audit log of all admin actions?
5. Do you want to add more admin users in the future?

---

**Created**: November 10, 2025  
**Status**: Planning Phase  
**Admin Email**: yerinssaibs@gmail.com
