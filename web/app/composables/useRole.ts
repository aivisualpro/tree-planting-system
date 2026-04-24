import { useAuthStore } from '~/stores/auth'

export function useRole() {
  const authStore = useAuthStore()

  const isSuperAdmin = computed(() => authStore.profile?.role === 'super_admin')
  const isAdmin = computed(() => ['super_admin', 'admin'].includes(authStore.profile?.role || ''))
  const isCoordinator = computed(() => ['super_admin', 'admin', 'coordinator'].includes(authStore.profile?.role || ''))

  function hasRole(allowedRoles: string[]) {
    if (!authStore.profile)
      return false
    return allowedRoles.includes(authStore.profile.role)
  }

  function hasCountryAccess(countryId: string) {
    if (isSuperAdmin.value)
      return true
    return authStore.profile?.assigned_countries?.includes(countryId) ?? false
  }

  return { isSuperAdmin, isAdmin, isCoordinator, hasRole, hasCountryAccess }
}
