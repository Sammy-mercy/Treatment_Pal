import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

let firebaseApp = null;
let auth = null;

function initFirebase() {
  if (firebaseApp) return;
  
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
  
  if (!projectId || !clientEmail || !privateKey) {
    console.warn('[firebase] Firebase credentials not configured. Using mock auth.');
    return;
  }
  
  try {
    firebaseApp = initializeApp({
      credential: cert({ projectId, clientEmail, privateKey }),
    });
    auth = getAuth(firebaseApp);
    console.log('[firebase] Firebase Admin initialized');
  } catch (err) {
    console.warn('[firebase] Firebase init error:', err.message);
  }
}

initFirebase();

export async function verifyFirebaseToken(token) {
  if (!auth) {
    // Mock mode for development
    return { uid: `mock_${token.slice(-8)}`, email: 'mock@example.com' };
  }
  return auth.verifyIdToken(token);
}

export { auth as firebaseAuth };