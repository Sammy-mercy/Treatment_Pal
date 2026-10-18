// models/Regimen.js
// Regimen Schema: title, clinicianId, patientId, items[], status

export default class Regimen {
  constructor(data) {
    this.id = data.id || `reg_${Date.now()}`;
    this.title = data.title;
    this.clinicianId = data.clinicianId;
    this.patientId = data.patientId;
    this.status = data.status || 'active'; // 'active' | 'paused' | 'completed'
    this.items = data.items || []; // Array of RegimenItem objects or IDs
    this.notes = data.notes || '';
    this.startDate = data.startDate || new Date().toISOString();
    this.updatedAt = new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      clinicianId: this.clinicianId,
      patientId: this.patientId,
      status: this.status,
      items: this.items,
      notes: this.notes,
      startDate: this.startDate,
      updatedAt: this.updatedAt
    };
  }
}