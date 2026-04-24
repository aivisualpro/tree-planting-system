ALTER TABLE public.profiles 
  ADD COLUMN force_tutorial BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN training_required BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN tutorial_completed BOOLEAN NOT NULL DEFAULT false;

-- Create an index to quickly find people needing training
CREATE INDEX idx_profiles_training ON public.profiles(training_required, tutorial_completed);
