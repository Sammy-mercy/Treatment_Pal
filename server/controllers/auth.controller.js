// controllers/auth.controller.js
const authService = require('../services/auth.service');

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    const result = await authService.loginAdmin(email, password);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
}

async function createSession(req, res, next) {
  try {
    const user = await authService.getFirebaseUser(req.firebaseIdentity);
    res.status(200).json({ user });
  } catch (error) {
    next(error);
  }
}

async function register(req, res, next) {
  try {
    const user = await authService.register(req.body, req.firebaseIdentity);
    res.status(201).json({ user });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  login,
  createSession,
  register,
};
