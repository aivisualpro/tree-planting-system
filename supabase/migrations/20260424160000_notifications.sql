-- Migration: 20260424160000_notifications.sql
-- Description: Sets up the notification system including events, preferences, and device tokens.

-- Create enums
CREATE TYPE notification_event_type AS ENUM (
    'visit.assigned',
    'visit.submitted',
    'visit.approved',
    'visit.rejected',
    'sync.failed_permanent',
    'user.invited',
    'password.reset',
    'weekly.country_summary',
    'emergency.broadcast'
);

CREATE TYPE notification_status AS ENUM (
    'pending',
    'processing',
    'sent',
    'failed'
);

CREATE TYPE device_platform AS ENUM (
    'android',
    'ios',
    'web'
);

-- Table: notification_preferences
CREATE TABLE IF NOT EXISTS public.notification_preferences (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    push_enabled BOOLEAN NOT NULL DEFAULT true,
    email_enabled BOOLEAN NOT NULL DEFAULT true,
    whatsapp_enabled BOOLEAN NOT NULL DEFAULT false,
    quiet_hours_start TIME WITHOUT TIME ZONE,
    quiet_hours_end TIME WITHOUT TIME ZONE,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: device_tokens
CREATE TABLE IF NOT EXISTS public.device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    platform device_platform NOT NULL,
    fcm_token TEXT NOT NULL,
    installed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    UNIQUE(user_id, fcm_token)
);

-- Table: notification_events
CREATE TABLE IF NOT EXISTS public.notification_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type notification_event_type NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    recipient_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    channels TEXT[] NOT NULL DEFAULT ARRAY['push']::TEXT[],
    status notification_status NOT NULL DEFAULT 'pending',
    scheduled_for TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    sent_at TIMESTAMPTZ,
    failed_reason TEXT,
    retry_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS: notification_preferences
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notification preferences"
    ON public.notification_preferences FOR SELECT
    USING (auth.uid() = user_id OR (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'super_admin'));

CREATE POLICY "Users can update their own notification preferences"
    ON public.notification_preferences FOR UPDATE
    USING (auth.uid() = user_id OR (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'super_admin'));

CREATE POLICY "Users can insert their own notification preferences"
    ON public.notification_preferences FOR INSERT
    WITH CHECK (auth.uid() = user_id OR (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'super_admin'));

-- RLS: device_tokens
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own device tokens"
    ON public.device_tokens FOR ALL
    USING (auth.uid() = user_id);

-- RLS: notification_events
ALTER TABLE public.notification_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notification events"
    ON public.notification_events FOR SELECT
    USING (auth.uid() = recipient_user_id OR (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('admin', 'super_admin'));

-- Webhook Trigger: Trigger edge function on notification_events INSERT
-- Note: Requires `pg_net` extension. We can use a trigger to make an http request, or use Supabase Database Webhooks.
-- Usually Supabase Database Webhooks are configured via the dashboard, but if we want to script it:
-- CREATE TRIGGER ...

-- Automatic preference creation on user creation
CREATE OR REPLACE FUNCTION public.handle_new_user_notification_preferences()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.notification_preferences (user_id)
    VALUES (new.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created_preferences
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_notification_preferences();

-- Triggers for notification_events
CREATE OR REPLACE FUNCTION public.enqueue_notification_event()
RETURNS TRIGGER AS $$
DECLARE
    coordinator_id UUID;
BEGIN
    -- visit.completed
    IF TG_TABLE_NAME = 'visits' AND TG_OP = 'INSERT' AND NEW.status = 'completed' THEN
        -- Find coordinator for the country
        SELECT id INTO coordinator_id
        FROM public.profiles
        WHERE NEW.country_id = ANY(assigned_countries) AND role = 'coordinator'
        LIMIT 1;
        
        IF coordinator_id IS NOT NULL THEN
            INSERT INTO public.notification_events (event_type, payload, recipient_user_id, channels)
            VALUES ('visit.submitted', jsonb_build_object('visit_id', NEW.id, 'country_id', NEW.country_id), coordinator_id, ARRAY['push']);
        END IF;
    END IF;
    
    -- visit.approved / visit.rejected
    IF TG_TABLE_NAME = 'visits' AND TG_OP = 'UPDATE' AND OLD.status != NEW.status AND NEW.status IN ('approved', 'rejected') THEN
        INSERT INTO public.notification_events (event_type, payload, recipient_user_id, channels)
        VALUES (
            CASE WHEN NEW.status = 'approved' THEN 'visit.approved'::notification_event_type ELSE 'visit.rejected'::notification_event_type END,
            jsonb_build_object('visit_id', NEW.id),
            NEW.created_by,
            ARRAY['push']
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on visits table
CREATE TRIGGER on_visit_status_changed_notification
    AFTER INSERT OR UPDATE OF status ON public.visits
    FOR EACH ROW EXECUTE FUNCTION public.enqueue_notification_event();

-- Trigger for auth.users INSERT (Welcome email)
CREATE OR REPLACE FUNCTION public.enqueue_welcome_email()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.notification_events (event_type, payload, recipient_user_id, channels)
    VALUES ('user.invited', jsonb_build_object('email', NEW.email), NEW.id, ARRAY['email']);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created_welcome_email
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.enqueue_welcome_email();


-- Enable pg_cron if not exists (Requires superuser/extensions support on Supabase)
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;

-- Function to queue weekly summary events
CREATE OR REPLACE FUNCTION public.enqueue_weekly_summaries()
RETURNS void AS $$
BEGIN
    INSERT INTO public.notification_events (event_type, payload, recipient_user_id, channels)
    SELECT 'weekly.country_summary'::notification_event_type, jsonb_build_object('week', extract(week from current_date)), id, ARRAY['email', 'whatsapp']
    FROM public.profiles
    WHERE role IN ('admin', 'super_admin');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Schedule the cron job for Monday 8am UTC
-- SELECT cron.schedule('weekly_country_summary', '0 8 * * 1', 'SELECT public.enqueue_weekly_summaries()');
