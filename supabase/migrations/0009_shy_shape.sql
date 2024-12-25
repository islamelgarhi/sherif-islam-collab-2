/*
  # Fix Profiles Trigger

  1. Changes
    - Add explicit error handling in trigger function
    - Add constraint checks
    - Improve profile creation logic
    - Add additional validation

  2. Security
    - Maintain RLS policies
    - Add input validation
*/

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users CASCADE;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Create improved function with better error handling
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  profile_exists boolean;
BEGIN
  -- Check if profile already exists
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = new.id
  ) INTO profile_exists;

  IF profile_exists THEN
    RAISE NOTICE 'Profile already exists for user %', new.id;
    RETURN new;
  END IF;

  -- Validate email
  IF new.email IS NULL OR length(new.email) < 3 THEN
    RAISE EXCEPTION 'Invalid email address';
  END IF;

  -- Create profile with retry logic
  FOR i IN 1..3 LOOP
    BEGIN
      INSERT INTO public.profiles (id, email)
      VALUES (new.id, new.email)
      ON CONFLICT (id) DO UPDATE
      SET email = EXCLUDED.email,
          updated_at = now();
      
      RETURN new;
    EXCEPTION WHEN others THEN
      IF i = 3 THEN RAISE; END IF;
      PERFORM pg_sleep(0.1); -- Small delay between retries
    END;
  END LOOP;

  RETURN new;
EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'Error in handle_new_user: % %', SQLERRM, SQLSTATE;
    RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Add additional indexes and constraints
ALTER TABLE profiles
  ADD CONSTRAINT profiles_email_check 
  CHECK (length(email) >= 3);

CREATE INDEX IF NOT EXISTS idx_profiles_email_lower 
  ON profiles (lower(email));