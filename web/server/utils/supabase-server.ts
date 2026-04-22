import { serverSupabaseClient } from '#supabase/server'
import type { Database } from '../../../shared/types/database'
import type { H3Event } from 'h3'

export const supabaseServer = (event: H3Event) => {
  return serverSupabaseClient<Database>(event)
}
