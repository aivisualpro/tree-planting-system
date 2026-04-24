# Server Module (`web/server/`)

This directory contains the Nitro API server for Nuxt.
- **api/**: API routes running securely in the Node backend. Uses Supabase Service Role for complex queries bypassing RLS.
- **plugins/**: Server middleware (rate limiting).
- **utils/**: Server-only helper functions.
