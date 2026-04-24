import type { Database } from '../../../../shared/types/database'
import { serverSupabaseServiceRole } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const client = serverSupabaseServiceRole<Database>(event)

  const { data, error } = await client
    .from('mv_top_species')
    .select('common_name_en, total_planted')
    .order('total_planted', { ascending: false })
    .limit(5)

  if (error) {
    throw createError({ statusCode: 500, statusMessage: error.message })
  }

  return data
})
