import { initializeApp } from 'firebase/app';
import type { User as FirebaseUser } from 'firebase/auth';
import { 
  getAuth, 
  GoogleAuthProvider, 
  signInWithPopup,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  updateProfile,
  signOut as firebaseSignOut,
  onAuthStateChanged
} from 'firebase/auth';
import { updateEmail, reauthenticateWithCredential, EmailAuthProvider, sendEmailVerification } from 'firebase/auth';
import { 
  getFirestore, 
  collection, 
  doc, 
  getDoc, 
  setDoc, 
  updateDoc, 
  query, 
  where, 
  getDocs,
  addDoc,
  Timestamp,
  orderBy,
  limit,
  deleteDoc,
  onSnapshot
} from 'firebase/firestore';
import { getStorage, ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { firebaseConfig, ADMIN_EMAIL, FIREBASE_ENABLED } from '../config/firebase';
import type { Merchant, Transaction } from '../types';

// Initialize Firebase only if config is valid
let app: any = null;
let auth: any = null;
let db: any = null;
let storage: any = null;

if (FIREBASE_ENABLED) {
  try {
    app = initializeApp(firebaseConfig);
    auth = getAuth(app);
    db = getFirestore(app);
    storage = getStorage(app);
    console.log('✅ Firebase initialized successfully');
  } catch (error) {
    console.error('❌ Firebase initialization error:', error);
  }
} else {
  console.warn('⚠️ Firebase not initialized - missing configuration. Please update .env file with your Firebase credentials.');
}

export { auth, db, storage };

// Google Auth Provider
const googleProvider = new GoogleAuthProvider();

// Auth functions
export const signInWithGoogle = async () => {
  try {
    const result = await signInWithPopup(auth, googleProvider);
    return result.user;
  } catch (error: any) {
    console.error('Error signing in with Google:', error);
    throw new Error(error.message);
  }
};

export const signInWithEmail = async (email: string, password: string) => {
  try {
    const result = await signInWithEmailAndPassword(auth, email, password);
    return result.user;
  } catch (error: any) {
    console.error('Error signing in with email:', error);
    let errorMessage = 'Failed to sign in';
    
    switch (error.code) {
      case 'auth/user-not-found':
        errorMessage = 'No account found with this email';
        break;
      case 'auth/wrong-password':
        errorMessage = 'Incorrect password';
        break;
      case 'auth/invalid-email':
        errorMessage = 'Invalid email address';
        break;
      case 'auth/user-disabled':
        errorMessage = 'This account has been disabled';
        break;
      case 'auth/too-many-requests':
        errorMessage = 'Too many failed attempts. Please try again later';
        break;
      default:
        errorMessage = error.message;
    }
    
    throw new Error(errorMessage);
  }
};

export const signUpWithEmail = async (email: string, password: string, fullName: string) => {
  try {
    // Create user account
    const result = await createUserWithEmailAndPassword(auth, email, password);
    const user = result.user;
    
    // Update profile with display name
    await updateProfile(user, {
      displayName: fullName,
    });
    
    // Create merchant record in Firestore with incomplete status
    await setDoc(doc(db, 'merchants', user.uid), {
      id: user.uid,
      email: email,
      businessName: fullName, // Will be updated during onboarding
      ownerName: fullName,
      kycStatus: 'incomplete',
      isActive: false,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    });
    
    return user;
  } catch (error: any) {
    console.error('Error signing up with email:', error);
    let errorMessage = 'Failed to create account';
    
    switch (error.code) {
      case 'auth/email-already-in-use':
        errorMessage = 'An account with this email already exists';
        break;
      case 'auth/invalid-email':
        errorMessage = 'Invalid email address';
        break;
      case 'auth/weak-password':
        errorMessage = 'Password is too weak. Use at least 6 characters';
        break;
      case 'auth/operation-not-allowed':
        errorMessage = 'Email/password sign-up is not enabled';
        break;
      default:
        errorMessage = error.message;
    }
    
    throw new Error(errorMessage);
  }
};

export const signOut = async () => {
  try {
    await firebaseSignOut(auth);
  } catch (error: any) {
    console.error('Error signing out:', error);
    throw new Error(error.message);
  }
};

export const onAuthChange = (callback: (user: FirebaseUser | null) => void) => {
  return onAuthStateChanged(auth, callback);
};

// Check if user is admin
export const isAdminUser = (email: string | null): boolean => {
  return email?.toLowerCase() === ADMIN_EMAIL.toLowerCase();
};

// Merchant functions
export const getMerchant = async (userId: string): Promise<Merchant | null> => {
  try {
    const merchantRef = doc(db, 'merchants', userId);
    const merchantSnap = await getDoc(merchantRef);
    
    if (merchantSnap.exists()) {
      const data = merchantSnap.data();
      return {
        id: merchantSnap.id,
        ...data,
        createdAt: data.createdAt?.toDate() || new Date(),
        updatedAt: data.updatedAt?.toDate() || new Date(),
      } as Merchant;
    }
    return null;
  } catch (error: any) {
    console.error('Error getting merchant:', error);
    throw new Error(error.message);
  }
};

export const createMerchant = async (userId: string, data: Partial<Merchant>): Promise<void> => {
  try {
    const merchantRef = doc(db, 'merchants', userId);
    await setDoc(merchantRef, {
      ...data,
      userId,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    });
  } catch (error: any) {
    console.error('Error creating merchant:', error);
    throw new Error(error.message);
  }
};

export const updateMerchant = async (userId: string, data: Partial<Merchant>): Promise<void> => {
  try {
    const merchantRef = doc(db, 'merchants', userId);
    await updateDoc(merchantRef, {
      ...data,
      updatedAt: Timestamp.now(),
    });
  } catch (error: any) {
    console.error('Error updating merchant:', error);
    throw new Error(error.message);
  }
};

// Helper function to format merchant data (handle mobile app's object format)
const formatMerchantData = (doc: any): Merchant => {
  const data = doc.data();
  
  // Handle Address objects from mobile app
  const formatAddress = (addr: any): string => {
    if (typeof addr === 'string') return addr;
    if (addr && typeof addr === 'object') {
      return `${addr.street || ''}, ${addr.city || ''}, ${addr.state || ''}`.trim();
    }
    return '';
  };
  
  return {
    id: doc.id,
    userId: data.userId || '',
    email: data.email || '',
    businessName: data.businessName || '',
    cacNumber: data.cacNumber,
    tin: data.tin,
    category: data.category || '',
    businessAddress: formatAddress(data.businessAddress),
    businessPhone: data.businessPhone || '',
    businessEmail: data.businessEmail,
    ownerName: data.ownerName || '',
    bvn: data.bvn,
    bvnOrNin: data.bvnOrNin || '',
    dateOfBirth: data.dateOfBirth || '',
    residentialAddress: formatAddress(data.residentialAddress),
    ownerPhone: data.ownerPhone || '',
    phoneNumber: data.phoneNumber || data.ownerPhone,
    idType: data.idType || 'bvn',
    bankName: data.bankName || '',
    accountNumber: data.accountNumber || '',
    accountName: data.accountName || '',
    accountType: data.accountType || '',
    kycStatus: data.kycStatus || 'pending',
    documents: data.documents,
    tier: data.tier || 'basic',
    dailyLimit: data.dailyLimit || 0,
    monthlyLimit: data.monthlyLimit || 0,
    registrationType: data.registrationType || 'individual',
    isAdmin: data.isAdmin || false,
    isActive: data.isActive,
    createdAt: data.createdAt?.toDate() || new Date(),
    updatedAt: data.updatedAt?.toDate() || new Date(),
    approvedAt: data.approvedAt?.toDate(),
    approvedBy: data.approvedBy,
    rejectionReason: data.rejectionReason,
  } as Merchant;
};

// Get all merchants (Admin only)
export const getAllMerchants = async (): Promise<Merchant[]> => {
  try {
    console.log('🔍 Fetching all merchants...');
    const merchantsRef = collection(db, 'merchants');
    const querySnapshot = await getDocs(merchantsRef);
    
    console.log('📊 Total merchants count:', querySnapshot.docs.length);
    
    const merchants = querySnapshot.docs.map(doc => {
      const data = doc.data();
      console.log('📄 Merchant:', doc.id, 'kycStatus:', data.kycStatus);
      return formatMerchantData(doc);
    });
    
    return merchants;
  } catch (error: any) {
    console.error('❌ Error getting all merchants:', error);
    throw new Error(error.message);
  }
};

// Get pending merchants (Admin only)
export const getPendingMerchants = async (): Promise<Merchant[]> => {
  try {
    console.log('🔍 Fetching pending merchants...');
    const merchantsRef = collection(db, 'merchants');
    const q = query(
      merchantsRef, 
      where('kycStatus', '==', 'pending'),
      orderBy('createdAt', 'desc')
    );
    const querySnapshot = await getDocs(q);
    
    console.log('📊 Pending merchants count:', querySnapshot.docs.length);
    
    const merchants = querySnapshot.docs.map(doc => {
      const data = doc.data();
      console.log('📄 Pending merchant doc:', doc.id, 'Email:', data.email, 'KYC:', data.kycStatus);
      return formatMerchantData(doc);
    });
    
    return merchants;
  } catch (error: any) {
    console.error('❌ Error getting pending merchants:', error);
    console.error('Error code:', error.code);
    console.error('Error message:', error.message);
    
    // If it's an index error, try without orderBy
    if (error.code === 'failed-precondition' || error.message?.includes('index')) {
      console.log('⚠️ Index error detected, trying without orderBy...');
      try {
        const merchantsRef = collection(db, 'merchants');
        const q = query(merchantsRef, where('kycStatus', '==', 'pending'));
        const querySnapshot = await getDocs(q);
        
        console.log('📊 Pending merchants (no orderBy):', querySnapshot.docs.length);
        
        return querySnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
          createdAt: doc.data().createdAt?.toDate() || new Date(),
          updatedAt: doc.data().updatedAt?.toDate() || new Date(),
        })) as Merchant[];
      } catch (fallbackError: any) {
        console.error('❌ Fallback query also failed:', fallbackError);
        throw new Error(fallbackError.message);
      }
    }
    
    throw new Error(error.message);
  }
};

