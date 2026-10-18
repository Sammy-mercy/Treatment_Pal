import crypto from 'crypto';
import { findOne, findMany, insertOne, updateOne } from '../config/db.js';
import { HttpError } from '../middleware/errorHandler.js';

function regimenDto(r) {
  return {
    id: r.id,
    name: r.name,
    strength: r.strength || '',
    type: r.type,
    active: r.active !== false,
    schedule: r.schedule || '',
    times: r.times || [],
    started: r.started || '',
    prescriber: r.prescriberName || 'Self-added',
    note: r.note || '',
    patientId: r.patientId,
  };
}

export async function getRegimens(patientId) {
  const regimens = await findMany('regimens', { patientId }, { sort: { active: -1, started: -1 } });
  const result = [];
  for (const r of regimens) {
    let prescriberName = 'Self-added';
    if (r.prescriberId) {
      const p = await findOne('users', { id: r.prescriberId });
      if (p) prescriberName = p.name;
    }
    result.push(regimenDto({ ...r, prescriberName }));
  }
  return result;
}

export async function createRegimen(patientId, prescriberId, data) {
  const id = crypto.randomUUID();
  const now = new Date();
  const day = now.toISOString().slice(0, 10);
  const time = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
  const times = [...new Set(data.times)].sort();
  
  const regimen = {
    id,
    patientId,
    prescriberId,
    name: data.name,
    strength: data.strength || '',
    type: data.type,
    active: true,
    schedule: data.schedule || `${times.length} time${times.length === 1 ? '' : 's'} daily`,
    times,
    started: day,
    startTime: time,
    note: data.note || '',
    createdAt: now.toISOString(),
  };
  
  await insertOne('regimens', regimen);
  
  let prescriberName = 'Self-added';
  if (prescriberId) {
    const p = await findOne('users', { id: prescriberId });
    if (p) prescriberName = p.name;
  }
  return regimenDto({ ...regimen, prescriberName });
}

export async function updateRegimen(regimenId, patientId, data) {
  const regimen = await findOne('regimens', { id: regimenId, patientId });
  if (!regimen) throw new HttpError(404, 'Regimen not found');
  
  const updates = {};
  if (data.active !== undefined) updates.active = data.active;
  if (data.note !== undefined) updates.note = data.note;
  
  await updateOne('regimens', { id: regimenId }, { $set: updates });
  const updated = await findOne('regimens', { id: regimenId });
  
  let prescriberName = 'Self-added';
  if (updated.prescriberId) {
    const p = await findOne('users', { id: updated.prescriberId });
    if (p) prescriberName = p.name;
  }
  return regimenDto({ ...updated, prescriberName });
}

export async function getRegimenById(regimenId) {
  return findOne('regimens', { id: regimenId });
}
