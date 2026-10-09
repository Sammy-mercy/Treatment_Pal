// routes/user.routes.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const authenticate = require('../middleware/authenticate');
const authorize = require('../middleware/authorize');

router.use(authenticate);

// GET /api/users?role=patient - Clinician directory search
router.get('/', authorize('clinician'), userController.getUsers);

// GET /api/users/:id
router.get('/:id', userController.getUserById);

// PUT /api/users/:id/profile - Update demographic/contact info
router.put('/:id/profile', userController.updateProfile);

module.exports = router;
