import { z } from 'zod';
import { parse } from './auth.validator.js';

const timeStr = z.string().regex(/^\d{2}:\d{2}$/, 'Invalid time format (HH:mm)');

export const createRegimenSchema = z.object({
  name: z.string().trim().min(2, 'Enter a name').max(80),
  strength: z.string().trim().max(60).optional().default(''),
  type: z.enum(['medication', 'therapy']),
  schedule: z.string().trim().max(120).optional().default(''),
  times: z.array(timeStr).min(1, 'Add at least one time').max(8),
  note: z.string().trim().max(400).optional().default(''),
  patientId: z.string().optional(),
});

export const updateRegimenSchema = z.object({
  active: z.boolean().optional(),
  note: z.string().trim().max(400).optional(),
});

export const logDoseSchema = z.object({
  regimenId: z.string().min(1),
  slot: timeStr.optional(),
});

export { parse };
