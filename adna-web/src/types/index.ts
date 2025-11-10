// Address interface (for mobile app compatibility)
export interface Address {
  street: string;
  city: string;
  state: string;
}

// Document interface (for mobile app compatibility)
export interface DocumentInfo {
  type: string;
  url: string;
  fileName: string;
  uploadedAt?: Date;
}

// Type definitions for Merchant
export interface Merchant {
  id: string;
  userId: string;
  email: string;
  businessName: string;
  cacNumber?: string;
  tin?: string;
  category: string;
  businessAddress: string | Address; // Support both formats
  businessPhone: string;
  businessEmail?: string;
  ownerName: string;
  bvn?: string; // BVN field
  bvnOrNin: string;
  dateOfBirth: string;
  residentialAddress: string | Address; // Support both formats
  ownerPhone: string;
  phoneNumber?: string; // Phone number field
  idType: 'bvn' | 'nin' | string;
  bankName: string;
  accountNumber: string;
  accountName: string;
  accountType: string;
  kycStatus: 'pending' | 'approved' | 'rejected' | 'incomplete';
  documents?: {
    cacCertificate?: string;
    utilityBill?: string;
    idDocument?: string;
  } | DocumentInfo[]; // Support both formats
  tier: 'starter' | 'growth' | 'enterprise' | 'basic' | string;
  dailyLimit: number;
  monthlyLimit: number;
  registrationType: 'individual' | 'business';
  isAdmin: boolean;
  isActive?: boolean; // Active status field
  createdAt: Date;
  updatedAt: Date;
  approvedAt?: Date;
  approvedBy?: string;
  rejectionReason?: string;
}

// Type definitions for Transaction
export interface Transaction {
  id: string;
  merchantId: string;
  merchantName: string;
  amount: number;
  currency: string;
  status: 'pending' | 'completed' | 'failed' | 'cancelled';
  paymentMethod: 'card' | 'bank_transfer' | 'ussd' | 'qr_code';
  customerEmail?: string;
  customerPhone?: string;
  customerName?: string;
  reference: string;
  description?: string;
  metadata?: Record<string, any>;
  createdAt: Date;
  completedAt?: Date;
  fee: number;
  netAmount: number;
}

// Type definitions for Payment Link
export interface PaymentLink {
  id: string;
  merchantId: string;
  title: string;
  description?: string;
  amount: number;
  currency: string;
  isActive: boolean;
  url: string;
  qrCode?: string;
  expiresAt?: Date;
  createdAt: Date;
  metadata?: Record<string, any>;
}

// Type definitions for User (Firebase Auth)
export interface User {
  uid: string;
  email: string | null;
  displayName: string | null;
  photoURL: string | null;
  emailVerified: boolean;
}

// Type definitions for Auth Context
export interface AuthContextType {
  user: User | null;
  merchant: Merchant | null;
  isAdmin: boolean;
  loading: boolean;
  signInWithGoogle: () => Promise<void>;
  signOut: () => Promise<void>;
  refreshMerchant: () => Promise<void>;
}

// Type definitions for Platform Stats (Admin)
export interface PlatformStats {
  totalMerchants: number;
  pendingMerchants: number;
  approvedMerchants: number;
  rejectedMerchants: number;
  totalTransactions: number;
  totalVolume: number;
  todayVolume: number;
  monthlyVolume: number;
}

// Type definitions for Dashboard Stats (Merchant)
export interface DashboardStats {
  totalTransactions: number;
  totalVolume: number;
  todayVolume: number;
  weekVolume: number;
  monthVolume: number;
  successRate: number;
  pendingSettlements: number;
}
