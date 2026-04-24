import type { Database } from '../../../shared/types/database'
import { defineStore } from 'pinia'

type Profile = Database['public']['Tables']['profiles']['Row']

export const useAuthStore = defineStore('auth', () => {
  const profile = ref<Profile | null>(null)
  const supabase = useSupabaseClient<Database>()
  const user = useSupabaseUser()

  async function fetchProfile() {
    if (!user.value)
      return
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.value.id)
      .single()

    if (!error && data) {
      profile.value = data
    }
  }

  function clearProfile() {
    profile.value = null
  }

  return { profile, fetchProfile, clearProfile }
})
