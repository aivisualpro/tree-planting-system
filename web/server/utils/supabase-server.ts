import type { H3Event } from 'h3'
import type { Database } from '../../../shared/types/database'
import { serverSupabaseClient } from '#supabase/server'

export function supabaseServer(event: H3Event) {
  return serverSupabaseClient<Database>(event)
}
