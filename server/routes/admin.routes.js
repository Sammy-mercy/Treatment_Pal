const express = require('express');
const analyticsController = require('../controllers/analytics.controller');
const authenticateRequired = require('../middleware/authenticateRequired');
const authorize = require('../middleware/authorize');

const router = express.Router();

router.get('/dashboard-stats', authenticateRequired, authorize('admin'), analyticsController.getDashboardStats);

module.exports = router;