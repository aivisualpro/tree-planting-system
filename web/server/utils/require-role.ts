import type { H3Event } from 'h3'
import type { Database } from '../../../shared/types/database'
import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export async function requireRole(event: H3Event, allowedRoles: string[]) {
  const user = await serverSupabaseUser(event)
  if (!user) {
    throw createError({ statusCode: 401, message: 'Unauthorized' })
  }

  const client = await serverSupabaseClient<Database>(event)
  const { data: profile, error } = await (client as any).from('users').select('role').eq('id', user.id).single()

  if (error || !profile || !allowedRoles.includes(profile.role)) {
    throw createError({ statusCode: 403, message: 'Forbidden' })
  }

  return user
}
