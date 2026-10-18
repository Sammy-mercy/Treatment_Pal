import { findMany, findOne, insertOne } from '../config/db.js';
import crypto from 'crypto';
import { HttpError } from '../middleware/errorHandler.js';

function addDays(dayStr, n) {
  const d = new Date(dayStr + 'T00:00:00Z');
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
}

function daysBetween(from, to) {
  const days = [];
  let d = from;
  while (d <= to) {
    days.push(d);
    d = addDays(d, 1);
  }
  return days;
}

export async function buildSlots(patientId, fromDay, toDay, now) {
  const regimens = await findMany('regimens', { patientId, active: true });
  const logs = await findMany('dose_logs', {
    patientId,
    day: { $gte: fromDay, $lte: toDay },
  });
  
  const logMap = new Map();
  for (const l of logs) {
    logMap.set(`${l.regimenId}|${l.day}|${l.slot}`, l);
  }
  
  const slots = [];
  const days = daysBetween(fromDay, toDay);
  
  for (const reg of regimens) {
    if (!reg.times || reg.times.length === 0) continue;
    const started = reg.started || reg.createdAt?.slice(0, 10) || fromDay;
    
    for (const day of days) {
      if (day < started) continue;
      
      for (const slot of reg.times) {
        // On start day, skip slots before start time
        if (day === started && reg.startTime && slot < reg.startTime) continue;
        
        const key = `${reg.id}|${day}|${slot}`;
        const log = logMap.get(key);
        
        let status;
        if (log) {
          status = 'taken';
        } else if (day < now.day || (day === now.day && slot < now.time)) {
          status = 'missed';
        } else if (day === now.day) {
          status = 'due';
        } else {
          status = 'upcoming';
        }
        
        slots.push({
          regimenId: reg.id,
          label: `${reg.name} ${reg.strength || ''}`.trim(),
          type: reg.type,
          day,
          slot,
          status,
          loggedTime: log?.loggedTime || null,
        });
      }
    }
  }
  
  return slots.sort((a, b) => (a.day + a.slot).localeCompare(b.day + b.slot));
}

export function summarize(slots) {
  const taken = slots.filter(s => s.status === 'taken').length;
  const missed = slots.filter(s => s.status === 'missed').length;
  const scheduled = taken + missed;
  const rate = scheduled > 0 ? Math.round((taken / scheduled) * 100) : null;
  return { taken, missed, scheduled, rate };
}

export async function adherenceFor(patientId, now, daysBack = 30) {
  const fromDay = addDays(now.day, -(daysBack - 1));
  const slots = await buildSlots(patientId, fromDay, now.day, now);
  return { slots, ...summarize(slots) };
}

export function streakDays(slots, today) {
  const byDay = new Map();
  for (const s of slots) {
    if (s.status === 'taken' || s.status === 'missed') {
      if (!byDay.has(s.day)) byDay.set(s.day, { taken: 0, missed: 0 });
      const d = byDay.get(s.day);
      if (s.status === 'taken') d.taken++;
      else d.missed++;
    }
  }
  
  let streak = 0;
  let day = today;
  while (true) {
    const d = byDay.get(day);
    if (!d || d.missed > 0) break;
    if (d.taken > 0) streak++;
    day = addDays(day, -1);
  }
  return streak;
}

export function weeklyTrend(slots, weeks, today) {
  const result = [];
  for (let w = weeks - 1; w >= 0; w--) {
    const end = addDays(today, -w * 7);
    const start = addDays(end, -6);
    const weekSlots = slots.filter(s => s.day >= start && s.day <= end);
    result.push(summarize(weekSlots).rate);
  }
  return result;
}

export function missedByPeriod(slots) {
  const periods = [
    { label: 'Morning (6am–12pm)', range: ['06:00', '12:00'], missed: 0 },
    { label: 'Afternoon (12pm–5pm)', range: ['12:00', '17:00'], missed: 0 },
    { label: 'Evening (5pm–9pm)', range: ['17:00', '21:00'], missed: 0 },
    { label: 'Night (9pm–6am)', range: ['21:00', '06:00'], missed: 0 },
  ];
  
  for (const s of slots) {
    if (s.status !== 'missed') continue;
    const time = s.slot;
    if (time >= '06:00' && time < '12:00') periods[0].missed++;
    else if (time >= '12:00' && time < '17:00') periods[1].missed++;
    else if (time >= '17:00' && time < '21:00') periods[2].missed++;
    else periods[3].missed++;
  }
  
  return periods;
}

export async function logDose(patientId, regimenId, slot, now) {
  const reg = await findOne('regimens', { id: regimenId, patientId, active: true });
  if (!reg) throw new HttpError(404, 'Regimen not found or paused');
  
  const todaySlots = await buildSlots(patientId, now.day, now.day, now);
  const regimenSlots = todaySlots.filter(s => s.regimenId === regimenId);
  
  if (slot) {
    if (!regimenSlots.some(s => s.slot === slot)) {
      throw new HttpError(400, 'That time is not on this regimen for today');
    }
  } else {
    const open = regimenSlots.filter(s => s.status !== 'taken');
    const pick = open.find(s => s.status === 'due') || open.find(s => s.status === 'missed') || open[0];
    if (!pick) throw new HttpError(409, "All of today's doses for this item are already logged");
    slot = pick.slot;
  }
  
  // Check for duplicate
  const existing = await findOne('dose_logs', { regimenId, day: now.day, slot });
  if (existing) throw new HttpError(409, 'That dose is already logged');
  
  await insertOne('dose_logs', {
    id: crypto.randomUUID(),
    patientId,
    regimenId,
    day: now.day,
    slot,
    loggedTime: now.time,
    createdAt: new Date().toISOString(),
  });
  
  return { ok: true, slot, loggedTime: now.time };
}

export { addDays };
