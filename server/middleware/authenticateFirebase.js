import { verifyFirebaseToken } from '../config/firebase.js';
import { HttpError } from './errorHandler.js';

export async function authenticateFirebase(req, _res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    
    if (!token) {
      return next(new HttpError(401, 'Firebase token required'));
    }
    
    const decoded = await verifyFirebaseToken(token);
    req.firebaseIdentity = decoded;
    next();
  } catch (err) {
    next(new HttpError(401, 'Invalid or expired Firebase token'));
  }
}
export default authenticateFirebase;