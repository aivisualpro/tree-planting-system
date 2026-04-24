-- Create storage bucket for visit-media if it doesn't exist
INSERT INTO storage.buckets (id, name, public) 
VALUES ('visit-media', 'visit-media', false)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (idempotent)
DROP POLICY IF EXISTS "Insert media policy" ON storage.objects;
DROP POLICY IF EXISTS "Select media policy" ON storage.objects;
DROP POLICY IF EXISTS "Delete media policy" ON storage.objects;

-- INSERT: auth.uid() = path_prefix (first segment = user id)
CREATE POLICY "Insert media policy"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'visit-media' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Helper function to check if user can read parent visit
CREATE OR REPLACE FUNCTION public.can_read_visit(p_visit_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.visits
    WHERE id = p_visit_id AND (
      created_by = auth.uid() OR
      public.has_country_access(country_id) OR
      (SELECT view_all_visits FROM public.profiles WHERE id = auth.uid()) = true
    )
  );
$$;

-- SELECT: user can read a media object if they can read the parent visit
-- The object name format is expected to be {user_id}/{visit_id}/{filename} or similar, but the metadata or name needs to link to visit_id.
-- Wait, how does Supabase know the visit_id? Usually it's the second segment of the path, or passed in metadata.
-- Let's assume the path is {user_id}/{visit_id}/{filename}.
CREATE POLICY "Select media policy"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'visit-media' AND
  public.can_read_visit( (storage.foldername(name))[2]::uuid )
);

-- DELETE: only the creator or admin
CREATE POLICY "Delete media policy"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'visit-media' AND
  (
    auth.uid()::text = (storage.foldername(name))[1] OR
    public.is_admin()
  )
);