// Approve merchant (Admin only)
export const approveMerchant = async (
  merchantId: string, 
  tier: string, 
  limits: { dailyLimit: number; monthlyLimit: number }
): Promise<void> => {
  try {
    const merchantRef = doc(db, 'merchants', merchantId);
    await updateDoc(merchantRef, {
      kycStatus: 'approved',
      tier,
      dailyLimit: limits.dailyLimit,
      monthlyLimit: limits.monthlyLimit,
      isActive: true,
      updatedAt: Timestamp.now(),
    });
  } catch (error: any) {
    console.error('Error approving merchant:', error);
    throw new Error(error.message);
  }
};

// Reject merchant (Admin only)
export const rejectMerchant = async (merchantId: string, reason: string): Promise<void> => {
  try {
    const merchantRef = doc(db, 'merchants', merchantId);
    await updateDoc(merchantRef, {
      kycStatus: 'rejected',
      rejectionReason: reason,
      updatedAt: Timestamp.now(),
    });
  } catch (error: any) {
    console.error('Error rejecting merchant:', error);
    throw new Error(error.message);
  }
};

// Transaction functions
export const getTransactions = async (merchantId: string, limitCount: number = 50): Promise<Transaction[]> => {
  try {
    const transactionsRef = collection(db, 'transactions');
    const q = query(
      transactionsRef,
      where('merchantId', '==', merchantId),
      orderBy('createdAt', 'desc'),
      limit(limitCount)
    );
    const querySnapshot = await getDocs(q);
    
    return querySnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt?.toDate() || new Date(),
      completedAt: doc.data().completedAt?.toDate(),
    })) as Transaction[];
  } catch (error: any) {
    console.error('Error getting transactions:', error);
    throw new Error(error.message);
  }
};

