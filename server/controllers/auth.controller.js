// controllers/auth.controller.js
const authService = require('../services/auth.service');

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
}

async function register(req, res, next) {
  try {
    const result = await authService.register(req.body);
    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
}

async function refreshToken(req, res, next) {
  try {
    const { refreshToken: token } = req.body;
    const result = await authService.refreshToken(token);
    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  login,
  register,
  refreshToken
};
