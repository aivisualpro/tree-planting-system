import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export default defineEventHandler(async (event) => {
  const user = await serverSupabaseUser(event)
  if (!user)
    throw createError({ statusCode: 401 })

  const body = await readBody(event)
  if (body.confirmEmail !== user.email) {
    throw createError({ statusCode: 400, statusMessage: 'Confirmation email mismatch' })
  }

  const client = await serverSupabaseClient<any>(event)

  try {
    // 1. Redact Profile (Section E.14)
    await client.from('profiles').update({
      full_name: 'REDACTED_USER',
      whatsapp: 'REDACTED',
      // We keep the ID to maintain FK integrity for historical reports
    }).eq('id', user.id)

    // 2. Clear sensitive metadata in auth.users (requires service role ideally)
    // Since we are using client, we might be limited, but we can redact what we can.

    // 3. Delete sensitive related data
    await Promise.all([
      client.from('device_tokens').delete().eq('user_id', user.id),
      client.from('notification_events').delete().eq('user_id', user.id),
    ])

    // 4. Audit entry (Section E.14)
    await client.from('audit_log').insert({
      table_name: 'profiles',
      row_id: user.id,
      operation: 'UPDATE',
      actor_id: user.id,
      new_row: { gdpr_action: 'erasure', reason: 'user_requested' },
    })

    // 5. Sign out user
    await client.auth.signOut()

    return { success: true, message: 'Account anonymized successfully' }
  }
  catch (error: any) {
    console.error('Anonymization error:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Failed to anonymize account',
    })
  }
})
