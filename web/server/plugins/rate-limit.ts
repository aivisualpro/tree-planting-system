import { defineNitroPlugin } from 'nitropack/runtime'
import { getCookie } from 'h3'

// In-memory store for rate limiting
const store = new Map<string, { count: number, resetAt: number }>()

export default defineNitroPlugin((nitroApp) => {
  nitroApp.hooks.hook('request', async (event) => {
    // Only apply rate limiting to API routes
    if (!event.path.startsWith('/api/')) return

    const ip = event.node.req.socket.remoteAddress || 'unknown-ip'
    
    // Naive check for authentication based on supabase token cookie presence
    // In a real app we'd verify the JWT, but checking for the cookie suffices for rate-limit tiers
    const sbAccessToken = getCookie(event, 'sb-access-token')
    
    const isAuth = !!sbAccessToken
    const limit = isAuth ? 100 : 20
    const windowMs = 60 * 1000 // 1 minute
    
    const key = isAuth ? `auth-${sbAccessToken}` : `ip-${ip}`
    const now = Date.now()
    
    let record = store.get(key)
    if (!record || record.resetAt < now) {
      record = { count: 0, resetAt: now + windowMs }
    }
    
    record.count += 1
    store.set(key, record)
    
    if (record.count > limit) {
      // Return 429 Too Many Requests
      throw createError({
        statusCode: 429,
        statusMessage: 'Too Many Requests',
        message: 'Rate limit exceeded'
      })
    }
  })
})
