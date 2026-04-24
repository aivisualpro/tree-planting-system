-- Migration: create_feedback_reports_table

CREATE TABLE IF NOT EXISTS public.feedback_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    device_info JSONB NOT NULL DEFAULT '{}'::jsonb,
    comment TEXT NOT NULL,
    screenshot_url TEXT,
    app_version TEXT,
    status TEXT DEFAULT 'new' CHECK (status IN ('new', 'investigating', 'resolved', 'closed')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE public.feedback_reports ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can insert their own feedback" ON public.feedback_reports
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own feedback" ON public.feedback_reports
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all feedback" ON public.feedback_reports
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role IN ('admin', 'super_admin')
        )
    );

CREATE POLICY "Admins can update feedback status" ON public.feedback_reports
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role IN ('admin', 'super_admin')
        )
    );

-- Create updated_at trigger
CREATE TRIGGER handle_updated_at_feedback_reports
    BEFORE UPDATE ON public.feedback_reports
    FOR EACH ROW
    EXECUTE FUNCTION public.touch_updated_at();

-- Add to audit log trigger
CREATE TRIGGER audit_feedback_reports_changes
    AFTER INSERT OR UPDATE OR DELETE ON public.feedback_reports
    FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();
