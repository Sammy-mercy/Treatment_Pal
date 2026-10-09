// validators/adherence.validator.js

function validateLogDose(req, res, next) {
  const { regimenItemId, status } = req.body;
  if (!regimenItemId) {
    return res.status(400).json({ error: 'regimenItemId is required' });
  }
  if (!status || !['taken', 'missed'].includes(status)) {
    return res.status(400).json({ error: 'Status must be either "taken" or "missed"' });
  }
  next();
}

module.exports = {
  validateLogDose
};
