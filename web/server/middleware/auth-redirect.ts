// Edge middleware for auth redirect (§11 – no cold start, runs at edge)
// Runs BEFORE serverless functions; keeps auth redirects fast.
// Deployed to the Edge runtime → no cold start latency.

import { defineEventHandler, sendRedirect, getCookie } from 'h3'

export default defineEventHandler(async (event) => {
  const url = event.node.req.url ?? '/'

  // Skip static assets, API routes, and public auth pages
  const PUBLIC_PATHS = ['/login', '/register', '/forgot-password', '/otp', '/confirm']
  const isPublic =
    PUBLIC_PATHS.some(p => url.startsWith(p)) ||
    url.startsWith('/_nuxt') ||
    url.startsWith('/api') ||
    url.startsWith('/fonts') ||
    url.startsWith('/favicon')

  if (isPublic) return

  // Lightweight cookie-only check – no DB round-trip
  const accessToken = getCookie(event, 'sb-access-token')

  if (!accessToken) {
    return sendRedirect(event, `/login?redirectTo=${encodeURIComponent(url)}`, 302)
  }
})
