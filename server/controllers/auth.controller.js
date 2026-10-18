// controllers/auth.controller.js
import * as authService from '../services/auth.service.js';
import { findOne } from '../config/db.js';

export async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    const result = await authService.loginAdmin(email, password);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
}

export async function createSession(req, res, next) {
  try {
    const user = await findOne('users', { firebaseUid: req.firebaseIdentity.uid });
    if (!user) {
      return res.status(404).json({ error: { message: 'No profile found. Please register first.' } });
    }
    const profile = await authService.getProfile(user.id);
    res.status(200).json({ user: profile });
  } catch (error) {
    next(error);
  }
}

export async function register(req, res, next) {
  try {
    const user = await authService.registerUser(req.body, req.firebaseIdentity?.uid);
    const profile = await authService.getProfile(user.id);
    res.status(201).json({ user: profile });
  } catch (error) {
    next(error);
  }
}

export default {
  login,
  createSession,
  register,
};
