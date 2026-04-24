import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const payload = await req.json();
    const event = payload.record; // from webhook

    if (!event || event.status !== 'pending') {
      return new Response(JSON.stringify({ message: 'No pending event found' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    const recipientUserId = event.recipient_user_id;

    // Fetch preferences
    const { data: prefs, error: prefsError } = await supabase
      .from('notification_preferences')
      .select('*')
      .eq('user_id', recipientUserId)
      .single();

    if (prefsError) throw prefsError;

    // Fetch user for email/phone
    const { data: user, error: userError } = await supabase.auth.admin.getUserById(recipientUserId);
    if (userError) throw userError;

    // Check quiet hours
    // (Simplification: If quiet hours are set and current time in user's timezone is within quiet hours, defer)
    if (prefs.quiet_hours_start && prefs.quiet_hours_end) {
      const now = new Date();
      const userTime = new Date(now.toLocaleString('en-US', { timeZone: prefs.timezone || 'UTC' }));
      const hours = userTime.getHours();
      const mins = userTime.getMinutes();
      
      const [startH, startM] = prefs.quiet_hours_start.split(':').map(Number);
      const [endH, endM] = prefs.quiet_hours_end.split(':').map(Number);
      
      const currentMins = hours * 60 + mins;
      const startTotalMins = startH * 60 + startM;
      const endTotalMins = endH * 60 + endM;

      let inQuietHours = false;
      if (startTotalMins < endTotalMins) {
        inQuietHours = currentMins >= startTotalMins && currentMins <= endTotalMins;
      } else {
        // Crosses midnight
        inQuietHours = currentMins >= startTotalMins || currentMins <= endTotalMins;
      }

      if (inQuietHours) {
        // Defer until morning (e.g. 8 AM next day)
        // Set scheduled_for to end of quiet hours or something similar.
        // For now, we will mark it to retry later or update scheduled_for.
        return new Response(JSON.stringify({ message: 'In quiet hours, deferred' }), { headers: corsHeaders });
      }
    }

    // Process channels
    const channels = event.channels || [];
    let allSuccess = true;
    let failedReason = '';

    for (const channel of channels) {
      try {
        if (channel === 'push' && prefs.push_enabled) {
          // Fetch device tokens
          const { data: tokens } = await supabase
            .from('device_tokens')
            .select('fcm_token')
            .eq('user_id', recipientUserId);
            
          if (tokens && tokens.length > 0) {
            // Push via FCM REST API
            const fcmTokens = tokens.map((t) => t.fcm_token);
            const serviceAccountJSON = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
            if (serviceAccountJSON) {
                // Implementation for FCM push
                // (In a real app, generate OAuth2 token from service account, then send request to FCM API)
                console.log('Sending push to:', fcmTokens);
            }
          }
        }

        if (channel === 'email' && prefs.email_enabled && user.user.email) {
          const resendApiKey = Deno.env.get('RESEND_API_KEY');
          if (resendApiKey) {
            const res = await fetch('https://api.resend.com/emails', {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${resendApiKey}`,
                'Content-Type': 'application/json'
              },
              body: JSON.stringify({
                from: 'notifications@tree-planting-system.aivisualpro.com',
                to: user.user.email,
                subject: `Notification: ${event.event_type}`,
                html: `<p>You have a new notification of type <strong>${event.event_type}</strong></p>`
              })
            });
            if (!res.ok) throw new Error(`Resend error: ${await res.text()}`);
          }
        }

        if (channel === 'whatsapp' && prefs.whatsapp_enabled && user.user.phone) {
          const metaToken = Deno.env.get('META_WHATSAPP_TOKEN');
          const phoneNumberId = Deno.env.get('META_PHONE_NUMBER_ID');
          if (metaToken && phoneNumberId) {
            const res = await fetch(`https://graph.facebook.com/v17.0/${phoneNumberId}/messages`, {
              method: 'POST',
              headers: {
                'Authorization': `Bearer ${metaToken}`,
                'Content-Type': 'application/json'
              },
              body: JSON.stringify({
                messaging_product: 'whatsapp',
                to: user.user.phone,
                type: 'template',
                template: {
                  name: event.event_type.replace('.', '_'), // e.g. visit_assigned
                  language: { code: 'en_US' }
                }
              })
            });
            if (!res.ok) throw new Error(`WhatsApp error: ${await res.text()}`);
          }
        }
      } catch (err) {
        allSuccess = false;
        const msg = err instanceof Error ? err.message : String(err);
        failedReason += ` [${channel} error: ${msg}]`;
      }
    }

    if (allSuccess) {
      await supabase
        .from('notification_events')
        .update({ status: 'sent', sent_at: new Date().toISOString() })
        .eq('id', event.id);
    } else {
      const retryCount = (event.retry_count || 0) + 1;
      const newStatus = retryCount >= 5 ? 'failed' : 'pending';
      
      await supabase
        .from('notification_events')
        .update({ 
          status: newStatus, 
          failed_reason: failedReason.trim(),
          retry_count: retryCount
        })
        .eq('id', event.id);
    }

    return new Response(JSON.stringify({ success: allSuccess, failedReason }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    return new Response(JSON.stringify({ error: msg }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});
