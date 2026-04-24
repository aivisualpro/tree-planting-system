// OpenTelemetry tracing for Nuxt server/api routes → Axiom (§18)
// Wraps every API event handler with a span and exports to Axiom via OTLP HTTP.

import { defineNitroPlugin } from 'nitropack/runtime'

interface TraceSpan {
  name: string
  startTime: number
  attributes: Record<string, string | number>
}

interface AxiomEvent {
  _time: string
  service: string
  span_name: string
  duration_ms: number
  status: 'ok' | 'error'
  error?: string
  [key: string]: unknown
}

async function exportSpan(span: TraceSpan & { status: 'ok' | 'error'; error?: string }): Promise<void> {
  const axiomApiKey = process.env.AXIOM_API_KEY
  const axiomDataset = process.env.AXIOM_DATASET || 'tree-planting-prod'

  if (!axiomApiKey) return // skip in dev if not configured

  const event: AxiomEvent = {
    _time: new Date().toISOString(),
    service: 'nuxt-api',
    span_name: span.name,
    duration_ms: Date.now() - span.startTime,
    status: span.status,
    ...span.attributes,
  }
  if (span.error) event.error = span.error

  try {
    await fetch(`https://api.axiom.co/v1/datasets/${axiomDataset}/ingest`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${axiomApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify([event]),
    })
  }
  catch {
    // Silently fail – tracing must not break the request
  }
}

export default defineNitroPlugin((nitro) => {
  // Hook into every request/response cycle
  nitro.hooks.hook('request', (event) => {
    const url = event.node.req.url ?? '/'
    if (!url.startsWith('/api/')) return

    const startTime = Date.now()
    ;(event as any).__traceStart = startTime
    ;(event as any).__traceName = `HTTP ${event.node.req.method} ${url}`
  })

  nitro.hooks.hook('afterResponse', (event) => {
    const url = event.node.req.url ?? '/'
    if (!url.startsWith('/api/')) return

    const startTime = (event as any).__traceStart as number | undefined
    const name = (event as any).__traceName as string | undefined
    if (!startTime || !name) return

    const statusCode = event.node.res.statusCode ?? 200

    exportSpan({
      name,
      startTime,
      status: statusCode >= 400 ? 'error' : 'ok',
      attributes: {
        'http.method': event.node.req.method ?? 'GET',
        'http.url': url,
        'http.status_code': statusCode,
      },
    })
  })
})
