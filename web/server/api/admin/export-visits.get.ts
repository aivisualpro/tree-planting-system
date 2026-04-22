import { serverSupabaseServiceRole } from '#supabase/server'
import { requireRole } from '../../utils/require-role'

export default defineEventHandler(async (event) => {
  await requireRole(event, ['admin', 'super_admin'])
  const client = serverSupabaseServiceRole(event)

  // Fetch visits
  const { data, error } = await client
    .from('visits')
    .select('id, trees_planted, status, created_at, country:countries(name)')
    .order('created_at', { ascending: false })

  if (error) {
    throw createError({ statusCode: 500, message: 'Export failed' })
  }

  // Set CSV headers
  setHeader(event, 'Content-Type', 'text/csv')
  setHeader(event, 'Content-Disposition', 'attachment; filename="visits_export.csv"')

  // Generate basic CSV
  let csv = 'ID,Date,Country,Trees Planted,Status\n'
  data?.forEach((v: any) => {
    csv += `${v.id},${v.created_at},${v.country?.name || ''},${v.trees_planted},${v.status}\n`
  })

  return csv
})
