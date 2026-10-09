// validators/regimen.validator.js

function validateCreateRegimen(req, res, next) {
  const { title, patientId, items } = req.body;
  if (!title || title.trim().length === 0) {
    return res.status(400).json({ error: 'Regimen title is required' });
  }
  if (!patientId) {
    return res.status(400).json({ error: 'patientId is required' });
  }
  if (!items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: 'At least one regimen item is required' });
  }
  next();
}

function validateUpdateRegimen(req, res, next) {
  const { title, status } = req.body;
  if (status && !['active', 'paused', 'completed'].includes(status)) {
    return res.status(400).json({ error: 'Status must be active, paused, or completed' });
  }
  next();
}

module.exports = {
  validateCreateRegimen,
  validateUpdateRegimen
};
