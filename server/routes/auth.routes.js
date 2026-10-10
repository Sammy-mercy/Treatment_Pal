// routes/auth.routes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { validateLogin, validateRegister } = require('../validators/auth.validator');
const authenticateFirebase = require('../middleware/authenticateFirebase');

// Server-provisioned admin login. Patient/clinician credentials are verified by Firebase Auth.
router.post('/login', validateLogin, authController.login);

router.post('/session', authenticateFirebase, authController.createSession);
router.post('/register', authenticateFirebase, validateRegister, authController.register);

// POST /api/auth/refresh
module.exports = router;
