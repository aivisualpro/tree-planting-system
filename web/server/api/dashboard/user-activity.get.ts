import { serverSupabaseServiceRole } from '#supabase/server'
import type { Database } from '../../../../shared/types/database'

export default defineEventHandler(async (event) => {
  const client = serverSupabaseServiceRole<Database>(event)

  const { data, error } = await client
    .from('mv_user_activity')
    .select('user_id, visits_created, trees_planted_by_user')
    .order('trees_planted_by_user', { ascending: false })
    .limit(5)

  if (error) {
    throw createError({ statusCode: 500, statusMessage: error.message })
  }

  // Fetch user profiles to get their names or roles
  // In a real app we might join auth.users to get emails, 
  // but since we only have access to profiles directly here, we'll fetch profiles.
  const { data: profiles } = await client
    .from('profiles')
    .select('id, role')
    .in('id', data.map(r => r.user_id || '').filter(Boolean))
    
  const profileMap = new Map(profiles?.map(p => [p.id, p.role]) || [])

  const enriched = data.map(row => ({
    user_id: row.user_id,
    role: profileMap.get(row.user_id || '') || 'Unknown',
    visits: row.visits_created,
    trees: row.trees_planted_by_user
  }))

  return enriched
})
