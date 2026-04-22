import { useAuthStore } from '~/stores/auth'

export default defineNuxtRouteMiddleware(async (to) => {
  const user = useSupabaseUser()
  const authStore = useAuthStore()

  // The @nuxtjs/supabase module handles redirecting unauthenticated users to /login 
  // via its own injected middleware. This middleware ensures we load their profile.
  if (user.value && !authStore.profile) {
    await authStore.fetchProfile()
  }
})
