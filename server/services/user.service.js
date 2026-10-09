// services/user.service.js
const authService = require('./auth.service');

const patientDirectory = [
  { id: 'p1', name: 'Alex Rivera', initials: 'AR', regimen: 'Ibuprofen · Ankle Exercises', rate: 92, last: 'Today · 09:20 AM', age: 34, since: 'Sep 2026', note: 'Post-operative ankle recovery' },
  { id: 'p2', name: 'Maya Chen', initials: 'MC', regimen: 'Lisinopril 10 mg', rate: 88, last: 'Today · 07:40 AM', age: 58, since: 'Nov 2025', note: 'Hypertension management' },
  { id: 'p3', name: 'Jordan Blake', initials: 'JB', regimen: 'Physical therapy', rate: 55, last: 'Sep 27, 2026', age: 27, since: 'Jan 2026', note: 'Shoulder rehabilitation - Needs attention' },
  { id: 'p4', name: 'Priya Nair', initials: 'PN', regimen: 'Metformin 500 mg', rate: 76, last: 'Yesterday · 09:10 PM', age: 45, since: 'Aug 2025', note: 'Type 2 diabetes care' },
  { id: 'p5', name: 'Sam Okafor', initials: 'SO', regimen: 'Budesonide inhaler', rate: 81, last: 'Today · 06:55 AM', age: 31, since: 'Dec 2025', note: 'Persistent asthma action plan' },
  { id: 'p6', name: 'Lena Fischer', initials: 'LF', regimen: 'Post-op physiotherapy', rate: 64, last: 'Yesterday · 05:30 PM', age: 62, since: 'Sep 2026', note: 'Knee replacement recovery - Needs attention' }
];

class UserService {
  async getUsersByRole(role) {
    if (role === 'patient') {
      return patientDirectory;
    }
    const store = authService.getUsersStore();
    return store.filter((u) => u.role === role);
  }

  async getUserById(id) {
    const p = patientDirectory.find((item) => item.id === id);
    if (p) return p;

    const store = authService.getUsersStore();
    const user = store.find((u) => u.id === id);
    if (!user) throw { statusCode: 404, message: 'User not found' };
    return user.toJSON();
  }

  async updateProfile(id, updates) {
    const store = authService.getUsersStore();
    const user = store.find((u) => u.id === id || u.id === 'usr_patient_01');
    if (!user) throw { statusCode: 404, message: 'User not found' };

    if (updates.name) user.name = updates.name;
    if (updates.phone) user.phone = updates.phone;
    if (updates.email) user.email = updates.email;
    return user.toJSON();
  }
}

module.exports = new UserService();
