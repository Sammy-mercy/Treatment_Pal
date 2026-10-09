// services/auth.service.js
const User = require('../models/User');

// Seeded users
const usersStore = [
  new User({
    id: 'usr_patient_01',
    name: 'Alex Rivera',
    email: 'alex.rivera@email.com',
    role: 'patient',
    phone: '(415) 555-0134',
    dob: '1991-03-14',
    assignedClinicianId: 'usr_clinician_01'
  }),
  new User({
    id: 'usr_clinician_01',
    name: 'Dr. Sarah Carter',
    email: 's.carter@downtownclinic.org',
    role: 'clinician',
    npi: '1740293847',
    specialization: 'Internal Medicine',
    phone: '(415) 555-0921'
  })
];

class AuthService {
  async login(email, password) {
    const user = usersStore.find((u) => u.email.toLowerCase() === email.toLowerCase());
    if (!user) {
      throw { statusCode: 401, message: 'Invalid credentials' };
    }

    const token = `jwt_mock_${user.role}_${Date.now()}`;
    const refreshToken = `ref_mock_${user.role}_${Date.now()}`;

    return {
      user: user.toJSON(),
      token,
      refreshToken
    };
  }

  async register(data) {
    const existing = usersStore.find((u) => u.email.toLowerCase() === data.email.toLowerCase());
    if (existing) {
      throw { statusCode: 409, message: 'User with this email already exists' };
    }

    const newUser = new User(data);
    usersStore.push(newUser);

    const token = `jwt_mock_${newUser.role}_${Date.now()}`;
    return {
      user: newUser.toJSON(),
      token
    };
  }

  async refreshToken(refreshToken) {
    if (!refreshToken) throw { statusCode: 400, message: 'Refresh token required' };
    return {
      token: `jwt_mock_refreshed_${Date.now()}`
    };
  }

  getUsersStore() {
    return usersStore;
  }
}

module.exports = new AuthService();
