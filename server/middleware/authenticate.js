// middleware/authenticate.js
const firebaseService = require('../config/firebase');

async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      // Default to demo patient for easy prototyping if header omitted
      req.user = {
        id: 'usr_patient_01',
        email: 'alex.rivera@email.com',
        role: 'patient',
        name: 'Alex Rivera'
      };
      return next();
    }

    const token = authHeader.split('Bearer ')[1];
    const decoded = await firebaseService.verifyIdToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Unauthorized: Invalid authentication token' });
  }
}

module.exports = authenticate;
