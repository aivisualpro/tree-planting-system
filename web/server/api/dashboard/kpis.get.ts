import { serverSupabaseServiceRole } from '#supabase/server'
import type { Database } from '../../../../shared/types/database'
import { z } from 'zod'

const dashboardQuerySchema = z.object({
  countryId: z.string().uuid().optional(),
  dateRange: z.string().optional()
})

export default defineEventHandler(async (event) => {
  const query = await getValidatedQuery(event, dashboardQuerySchema.parse)
  const client = serverSupabaseServiceRole<Database>(event)

  // Use the materialized view for high-performance KPI aggregation
  const { data, error } = await client
    .from('mv_country_kpis')
    .select('total_visits, total_trees, total_attendance')

  if (error) {
    throw createError({ statusCode: 500, statusMessage: error.message })
  }

  // Aggregate across all countries the user has access to
  // For the MVP dashboard, we'll sum up the global totals
  const aggregated = data.reduce(
    (acc, row) => ({
      visits: acc.visits + Number(row.total_visits || 0),
      trees: acc.trees + Number(row.total_trees || 0),
      attendance: acc.attendance + Number(row.total_attendance || 0),
    }),
    { visits: 0, trees: 0, attendance: 0 }
  )

  return aggregated
})
