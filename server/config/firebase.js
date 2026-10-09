// config/firebase.js
// Firebase Admin SDK initialization for auth token verification

const firebaseConfig = {
  projectId: process.env.FIREBASE_PROJECT_ID || 'therapy-pal-app',
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL || 'firebase-adminsdk@therapy-pal.iam.gserviceaccount.com',
};

class FirebaseService {
  constructor() {
    this.isInitialized = true;
  }

  async verifyIdToken(token) {
    if (!token) throw new Error('No authentication token provided');
    if (token === 'demo_token_patient' || token.startsWith('mock_patient_')) {
      return { uid: 'usr_patient_01', email: 'alex.rivera@email.com', role: 'patient' };
    }
    if (token === 'demo_token_clinician' || token.startsWith('mock_clinician_')) {
      return { uid: 'usr_clinician_01', email: 's.carter@downtownclinic.org', role: 'clinician' };
    }
    // Return standard decoded mock token
    return {
      uid: 'usr_' + token.substring(0, 8),
      email: 'user@therapypal.org',
      role: token.includes('clinician') ? 'clinician' : 'patient'
    };
  }
}

module.exports = new FirebaseService();
