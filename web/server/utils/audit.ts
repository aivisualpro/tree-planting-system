import type { H3Event } from 'h3'
import type { Database } from '../../../shared/types/database'
import { serverSupabaseServiceRole, serverSupabaseUser } from '#supabase/server'

export async function logAdminAction(event: H3Event, action: string, details: any = {}) {
  const user = await serverSupabaseUser(event)
  if (!user)
    return

  const client = serverSupabaseServiceRole<Database>(event)

  await client.from('audit_log').insert({
    table_name: 'admin_actions',
    row_id: user.id, // Using user ID as a reference
    operation: 'INSERT',
    actor_id: user.id,
    new_row: { action, details },
    occurred_at: new Date().toISOString(),
  })
}
