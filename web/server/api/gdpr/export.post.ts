import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'
import JSZip from 'jszip'

export default defineEventHandler(async (event) => {
  const user = await serverSupabaseUser(event)
  if (!user)
    throw createError({ statusCode: 401 })

  const client = await serverSupabaseClient<any>(event)

  // 1. Rate limit check (Section D.12)
  const { data: profile } = await client.from('profiles').select('last_export_at').eq('id', user.id).single()
  if (profile?.last_export_at && (Date.now() - new Date(profile.last_export_at).getTime()) < 24 * 60 * 60 * 1000) {
    throw createError({ statusCode: 429, statusMessage: 'One export per day allowed' })
  }

  // Update last_export_at
  await client.from('profiles').update({ last_export_at: new Date().toISOString() }).eq('id', user.id)

  // 2. Collect user data (Section D.11)
  const [
    { data: profileData },
    { data: visits },
    { data: auditLogs },
  ] = await Promise.all([
    client.from('profiles').select('*').eq('id', user.id).single(),
    client.from('visits').select('*, visit_media(*)').eq('created_by', user.id),
    client.from('audit_log').select('*').eq('actor_id', user.id),
  ])

  const zip = new JSZip()

  // Add JSON files
  zip.file('profile.json', JSON.stringify({ ...profileData, email: user.email }, null, 2))
  zip.file('visits.json', JSON.stringify(visits, null, 2))
  zip.file('audit_log_self.json', JSON.stringify(auditLogs, null, 2))

  // Scaffolding visit media folder (Section D.11.3)
  const mediaFolder = zip.folder('visit_media')
  if (visits) {
    for (const visit of visits) {
      if (visit.visit_media) {
        for (const media of visit.visit_media) {
          // Note: In a production environment, we'd stream these from S3/Storage
          // Adding a placeholder file to indicate where the media would be
          mediaFolder?.file(`${media.id}_${media.storage_path.split('/').pop()}`, `Metadata: ${JSON.stringify(media)}`)
        }
      }
    }
  }

  const content = await zip.generateAsync({ type: 'nodebuffer' })

  setResponseHeader(event, 'Content-Type', 'application/zip')
  setResponseHeader(event, 'Content-Disposition', `attachment; filename="my-data-export-${new Date().toISOString().split('T')[0]}.zip"`)

  return content
})
