// models/AdherenceLog.js
// AdherenceLog Schema: regimenItemId, patientId, status ('taken' | 'missed'), scheduledAt, loggedAt

export default class AdherenceLog {
  constructor(data) {
    this.id = data.id || `log_${Date.now()}`;
    this.regimenItemId = data.regimenItemId;
    this.patientId = data.patientId;
    this.status = data.status; // 'taken' | 'missed'
    this.scheduledAt = data.scheduledAt || new Date().toISOString();
    this.loggedAt = data.loggedAt || new Date().toISOString();
    this.notes = data.notes || '';
  }

  toJSON() {
    return {
      id: this.id,
      regimenItemId: this.regimenItemId,
      patientId: this.patientId,
      status: this.status,
      scheduledAt: this.scheduledAt,
      loggedAt: this.loggedAt,
      notes: this.notes
    };
  }
}
