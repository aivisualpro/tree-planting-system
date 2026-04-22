import { serverSupabaseServiceRole } from '#supabase/server'
import type { Database } from '../../../../shared/types/database'

export default defineEventHandler(async (event) => {
  const client = serverSupabaseServiceRole<Database>(event)

  // Fetch all completed visits from the last 30 days
  const thirtyDaysAgo = new Date()
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)

  const { data, error } = await client
    .from('visits')
    .select('scheduled_date, total_trees_planted, attendance')
    .eq('status', 'completed')
    .gte('scheduled_date', thirtyDaysAgo.toISOString().split('T')[0])
    .order('scheduled_date', { ascending: true })

  if (error) {
    throw createError({ statusCode: 500, statusMessage: error.message })
  }

  // Group by date
  const timelineMap = new Map<string, { trees: number, attendance: number }>()

  data.forEach(visit => {
    if (!visit.scheduled_date) return
    
    const existing = timelineMap.get(visit.scheduled_date) || { trees: 0, attendance: 0 }
    timelineMap.set(visit.scheduled_date, {
      trees: existing.trees + Number(visit.total_trees_planted || 0),
      attendance: existing.attendance + Number(visit.attendance || 0)
    })
  })

  // Convert to array format for ECharts
  const timeline = Array.from(timelineMap.entries()).map(([date, metrics]) => ({
    date,
    ...metrics
  }))

  return timeline
})
