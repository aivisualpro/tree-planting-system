import type { Database } from '../../../../shared/types/database'
import { serverSupabaseServiceRole } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const client = serverSupabaseServiceRole<Database>(event)

  // Query the materialized view
  const { data, error } = await client
    .from('mv_country_kpis')
    .select('country_id, total_visits, total_trees, total_attendance')

  if (error) {
    throw createError({ statusCode: 500, statusMessage: error.message })
  }

  // We need country names, so let's fetch those too
  const { data: countries } = await client
    .from('countries')
    .select('id, name_en')

  const countryMap = new Map(countries?.map(c => [c.id, c.name_en]) || [])

  const breakdown = data.map(row => ({
    country_name: countryMap.get(row.country_id || '') || 'Unknown',
    visits: row.total_visits,
    trees: row.total_trees,
    attendance: row.total_attendance,
  }))

  return breakdown
})
