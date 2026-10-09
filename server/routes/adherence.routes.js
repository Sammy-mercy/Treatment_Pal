// routes/adherence.routes.js
const express = require('express');
const router = express.Router();
const adherenceController = require('../controllers/adherence.controller');
const authenticate = require('../middleware/authenticate');
const { validateLogDose } = require('../validators/adherence.validator');

router.use(authenticate);

// GET /api/adherence-logs
router.get('/', adherenceController.getLogs);

// POST /api/adherence-logs - Patient logs dose taken/missed
router.post('/', validateLogDose, adherenceController.logDose);

// GET /api/adherence-logs/compliance/:patientId
router.get('/compliance/:patientId?', adherenceController.getCompliance);

module.exports = router;