// Get all transactions (Admin only)
export const getAllTransactions = async (limitCount: number = 100): Promise<Transaction[]> => {
  try {
    const transactionsRef = collection(db, 'transactions');
    const q = query(
      transactionsRef,
      orderBy('createdAt', 'desc'),
      limit(limitCount)
    );
    const querySnapshot = await getDocs(q);
    
    return querySnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt?.toDate() || new Date(),
      completedAt: doc.data().completedAt?.toDate(),
    })) as Transaction[];
  } catch (error: any) {
    console.error('Error getting all transactions:', error);
    throw new Error(error.message);
  }
};

// File upload function
export const uploadFile = async (file: File, path: string): Promise<string> => {
  try {
    const storageRef = ref(storage, path);
    await uploadBytes(storageRef, file);
    const downloadURL = await getDownloadURL(storageRef);
    return downloadURL;
  } catch (error: any) {
    console.error('Error uploading file:', error);
    throw new Error(error.message);
  }
};

// Admin Platform Stats
export const getPlatformStats = async (): Promise<{
  totalMerchants: number;
  pendingMerchants: number;
  approvedMerchants: number;
  rejectedMerchants: number;
  totalTransactions: number;
  totalVolume: number;
  todayVolume: number;
  monthlyVolume: number;
}> => {
  try {
    const merchantsRef = collection(db, 'merchants');
    const transactionsRef = collection(db, 'transactions');
    
    // Get all merchants
    const allMerchantsSnap = await getDocs(merchantsRef);
    const allMerchants = allMerchantsSnap.docs;
    
    // Count by status
    const pendingMerchants = allMerchants.filter(doc => doc.data().kycStatus === 'pending').length;
    const approvedMerchants = allMerchants.filter(doc => doc.data().kycStatus === 'approved').length;
    const rejectedMerchants = allMerchants.filter(doc => doc.data().kycStatus === 'rejected').length;
    
    // Get all transactions
    const allTransactionsSnap = await getDocs(transactionsRef);
    const allTransactions = allTransactionsSnap.docs;
    
    // Calculate total volume
    let totalVolume = 0;
    let todayVolume = 0;
    let monthlyVolume = 0;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
    
    allTransactions.forEach(doc => {
      const data = doc.data();
      const amount = data.amount || 0;
      const status = data.status;
      const createdAt = data.createdAt?.toDate();
      
      if (status === 'completed') {
        totalVolume += amount;
        
        if (createdAt && createdAt >= today) {
          todayVolume += amount;
        }
        
        if (createdAt && createdAt >= monthStart) {
          monthlyVolume += amount;
        }
      }
    });
    
    return {
      totalMerchants: allMerchants.length,
      pendingMerchants,
      approvedMerchants,
      rejectedMerchants,
      totalTransactions: allTransactions.length,
      totalVolume,
      todayVolume,
      monthlyVolume,
    };
  } catch (error: any) {
    console.error('Error getting platform stats:', error);
    throw new Error(error.message);
  }
};

