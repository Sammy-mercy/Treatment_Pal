// services/adherence.service.js
const AdherenceLog = require('../models/AdherenceLog');

const logsStore = [
  new AdherenceLog({
    id: 'log_01',
    regimenItemId: 'item_02',
    patientId: 'usr_patient_01',
    status: 'taken',
    loggedAt: '2026-09-29T09:20:00Z',
    notes: 'Completed full set'
  }),
  new AdherenceLog({
    id: 'log_02',
    regimenItemId: 'item_03',
    patientId: 'usr_patient_01',
    status: 'taken',
    loggedAt: '2026-09-29T08:06:00Z'
  }),
  new AdherenceLog({
    id: 'log_03',
    regimenItemId: 'item_01',
    patientId: 'usr_patient_01',
    status: 'taken',
    loggedAt: '2026-09-29T08:05:00Z'
  }),
  new AdherenceLog({
    id: 'log_04',
    regimenItemId: 'item_03',
    patientId: 'usr_patient_01',
    status: 'missed',
    loggedAt: '2026-09-28T20:00:00Z',
    notes: 'Late working shift'
  })
];

class AdherenceService {
  async getLogsForPatient(patientId) {
    return logsStore.filter((l) => l.patientId === patientId || patientId === 'usr_patient_01');
  }

  async logDose(data, patientId) {
    const newLog = new AdherenceLog({
      regimenItemId: data.regimenItemId,
      patientId: patientId || 'usr_patient_01',
      status: data.status,
      scheduledAt: data.scheduledAt || new Date().toISOString(),
      loggedAt: new Date().toISOString(),
      notes: data.notes || ''
    });

    logsStore.unshift(newLog);
    return newLog;
  }

  async calculateCompliance(patientId) {
    const patientLogs = await this.getLogsForPatient(patientId);
    if (!patientLogs.length) return { rate: 100, total: 0, taken: 0, missed: 0 };

    const taken = patientLogs.filter((l) => l.status === 'taken').length;
    const missed = patientLogs.filter((l) => l.status === 'missed').length;
    const rate = Math.round((taken / (taken + missed)) * 100);

    return { rate, total: taken + missed, taken, missed };
  }
}

module.exports = new AdherenceService();
