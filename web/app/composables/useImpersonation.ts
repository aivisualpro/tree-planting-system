import { useSupabaseClient, useSupabaseUser, useCookie } from '#imports'
import { ref, computed } from 'vue'

export const useImpersonation = () => {
  const client = useSupabaseClient()
  const user = useSupabaseUser()
  const isImpersonating = useCookie('is_impersonating', { default: () => false })
  const impersonatedUserName = useCookie('impersonated_user_name', { default: () => '' })

  async function startImpersonation(targetUserId: string, targetUserName: string) {
    try {
      const { data: currentSession } = await client.auth.getSession()
      if (currentSession?.session) {
        // Save current session to localStorage
        localStorage.setItem('original_session', JSON.stringify(currentSession.session))
      }

      const { data, error } = await client.functions.invoke('start_impersonation', {
        body: { target_user_id: targetUserId }
      })

      if (error) throw error

      if (data?.token) {
        // We set the session with the custom token
        await client.auth.setSession({
          access_token: data.token,
          refresh_token: '' // short-lived token
        })

        isImpersonating.value = true
        impersonatedUserName.value = targetUserName
        
        // Reload to apply new session globally
        window.location.href = '/'
      }
    } catch (e: any) {
      console.error('Impersonation failed:', e)
      throw e
    }
  }

  async function exitImpersonation() {
    try {
      const originalSessionStr = localStorage.getItem('original_session')
      if (originalSessionStr) {
        const originalSession = JSON.parse(originalSessionStr)
        await client.auth.setSession({
          access_token: originalSession.access_token,
          refresh_token: originalSession.refresh_token
        })
        localStorage.removeItem('original_session')
      } else {
        await client.auth.signOut()
      }
    } catch (e) {
      console.error('Failed to restore session:', e)
    } finally {
      isImpersonating.value = false
      impersonatedUserName.value = ''
      window.location.href = '/'
    }
  }

  return {
    isImpersonating,
    impersonatedUserName,
    startImpersonation,
    exitImpersonation
  }
}
