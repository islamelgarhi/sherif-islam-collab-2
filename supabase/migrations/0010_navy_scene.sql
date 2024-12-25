-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users CASCADE;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Create a more robust function for handling new users
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  max_retries CONSTANT int := 3;
  current_try int := 0;
  profile_id uuid;
BEGIN
  -- Input validation
  IF new.email IS NULL THEN
    RAISE EXCEPTION 'Email cannot be null';
  END IF;

  -- Retry loop for profile creation
  WHILE current_try < max_retries LOOP
    BEGIN
      INSERT INTO public.profiles (id, email)
      VALUES (new.id, new.email)
      ON CONFLICT (id) DO UPDATE
      SET email = EXCLUDED.email,
          updated_at = now()
      RETURNING id INTO profile_id;

      IF profile_id IS NOT NULL THEN
        RETURN new;
      END IF;

      current_try := current_try + 1;
      IF current_try < max_retries THEN
        PERFORM pg_sleep(0.1 * current_try); -- Exponential backoff
      END IF;
    EXCEPTION WHEN OTHERS THEN
      IF current_try = max_retries - 1 THEN
        RAISE EXCEPTION 'Failed to create profile after % attempts: %', max_retries, SQLERRM;
      END IF;
      current_try := current_try + 1;
      PERFORM pg_sleep(0.1 * current_try);
    END;
  END LOOP;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create new trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Add additional safeguards
ALTER TABLE profiles
  ADD CONSTRAINT valid_email 
  CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Create function to validate email
CREATE OR REPLACE FUNCTION validate_email()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
    RAISE EXCEPTION 'Invalid email format';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for email validation
CREATE TRIGGER validate_email_trigger
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION validate_email();