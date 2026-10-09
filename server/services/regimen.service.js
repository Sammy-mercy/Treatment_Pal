// services/regimen.service.js
const Regimen = require('../models/Regimen');
const RegimenItem = require('../models/RegimenItem');

const regimensStore = [
  new Regimen({
    id: 'reg_01',
    title: 'Post-Op Ankle Recovery Plan',
    clinicianId: 'usr_clinician_01',
    patientId: 'usr_patient_01',
    status: 'active',
    notes: 'Take ibuprofen strictly with meals. Stop ankle band exercises if acute sharp pain occurs.',
    items: [
      new RegimenItem({
        id: 'item_01',
        regimenId: 'reg_01',
        drugName: 'Ibuprofen',
        dosage: '200 mg',
        type: 'medication',
        frequency: '3 times daily',
        times: ['08:00', '13:00', '20:00'],
        instructions: 'Take after meals'
      }),
      new RegimenItem({
        id: 'item_02',
        regimenId: 'reg_01',
        drugName: 'Ankle Exercises',
        dosage: '15 min set',
        type: 'therapy',
        frequency: '2 times daily',
        times: ['09:00', '19:00'],
        instructions: 'Dorsiflexion, circles, resistance band'
      }),
      new RegimenItem({
        id: 'item_03',
        regimenId: 'reg_01',
        drugName: 'Amoxicillin',
        dosage: '500 mg',
        type: 'medication',
        frequency: '2 times daily',
        times: ['08:00', '20:00'],
        instructions: 'Complete full course'
      }),
      new RegimenItem({
        id: 'item_04',
        regimenId: 'reg_01',
        drugName: 'Vitamin D3',
        dosage: '1000 IU',
        type: 'medication',
        frequency: 'Once daily',
        times: ['08:00'],
        active: false,
        instructions: 'Paused — normal range achieved'
      })
    ]
  })
];

class RegimenService {
  async getRegimensForUser(user) {
    if (user.role === 'patient') {
      return regimensStore.filter((r) => r.patientId === user.id || r.patientId === 'usr_patient_01');
    }
    // Clinician sees all assigned regimens
    return regimensStore.filter((r) => r.clinicianId === user.id || r.clinicianId === 'usr_clinician_01');
  }

  async getRegimenById(id) {
    const regimen = regimensStore.find((r) => r.id === id);
    if (!regimen) throw { statusCode: 404, message: 'Regimen not found' };
    return regimen;
  }

  async createRegimen(data, clinicianId) {
    const newRegimen = new Regimen({
      title: data.title,
      clinicianId,
      patientId: data.patientId,
      status: 'active',
      notes: data.notes || '',
      items: (data.items || []).map((it) => new RegimenItem({ ...it, regimenId: `reg_${Date.now()}` }))
    });

    regimensStore.unshift(newRegimen);
    return newRegimen;
  }

  async updateRegimen(id, updates) {
    const index = regimensStore.findIndex((r) => r.id === id);
    if (index === -1) throw { statusCode: 404, message: 'Regimen not found' };

    const current = regimensStore[index];
    if (updates.title) current.title = updates.title;
    if (updates.status) current.status = updates.status;
    if (updates.notes) current.notes = updates.notes;
    current.updatedAt = new Date().toISOString();

    return current;
  }

  async toggleItemActive(regimenId, itemId) {
    const regimen = await this.getRegimenById(regimenId);
    const item = regimen.items.find((i) => i.id === itemId);
    if (!item) throw { statusCode: 404, message: 'Regimen item not found' };

    item.active = !item.active;
    return item;
  }
}

module.exports = new RegimenService();
