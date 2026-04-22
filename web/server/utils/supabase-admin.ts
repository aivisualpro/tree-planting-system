import { serverSupabaseServiceRole } from '#supabase/server'
import type { Database } from '../../../shared/types/database'
import type { H3Event } from 'h3'

export const supabaseAdmin = (event: H3Event) => {
  return serverSupabaseServiceRole<Database>(event)
}
