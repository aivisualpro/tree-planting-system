import type { Database } from '../../../shared/types/database'
import { useSupabaseClient, useSupabaseUser } from '#imports'

export function useSupabase() {
  const client = useSupabaseClient<Database>()
  const user = useSupabaseUser()

  return {
    client,
    user,
  }
}
