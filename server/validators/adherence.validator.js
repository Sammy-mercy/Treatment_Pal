import { z } from 'zod';
import { parse } from './auth.validator.js';

export const logAdherenceSchema = z.object({
  regimenItemId: z.string().min(1, 'Regimen item ID is required'),
  status: z.enum(['taken', 'missed']),
  scheduledAt: z.string().optional(),
  notes: z.string().max(500).optional(),
});

export { parse };
