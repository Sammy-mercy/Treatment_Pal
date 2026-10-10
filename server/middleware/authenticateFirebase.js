const firebaseService = require('../config/firebase');

async function authenticateFirebase(req, res, next) {
  try {
    const authorization = req.headers.authorization || '';
    if (!authorization.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Firebase authentication required' });
    }
    req.firebaseIdentity = await firebaseService.verifyFirebaseIdToken(authorization.slice(7));
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Unauthorized: Invalid Firebase ID token' });
  }
}

module.exports = authenticateFirebase;