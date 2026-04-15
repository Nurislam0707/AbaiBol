-- 1. Create new tables for categories
CREATE TABLE IF NOT EXISTS public.buildings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text, -- e.g., 'Canteen', 'Library', 'Toilet'
  image_url text
);

CREATE TABLE IF NOT EXISTS public.student_life_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  image_url text
);

CREATE TABLE IF NOT EXISTS public.clubs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text, -- e.g., 'Art', 'Science', 'Sport'
  image_url text
);

-- 2. Update reviews table to support new categories
ALTER TABLE public.reviews ADD COLUMN IF NOT EXISTS building_id uuid REFERENCES public.buildings(id) ON DELETE CASCADE;
ALTER TABLE public.reviews ADD COLUMN IF NOT EXISTS student_life_id uuid REFERENCES public.student_life_items(id) ON DELETE CASCADE;
ALTER TABLE public.reviews ADD COLUMN IF NOT EXISTS club_id uuid REFERENCES public.clubs(id) ON DELETE CASCADE;

-- 3. Update the constraint to include new categories
ALTER TABLE public.reviews DROP CONSTRAINT IF EXISTS reviews_target_check;
ALTER TABLE public.reviews ADD CONSTRAINT reviews_target_check CHECK (
  (teacher_id IS NOT NULL AND subject_id IS NULL AND building_id IS NULL AND student_life_id IS NULL AND club_id IS NULL) OR
  (teacher_id IS NULL AND subject_id IS NOT NULL AND building_id IS NULL AND student_life_id IS NULL AND club_id IS NULL) OR
  (teacher_id IS NULL AND subject_id IS NULL AND building_id IS NOT NULL AND student_life_id IS NULL AND club_id IS NULL) OR
  (teacher_id IS NULL AND subject_id IS NULL AND building_id IS NULL AND student_life_id IS NOT NULL AND club_id IS NULL) OR
  (teacher_id IS NULL AND subject_id IS NULL AND building_id IS NULL AND student_life_id IS NULL AND club_id IS NOT NULL)
);

-- 4. Enable RLS for new tables
ALTER TABLE public.buildings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_life_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clubs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "buildings_are_publicly_readable" ON public.buildings FOR SELECT USING (true);
CREATE POLICY "student_life_are_publicly_readable" ON public.student_life_items FOR SELECT USING (true);
CREATE POLICY "clubs_are_publicly_readable" ON public.clubs FOR SELECT USING (true);

-- 5. Notify Supabase PostgREST schema cache to reload
NOTIFY pgrst, 'reload schema';
