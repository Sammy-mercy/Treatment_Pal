import { verifyFirebaseToken } from '../config/firebase.js';
import { findOne } from '../config/db.js';
import jwt from 'jsonwebtoken';

export async function authenticate(req, _res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    
    if (!token) {
      req.user = null;
      return next();
    }
    
    // Try admin / app JWT first
    try {
      const secret = process.env.ADMIN_TOKEN_SECRET || process.env.JWT_SECRET || 'dev-secret';
      const payload = jwt.verify(token, secret);
      if (payload.role === 'admin') {
        req.user = { id: 'admin', role: 'admin', email: payload.email, name: 'Admin' };
        return next();
      }
      if (payload.sub) {
        const user = await findOne('users', { id: payload.sub });
        if (user) {
          req.user = {
            id: user._id?.toString() || user.id,
            firebaseUid: user.firebaseUid,
            email: user.email,
            name: user.name,
            role: user.role,
          };
          return next();
        }
      }
    } catch (_) {
      // Not an admin/app JWT, try Firebase
    }
    
    // Try Firebase token
    const decoded = await verifyFirebaseToken(token);
    const user = await findOne('users', { firebaseUid: decoded.uid });
    
    if (user) {
      req.user = {
        id: user._id?.toString() || user.id,
        firebaseUid: decoded.uid,
        email: user.email,
        name: user.name,
        role: user.role,
      };
    } else {
      req.user = null;
    }
    
    next();
  } catch (err) {
    req.user = null;
    next();
  }
}
export default authenticate;
