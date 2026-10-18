import { findOne, findMany, updateOne } from '../config/db.js';
import { HttpError } from '../middleware/errorHandler.js';
import { adherenceFor } from './adherence.service.js';

function initials(name = '') {
  return name.replace(/^Dr\.?\s+/i, '').split(/\s+/).filter(Boolean).slice(0, 2).map(p => p[0].toUpperCase()).join('');
}

function ageFrom(dob) {
  const t = Date.parse(dob);
  if (Number.isNaN(t)) return null;
  return Math.floor((Date.now() - t) / (365.25 * 24 * 3600 * 1000));
}

export async function getUsers(role) {
  const users = await findMany('users', role ? { role } : {});
  return users.map(u => ({
    id: u.id,
    name: u.name,
    email: u.email,
    role: u.role,
    initials: initials(u.name),
    createdAt: u.createdAt,
  }));
}

export const getUsersByRole = getUsers;

export async function getUserById(userId) {
  const user = await findOne('users', { id: userId });
  if (!user) throw new HttpError(404, 'User not found');
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    initials: initials(user.name),
    phone: user.phone,
    dob: user.dob,
    createdAt: user.createdAt,
  };
}

export async function getClinicianPatients(clinicianId, now) {
  const profiles = await findMany('patient_profiles', { clinicianId });
  const patients = [];
  
  for (const p of profiles) {
    const user = await findOne('users', { id: p.userId });
    if (!user) continue;
    
    const { rate, missed } = await adherenceFor(user.id, now, 30);
    const regimens = await findMany('regimens', { patientId: user.id, active: true });
    const doseLogCol = (await import('../config/db.js')).getCollection('dose_logs');
    const lastLog = doseLogCol ? await doseLogCol.findOne({ patientId: user.id }, { sort: { createdAt: -1 } }) : null;
    
    patients.push({
      id: user.id,
      name: user.name,
      initials: initials(user.name),
      note: p.note || '',
      age: ageFrom(user.dob),
      since: user.createdAt,
      rate,
      missed,
      regimen: regimens.map(r => `${r.name} ${r.strength || ''}`.trim()).join(' · ') || 'No active regimen',
      lastLog: lastLog ? { day: lastLog.day, time: lastLog.loggedTime } : null,
    });
  }
  
  const rated = patients.filter(p => p.rate !== null);
  const summary = {
    total: patients.length,
    avgAdherence: rated.length ? Math.round(rated.reduce((a, p) => a + p.rate, 0) / rated.length) : null,
    needsAttention: rated.filter(p => p.rate < 80).length,
  };
  
  return { patients, summary };
}

export async function getPatientDetail(clinicianId, patientId, now) {
  const profile = await findOne('patient_profiles', { userId: patientId, clinicianId });
  if (!profile) throw new HttpError(404, 'Patient not found in your panel');
  
  const user = await findOne('users', { id: patientId });
  if (!user) throw new HttpError(404, 'Patient not found');
  
  const { rate } = await adherenceFor(patientId, now, 30);
  const regimens = await findMany('regimens', { patientId });
  const history = await findMany('history', { patientId }, { sort: { date: -1 } });
  
  let prescriberNames = {};
  for (const r of regimens) {
    if (r.prescriberId && !prescriberNames[r.prescriberId]) {
      const p = await findOne('users', { id: r.prescriberId });
      prescriberNames[r.prescriberId] = p?.name || 'Unknown';
    }
  }
  
  return {
    patient: {
      id: user.id,
      name: user.name,
      initials: initials(user.name),
      email: user.email,
      phone: user.phone,
      dob: user.dob,
      note: profile.note || '',
      age: ageFrom(user.dob),
      since: user.createdAt,
      rate,
    },
    regimens: regimens.map(r => ({
      id: r.id, name: r.name, strength: r.strength || '', type: r.type,
      active: r.active !== false, schedule: r.schedule || '',
      times: r.times || [], started: r.started || '',
      prescriber: prescriberNames[r.prescriberId] || 'Self-added',
      note: r.note || '',
    })),
    history: history.map(h => ({ id: h.id, date: h.date, title: h.title, detail: h.detail || '', place: h.place || '' })),
  };
}

export async function linkPatient(clinicianId, email) {
  const user = await findOne('users', { email: email.toLowerCase(), role: 'patient' });
  if (!user) throw new HttpError(404, 'No patient account found with that email');
  
  const profile = await findOne('patient_profiles', { userId: user.id });
  if (profile?.clinicianId && profile.clinicianId !== clinicianId) {
    throw new HttpError(409, 'That patient is already assigned to another clinician');
  }
  
  const { updateOne: dbUpdateOne } = await import('../config/db.js');
  await dbUpdateOne('patient_profiles', { userId: user.id }, { $set: { clinicianId } });
  return { ok: true, patientId: user.id };
}