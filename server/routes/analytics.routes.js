const express = require('express');
const analyticsController = require('../controllers/analytics.controller');
const authenticateRequired = require('../middleware/authenticateRequired');

const router = express.Router();

router.post('/visits', analyticsController.recordAnonymousVisit);
router.post('/visit', authenticateRequired, analyticsController.recordUserVisit);

module.exports = router;