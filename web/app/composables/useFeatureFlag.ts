import { onMounted, ref } from 'vue'

export function useFeatureFlag() {
  const supabase = useSupabaseClient()
  const flags = useState<Record<string, boolean>>('featureFlags', () => ({}))
  const isLoaded = useState<boolean>('featureFlagsLoaded', () => false)

  const loadFlags = async () => {
    if (isLoaded.value)
      return

    try {
      const { data, error } = await supabase.rpc('get_feature_flags_for_user')
      if (error) {
        console.error('Failed to load feature flags', error)
        return
      }

      if (data) {
        flags.value = data as Record<string, boolean>
      }
    }
    catch (err) {
      console.error('Error loading feature flags:', err)
    }
    finally {
      isLoaded.value = true
    }
  }

  const isEnabled = (key: string): boolean => {
    return !!flags.value[key]
  }

  // Load flags immediately if not running on server
  if (import.meta.client) {
    onMounted(() => {
      loadFlags()
    })
  }
  else {
    // on server
    loadFlags()
  }

  return {
    flags,
    isEnabled,
    loadFlags,
    isLoaded,
  }
}
