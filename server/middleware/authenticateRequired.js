const firebaseService = require('../config/firebase');
const db = require('../config/db');

async function authenticateRequired(req, res, next) {
  try {
    const authorization = req.headers.authorization || '';
    if (!authorization.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const identity = await firebaseService.verifyIdToken(authorization.slice(7));
    if (identity.role === 'admin') {
      req.user = identity;
      return next();
    }

    const firebaseUid = identity.uid || identity.sub;
    const profile = await db.findUserById(firebaseUid);
    if (!profile) return res.status(403).json({ error: 'Registered app profile required' });
    const { _id, ...user } = profile;
    req.user = { ...user, id: user.id || firebaseUid };
    return next();
  } catch (error) {
    return res.status(401).json({ error: 'Unauthorized: Invalid authentication token' });
  }
}

module.exports = authenticateRequired;