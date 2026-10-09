// validators/auth.validator.js

function validateLogin(req, res, next) {
  const { email, password } = req.body;
  if (!email || !email.includes('@')) {
    return res.status(400).json({ error: 'Valid email address is required' });
  }
  if (!password || password.length < 4) {
    return res.status(400).json({ error: 'Password must be at least 4 characters' });
  }
  next();
}

function validateRegister(req, res, next) {
  const { name, email, password, role } = req.body;
  if (!name || name.trim().length === 0) {
    return res.status(400).json({ error: 'Full name is required' });
  }
  if (!email || !email.includes('@')) {
    return res.status(400).json({ error: 'Valid email address is required' });
  }
  if (!password || password.length < 6) {
    return res.status(400).json({ error: 'Password must be at least 6 characters' });
  }
  if (!role || !['patient', 'clinician'].includes(role)) {
    return res.status(400).json({ error: 'Role must be either "patient" or "clinician"' });
  }
  next();
}

module.exports = {
  validateLogin,
  validateRegister
};
