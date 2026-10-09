// routes/auth.routes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { validateLogin, validateRegister } = require('../validators/auth.validator');

// POST /api/auth/login
router.post('/login', validateLogin, authController.login);

// POST /api/auth/register
router.post('/register', validateRegister, authController.register);

// POST /api/auth/refresh
router.post('/refresh', authController.refreshToken);

module.exports = router;
