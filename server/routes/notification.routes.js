// routes/notification.routes.js
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const authenticate = require('../middleware/authenticate');

router.use(authenticate);

// GET /api/notifications
router.get('/', notificationController.getNotifications);

// POST /api/notifications/read-all
router.post('/read-all', notificationController.markAllRead);

// POST /api/notifications/register-token
router.post('/register-token', notificationController.registerToken);

module.exports = router;
