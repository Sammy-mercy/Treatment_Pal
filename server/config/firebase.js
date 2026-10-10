const jwt = require('jsonwebtoken');
const { cert, getApps, initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const privateKey = (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n');
let firebaseApp = null;

if (privateKey && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PROJECT_ID) {
  try {
    firebaseApp = getApps()[0] || initializeApp({
      credential: cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey,
      }),
    });
  } catch (error) {
    console.error('Firebase Admin Auth initialization failed:', error.message);
  }
}

class FirebaseService {
  constructor() {
    this.auth = firebaseApp ? getAuth(firebaseApp) : null;
  }

  async verifyFirebaseIdToken(token) {
    if (process.env.NODE_ENV === 'test') {
      return jwt.verify(token, process.env.TEST_FIREBASE_TOKEN_SECRET);
    }
    if (!this.auth) throw new Error('Firebase Admin Auth is not configured');
    return this.auth.verifyIdToken(token);
  }

  async verifyIdToken(token) {
    if (!token) throw new Error('No authentication token provided');
    if (process.env.ADMIN_TOKEN_SECRET) {
      try {
        const claims = jwt.verify(token, process.env.ADMIN_TOKEN_SECRET);
        if (claims.role === 'admin') return claims;
      } catch (_) {
        // Try Firebase Authentication ID-token verification next.
      }
    }
    return this.verifyFirebaseIdToken(token);
  }
}

module.exports = new FirebaseService();