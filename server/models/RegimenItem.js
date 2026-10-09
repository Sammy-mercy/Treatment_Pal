// models/RegimenItem.js
// RegimenItem Schema: drugName, dosage, frequency, times, type, regimenId

class RegimenItem {
  constructor(data) {
    this.id = data.id || `item_${Date.now()}`;
    this.regimenId = data.regimenId;
    this.drugName = data.drugName;
    this.dosage = data.dosage; // e.g. "200 mg" or "15 min set"
    this.type = data.type || 'medication'; // 'medication' | 'therapy'
    this.frequency = data.frequency || 'Daily';
    this.times = data.times || ['08:00', '20:00'];
    this.instructions = data.instructions || '';
    this.active = data.active !== undefined ? data.active : true;
  }

  toJSON() {
    return {
      id: this.id,
      regimenId: this.regimenId,
      drugName: this.drugName,
      dosage: this.dosage,
      type: this.type,
      frequency: this.frequency,
      times: this.times,
      instructions: this.instructions,
      active: this.active
    };
  }
}

module.exports = RegimenItem;
