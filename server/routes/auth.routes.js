import { Router } from 'express';
import { authenticateRequired } from '../middleware/authenticateRequired.js';
import { authenticateFirebase } from '../middleware/authenticateFirebase.js';
import { loginSchema, registerSchema, updateProfileSchema, prefsSchema, parse } from '../validators/auth.validator.js';
import { registerUser, loginUser, loginAdmin, signToken, getProfile, updateProfile, updatePrefs } from '../services/auth.service.js';
import { findOne } from '../config/db.js';

const router = Router();

// Admin login with email/password
router.post('/login', async (req, res, next) => {
  try {
    const data = parse(loginSchema, req.body);
    if (data.role === 'admin') {
      const result = await loginAdmin(data.email, data.password);
      return res.json(result);
    }
    const user = await loginUser(data.email, data.password, data.role);
    const token = signToken(user);
    const profile = await getProfile(user.id);
    res.json({ token, user: profile });
  } catch (err) {
    next(err);
  }
});

// Firebase session verification
router.post('/session', authenticateFirebase, async (req, res, next) => {
  try {
    const user = await findOne('users', { firebaseUid: req.firebaseIdentity.uid });
    if (!user) {
      return res.status(404).json({ error: { message: 'No profile found. Please register first.' } });
    }
    const profile = await getProfile(user.id);
    res.json({ user: profile });
  } catch (err) {
    next(err);
  }
});

// Firebase registration
router.post('/register', authenticateFirebase, async (req, res, next) => {
  try {
    const body = {
      email: req.firebaseIdentity?.email,
      ...req.body,
    };
    const data = parse(registerSchema, body);
    const user = await registerUser(data, req.firebaseIdentity.uid);
    const profile = await getProfile(user.id);
    res.status(201).json({ user: profile });
  } catch (err) {
    next(err);
  }
});

// Get current user profile
router.get('/me', authenticateRequired, async (req, res, next) => {
  try {
    const profile = await getProfile(req.user.id);
    res.json({ user: profile });
  } catch (err) {
    next(err);
  }
});

// Update profile
router.patch('/me', authenticateRequired, async (req, res, next) => {
  try {
    const data = parse(updateProfileSchema, req.body);
    const profile = await updateProfile(req.user.id, data);
    res.json({ user: profile });
  } catch (err) {
    next(err);
  }
});

// Update notification prefs
router.patch('/me/prefs', authenticateRequired, async (req, res, next) => {
  try {
    const data = parse(prefsSchema, req.body);
    const profile = await updatePrefs(req.user.id, data);
    res.json({ user: profile });
  } catch (err) {
    next(err);
  }
});

export default router;
