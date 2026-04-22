import { useSupabaseClient, useSupabaseUser } from '#imports'
import type { Database } from '../../../shared/types/database'

export const useSupabase = () => {
  const client = useSupabaseClient<Database>()
  const user = useSupabaseUser()
  
  return {
    client,
    user
  }
}
