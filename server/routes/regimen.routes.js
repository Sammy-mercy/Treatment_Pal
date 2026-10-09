// routes/regimen.routes.js
const express = require('express');
const router = express.Router();
const regimenController = require('../controllers/regimen.controller');
const authenticate = require('../middleware/authenticate');
const authorize = require('../middleware/authorize');
const { validateCreateRegimen, validateUpdateRegimen } = require('../validators/regimen.validator');

// All regimen routes require authentication
router.use(authenticate);

// GET /api/regimens - Patient sees their own; Clinician sees assigned
router.get('/', regimenController.getRegimens);

// GET /api/regimens/:id
router.get('/:id', regimenController.getRegimenById);

// POST /api/regimens - Clinician creates regimen
router.post('/', authorize('clinician'), validateCreateRegimen, regimenController.createRegimen);

// PUT /api/regimens/:id - Clinician updates regimen status or title
router.put('/:id', authorize('clinician'), validateUpdateRegimen, regimenController.updateRegimen);

// PATCH /api/regimens/:id/items/:itemId/toggle - Pause/resume item
router.patch('/:id/items/:itemId/toggle', regimenController.toggleItem);

module.exports = router;
