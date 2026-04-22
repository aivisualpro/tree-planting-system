import { useRole } from '~/composables/useRole'

export default defineNuxtRouteMiddleware((to) => {
  const { hasRole } = useRole()
  
  const allowedRoles = to.meta.roles as string[] | undefined
  if (allowedRoles && !hasRole(allowedRoles)) {
    return navigateTo('/403')
  }
})
