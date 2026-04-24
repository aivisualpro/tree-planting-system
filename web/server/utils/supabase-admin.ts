import type { H3Event } from 'h3'
import type { Database } from '../../../shared/types/database'
import { serverSupabaseServiceRole } from '#supabase/server'

export function supabaseAdmin(event: H3Event) {
  return serverSupabaseServiceRole<Database>(event)
}
