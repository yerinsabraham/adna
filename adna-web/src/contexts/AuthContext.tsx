import React, { createContext, useContext, useEffect, useState } from 'react';
import {
  signInWithGoogle as firebaseSignInWithGoogle,
  signOut as firebaseSignOut,
  onAuthChange,
  getMerchant,
  isAdminUser,
} from '../services/firebase';
import type { AuthContextType, User, Merchant } from '../types';
import toast from 'react-hot-toast';

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [merchant, setMerchant] = useState<Merchant | null>(null);
  const [loading, setLoading] = useState(true);
  const [isAdmin, setIsAdmin] = useState(false);

  useEffect(() => {
    const unsubscribe = onAuthChange(async (firebaseUser) => {
      if (firebaseUser) {
        const userData: User = {
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
          emailVerified: firebaseUser.emailVerified,
        };
        
        setUser(userData);
        setIsAdmin(isAdminUser(firebaseUser.email));

        // Load merchant data
        try {
          const merchantData = await getMerchant(firebaseUser.uid);
          setMerchant(merchantData);
        } catch (error) {
          console.error('Error loading merchant:', error);
        }
      } else {
        setUser(null);
        setMerchant(null);
        setIsAdmin(false);
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const signInWithGoogle = async () => {
    try {
      await firebaseSignInWithGoogle();
      toast.success('Successfully signed in!');
    } catch (error: any) {
      toast.error(error.message || 'Failed to sign in');
      throw error;
    }
  };

  const signOut = async () => {
    try {
      await firebaseSignOut();
      toast.success('Successfully signed out');
    } catch (error: any) {
      toast.error(error.message || 'Failed to sign out');
      throw error;
    }
  };

  const refreshMerchant = async () => {
    if (user) {
      try {
        const merchantData = await getMerchant(user.uid);
        setMerchant(merchantData);
      } catch (error) {
        console.error('Error refreshing merchant:', error);
        throw error;
      }
    }
  };

  const value: AuthContextType = {
    user,
    merchant,
    isAdmin,
    loading,
    signInWithGoogle,
    signOut,
    refreshMerchant,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
