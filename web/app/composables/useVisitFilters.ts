// Composable for filter-heavy pages:
// - Debounced filter changes (§9 – 300ms)
// - Pinia cache with staleTime (§9)
// - useAsyncData with server-side SSR (§9)

import { useDebounceFn } from '@vueuse/core'
import { useAsyncData } from 'nuxt/app'
import { computed, ref, watch } from 'vue'

export interface VisitFilters {
  countryId?: string
  status?: string
  dateFrom?: string
  dateTo?: string
  page: number
  limit: number
}

export interface CachedEntry<T> {
  data: T
  fetchedAt: number
}

// Module-level Pinia-like cache (staleTime: 30 s)
const _cache = new Map<string, CachedEntry<unknown>>()
const STALE_MS = 30_000

function cacheKey(filters: VisitFilters): string {
  return JSON.stringify(filters)
}

function isFresh(entry: CachedEntry<unknown>): boolean {
  return Date.now() - entry.fetchedAt < STALE_MS
}

export function useVisitFilters(initialFilters: Partial<VisitFilters> = {}) {
  const filters = ref<VisitFilters>({
    page: 1,
    limit: 25,
    ...initialFilters,
  })

  // §9 – debounce filter changes 300 ms
  const debouncedFetch = useDebounceFn(() => {
    refresh()
  }, 300)

  watch(filters, debouncedFetch, { deep: true })

  const { data, pending, error, refresh } = useAsyncData(
    `visits-${cacheKey(filters.value)}`,
    async () => {
      const key = cacheKey(filters.value)

      // §9 – serve stale data immediately while revalidating
      const cached = _cache.get(key)
      if (cached && isFresh(cached)) {
        return cached.data
      }

      const params = new URLSearchParams()
      if (filters.value.countryId)
        params.set('countryId', filters.value.countryId)
      if (filters.value.status)
        params.set('status', filters.value.status)
      if (filters.value.dateFrom)
        params.set('dateFrom', filters.value.dateFrom)
      if (filters.value.dateTo)
        params.set('dateTo', filters.value.dateTo)
      params.set('page', String(filters.value.page))
      params.set('limit', String(filters.value.limit))

      const result = await $fetch(`/api/visits?${params.toString()}`)

      _cache.set(key, { data: result, fetchedAt: Date.now() })
      return result
    },
    {
      server: true, // §9 – SSR on first load
      lazy: false,
    },
  )

  function setFilter(patch: Partial<VisitFilters>) {
    filters.value = { ...filters.value, ...patch, page: 1 }
  }

  function nextPage() {
    filters.value = { ...filters.value, page: filters.value.page + 1 }
  }

  function prevPage() {
    if (filters.value.page > 1) {
      filters.value = { ...filters.value, page: filters.value.page - 1 }
    }
  }

  function clearCache() {
    _cache.clear()
  }

  return {
    filters,
    data,
    pending,
    error,
    refresh,
    setFilter,
    nextPage,
    prevPage,
    clearCache,
  }
}
