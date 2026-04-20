-- Add avatar_url, cover_url, and bio to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS bio TEXT;

-- Refresh schema cache (Supabase specific)
NOTIFY pgrst, 'reload schema';
