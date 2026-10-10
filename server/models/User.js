// models/User.js
// User Schema: handles patient and clinician identities

class User {
  constructor(data) {
    this.id = data.id || `usr_${Date.now()}`;
    this.name = data.name;
    this.email = data.email;
    this.role = data.role; // 'patient' | 'clinician'
    this.phone = data.phone || '';
    this.dob = data.dob || '';
    this.npi = data.npi || null; // Clinician only
    this.specialization = data.specialization || null;
    this.assignedClinicianId = data.assignedClinicianId || null; // Patient only
    this.createdAt = data.createdAt || new Date().toISOString();
    this.lastActiveAt = data.lastActiveAt || null;
    this.totalVisits = data.totalVisits || 0;
  }

  toJSON() {
    return {
      id: this.id,
      name: this.name,
      email: this.email,
      role: this.role,
      phone: this.phone,
      dob: this.dob,
      npi: this.npi,
      specialization: this.specialization,
      assignedClinicianId: this.assignedClinicianId,
      createdAt: this.createdAt,
      lastActiveAt: this.lastActiveAt,
      totalVisits: this.totalVisits
    };
  }
}

module.exports = User;