// Merchant Dashboard Stats
export const getMerchantStats = async (merchantId: string): Promise<{
  totalTransactions: number;
  totalVolume: number;
  todayVolume: number;
  weekVolume: number;
  monthVolume: number;
  successRate: number;
  pendingSettlements: number;
}> => {
  try {
    const transactionsRef = collection(db, 'transactions');
    const q = query(transactionsRef, where('merchantId', '==', merchantId));
    const querySnapshot = await getDocs(q);
    
    const transactions = querySnapshot.docs;
    
    let totalVolume = 0;
    let todayVolume = 0;
    let weekVolume = 0;
    let monthVolume = 0;
    let successfulTransactions = 0;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const weekStart = new Date(today);
    weekStart.setDate(today.getDate() - 7);
    
    const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
    
    transactions.forEach(doc => {
      const data = doc.data();
      const amount = data.amount || 0;
      const status = data.status;
      const createdAt = data.createdAt?.toDate();
      
      if (status === 'completed') {
        totalVolume += amount;
        successfulTransactions++;
        
        if (createdAt && createdAt >= today) {
          todayVolume += amount;
        }
        
        if (createdAt && createdAt >= weekStart) {
          weekVolume += amount;
        }
        
        if (createdAt && createdAt >= monthStart) {
          monthVolume += amount;
        }
      }
    });
    
    const successRate = transactions.length > 0 
      ? (successfulTransactions / transactions.length) * 100 
      : 0;
    
    // Get pending settlements
    const settlementsRef = collection(db, 'settlements');
    const settlementsQuery = query(
      settlementsRef,
      where('merchantId', '==', merchantId),
      where('status', '==', 'pending')
    );
    const settlementsSnap = await getDocs(settlementsQuery);
    
    return {
      totalTransactions: transactions.length,
      totalVolume,
      todayVolume,
      weekVolume,
      monthVolume,
      successRate,
      pendingSettlements: settlementsSnap.docs.length,
    };
  } catch (error: any) {
    console.error('Error getting merchant stats:', error);
    throw new Error(error.message);
  }
};

// Re-authenticate user using current password (email/password users)
export const reauthenticateWithPassword = async (currentPassword: string): Promise<void> => {
  try {
    const user = auth.currentUser;
    if (!user || !user.email) throw new Error('No authenticated user');
    const credential = EmailAuthProvider.credential(user.email, currentPassword);
    await reauthenticateWithCredential(user, credential);
  } catch (error: any) {
    console.error('Error reauthenticating user:', error);
    throw new Error(error.message || 'Reauthentication failed');
  }
};

// Change user's email securely and update merchant record
export const changeUserEmail = async (newEmail: string): Promise<void> => {
  try {
    const user = auth.currentUser;
    if (!user) throw new Error('No authenticated user');

    await updateEmail(user, newEmail);
    // send verification to the new email
    await sendEmailVerification(user);

    // update merchant record if exists
    try {
      await updateMerchant(user.uid, { email: newEmail });
    } catch (err) {
      console.warn('Could not update merchant email after auth email update:', err);
    }
  } catch (error: any) {
    console.error('Error changing user email:', error);
    throw new Error(error.message || 'Failed to change email');
  }
};

