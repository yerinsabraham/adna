// Firebase configuration
// Get these values from your Firebase Console > Project Settings

const hasValidConfig = 
  import.meta.env.VITE_FIREBASE_API_KEY && 
  !import.meta.env.VITE_FIREBASE_API_KEY.includes('YOUR_ACTUAL') &&
  !import.meta.env.VITE_FIREBASE_API_KEY.includes('placeholder');

export const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "adna-faa82.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "adna-faa82",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "adna-faa82.appspot.com",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || ""
};

export const FIREBASE_ENABLED = hasValidConfig;

// Admin email for automatic admin access
export const ADMIN_EMAIL = import.meta.env.VITE_ADMIN_EMAIL || "yerinssaibs@gmail.com";

// Partner API configuration
export const PARTNER_API_CONFIG = {
  baseUrl: import.meta.env.VITE_PARTNER_API_BASE_URL || "https://api.partner.com",
  apiKey: import.meta.env.VITE_PARTNER_API_KEY || ""
};
