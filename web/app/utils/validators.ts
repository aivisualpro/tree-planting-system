import { z } from 'zod'

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
})

export const countrySchema = z.object({
  name: z.string().min(2),
  code: z.string().length(2),
  isActive: z.boolean().default(true),
})

export const userInviteSchema = z.object({
  email: z.string().email(),
  role: z.enum(['super_admin', 'admin', 'manager', 'user']),
  countryId: z.string().uuid().optional(),
})