// Create an admin support request for email changes (for OAuth users)
export const requestEmailChange = async (userId: string, oldEmail: string, newEmail: string, reason: string = ''): Promise<void> => {
  try {
    const reqRef = collection(db, 'email_change_requests');
    await addDoc(reqRef, {
      userId,
      oldEmail,
      newEmail,
      reason,
      status: 'pending',
      createdAt: Timestamp.now(),
    });
  } catch (error: any) {
    console.error('Error creating email change request:', error);
    throw new Error(error.message || 'Failed to create request');
  }
};

// Payments (mock) - persist payment links to Firestore
export const createPaymentLink = async (merchantId: string, data: { title: string; description?: string; currency: string; amount: number; }): Promise<string> => {
  try {
    const paymentsRef = collection(db, 'payments');
    const docRef = await addDoc(paymentsRef, {
      merchantId,
      title: data.title,
      description: data.description || '',
      currency: data.currency,
      amount: data.amount,
      createdAt: Timestamp.now(),
    });
    // return a link path that the front-end can use
    return `/pay/${docRef.id}`;
  } catch (error: any) {
    console.error('Error creating payment link:', error);
    throw new Error(error.message || 'Failed to create payment link');
  }
};

export const getPayments = async (merchantId: string) => {
  try {
    const paymentsRef = collection(db, 'payments');
    const q = query(paymentsRef, where('merchantId', '==', merchantId), orderBy('createdAt', 'desc'));
    const snap = await getDocs(q);
    return snap.docs.map(d => ({ id: d.id, ...d.data() }));
  } catch (error: any) {
    console.error('Error getting payments:', error);
    throw new Error(error.message || 'Failed to get payments');
  }
};

// Notifications helpers - stored under merchants/{merchantId}/notifications
export const subscribeMerchantNotifications = (merchantId: string, cb: (items: any[]) => void) => {
  try {
    const notificationsRef = collection(db, 'merchants', merchantId, 'notifications');
    const q = query(notificationsRef, orderBy('createdAt', 'desc'), limit(50));
    const unsub = onSnapshot(q, (snapshot) => {
      const items = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
      cb(items);
    }, (err) => {
      console.error('Notifications snapshot error:', err);
      cb([]);
    });
    return unsub;
  } catch (error: any) {
    console.error('Error subscribing to notifications:', error);
    return () => {};
  }
};

export const markNotificationRead = async (merchantId: string, notificationId: string) => {
  try {
    const notifRef = doc(db, 'merchants', merchantId, 'notifications', notificationId);
    await updateDoc(notifRef, { read: true, updatedAt: Timestamp.now() } as any);
  } catch (error: any) {
    console.error('Error marking notification read:', error);
    throw new Error(error.message || 'Failed to mark notification read');
  }
};

export const deleteNotification = async (merchantId: string, notificationId: string) => {
  try {
    const notifRef = doc(db, 'merchants', merchantId, 'notifications', notificationId);
    await deleteDoc(notifRef);
  } catch (error: any) {
    console.error('Error deleting notification:', error);
    throw new Error(error.message || 'Failed to delete notification');
  }
};

// Mock account-name resolver backed by Firestore for development/testing.
// Searches `mock_account_numbers` collection for a match of bankName + accountNumber.
// If not found, creates a mock document (only when FIREBASE_ENABLED) and returns a generated name.
export const resolveAccountName = async (bankName: string, accountNumber: string): Promise<string> => {
  try {
    if (!bankName || !accountNumber) return '';

    // If Firestore isn't enabled, return a quick synthetic name
    if (!FIREBASE_ENABLED) {
      return `${bankName} Account ${accountNumber.slice(-4)}`;
    }

    const collectionRef = collection(db, 'mock_account_numbers');
    const q = query(
      collectionRef,
      where('bankName', '==', bankName),
      where('accountNumber', '==', accountNumber),
      limit(1)
    );
    const snap = await getDocs(q);
    if (!snap.empty) {
      const data = snap.docs[0].data();
      return data.accountName || `${bankName} Account ${accountNumber.slice(-4)}`;
    }

    // Not found - create a mock entry so future lookups return a consistent value
    const generatedName = `${bankName} Account ${accountNumber.slice(-4)}`;
    try {
      await addDoc(collectionRef, {
        bankName,
        accountNumber,
        accountName: generatedName,
        createdAt: Timestamp.now(),
      });
    } catch (err) {
      console.warn('Could not create mock account doc:', err);
    }

    return generatedName;
  } catch (error: any) {
    console.error('Error resolving account name:', error);
    return '';
  }
};
