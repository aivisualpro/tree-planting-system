DROP INDEX IF EXISTS public.idx_profiles_training;

ALTER TABLE public.profiles 
  DROP COLUMN force_tutorial,
  DROP COLUMN training_required,
  DROP COLUMN tutorial_completed;
