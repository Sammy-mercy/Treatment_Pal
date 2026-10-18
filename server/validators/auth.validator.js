import { z } from 'zod';

const email = z.string().trim().toLowerCase().email('Enter a valid email address');

export const loginSchema = z.object({
  email: z.string().email('Enter a valid email address'),
  password: z.string().min(1, 'Enter your password'),
  role: z.enum(['patient', 'clinician', 'admin']).optional(),
});

export const registerSchema = z.discriminatedUnion('role', [
  z.object({
    role: z.literal('patient'),
    name: z.string().trim().min(2, 'Enter your full name').max(100),
    email: email.optional(), 
    password: z.string().min(8, 'Password must be at least 8 characters').max(128).optional().default(''),
    phone: z.string().trim().max(40).optional().default(''),
    clinicianEmail: email.optional(),
  }),
  z.object({
    role: z.literal('clinician'),
    name: z.string().trim().min(2, 'Enter your full name').max(100),
    email: email.optional(),
    password: z.string().min(8, 'Password must be at least 8 characters').max(128).optional().default(''),
    npi: z.string().trim().regex(/^\d{10}$/, 'NPI must be 10 digits').optional().default('0000000000'),
    specialization: z.string().trim().min(2).max(100).optional().default('General Practice'),
    license: z.string().trim().max(60).optional().default(''),
  }),
]);

export const updateProfileSchema = z.object({
  name: z.string().trim().min(2).max(100).optional(),
  email: email.optional(),
  phone: z.string().trim().max(40).optional(),
});

export const prefsSchema = z.object({
  doseReminders: z.boolean().optional(),
  missedDose: z.boolean().optional(),
  clinicianMessages: z.boolean().optional(),
  weeklySummary: z.boolean().optional(),
});

export function parse(schema, data) {
  const res = schema.safeParse(data);
  if (!res.success) {
    const err = new Error(res.error.issues[0].message);
    err.status = 400;
    throw err;
  }
  return res.data;
}
