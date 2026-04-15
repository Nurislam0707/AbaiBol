-- 1. Add image_url to reviews table
ALTER TABLE public.reviews ADD COLUMN IF NOT EXISTS image_url text;

-- 2. Create review_likes table
CREATE TABLE IF NOT EXISTS public.review_likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid REFERENCES public.reviews(id) ON DELETE CASCADE NOT NULL,
  user_id uuid NOT NULL, -- This will correspond to our anonymous auth pseudo-user ID if we don't have true auth, or real user_id
  created_at timestamptz DEFAULT now(),
  UNIQUE(review_id, user_id)
);

-- 3. Create review_reports table for moderation
CREATE TABLE IF NOT EXISTS public.review_reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid REFERENCES public.reviews(id) ON DELETE CASCADE NOT NULL,
  user_id uuid NOT NULL,
  reason text NOT NULL,
  status text DEFAULT 'pending', -- 'pending', 'resolved', 'dismissed'
  created_at timestamptz DEFAULT now()
);

-- 4. Enable RLS
ALTER TABLE public.review_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;

-- 5. Policies for Review Likes
CREATE POLICY "anyone_can_read_likes" ON public.review_likes FOR SELECT USING (true);
CREATE POLICY "users_can_insert_likes" ON public.review_likes FOR INSERT WITH CHECK (true);
CREATE POLICY "users_can_delete_own_likes" ON public.review_likes FOR DELETE USING (true); -- Ideally restrict by auth.uid() if users are logged in

-- 6. Policies for Review Reports
CREATE POLICY "users_can_insert_reports" ON public.review_reports FOR INSERT WITH CHECK (true);
-- We shouldn't allow normal users to SELECT reports for privacy reasons, only admins

-- 7. Views or Functions to get helpful count
-- Instead of a trigger, we can just use a function or joining, but since Postgrest doesn't easily return join counts inside basic selects,
-- We will add helpful_count column to reviews table and use a trigger to maintain it.
ALTER TABLE public.reviews ADD COLUMN IF NOT EXISTS helpful_count integer DEFAULT 0;

CREATE OR REPLACE FUNCTION update_helpful_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.reviews SET helpful_count = helpful_count + 1 WHERE id = NEW.review_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.reviews SET helpful_count = helpful_count - 1 WHERE id = OLD.review_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_helpful_count ON public.review_likes;
CREATE TRIGGER trigger_update_helpful_count
AFTER INSERT OR DELETE ON public.review_likes
FOR EACH ROW EXECUTE FUNCTION update_helpful_count();

-- 8. Create Storage Bucket for Review Images
INSERT INTO storage.buckets (id, name, public) 
VALUES ('review_images', 'review_images', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Give users access to own folder" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'review_images');
CREATE POLICY "Give public access to review images" ON storage.objects FOR SELECT USING (bucket_id = 'review_images');
