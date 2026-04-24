import { z } from 'zod'
import { serverSupabaseServiceRole } from '#supabase/server'
import { requireRole } from '../../utils/require-role'
import { logAdminAction } from '../../utils/audit'


const inviteSchema = z.object({
  email: z.string().email(),
  role: z.enum(['field_agent', 'admin', 'super_admin'])
})

export default defineEventHandler(async (event) => {
  // Only admins can invite users
  await requireRole(event, ['admin', 'super_admin'])
  
  const body = await readValidatedBody(event, inviteSchema.parse)
  const client = serverSupabaseServiceRole(event)

  await logAdminAction(event, 'invite_user', { email: body.email, role: body.role })

  // In a real implementation, we would use client.auth.admin.inviteUserByEmail()
  // and insert a row into our custom `users` table.
  // For the scaffold, we just insert into our public users table to simulate.
  const { data, error } = await (client as any).from('profiles')
    .insert({
      email: body.email,
      role: body.role,
      name: ''
    })
    .select()
    .single()

  if (error) {
    throw createError({ statusCode: 400, statusMessage: error.message })
  }

  return { success: true, user: data }
})
