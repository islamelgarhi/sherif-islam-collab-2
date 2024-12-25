/*
  # Update trials table and policies

  1. Changes
    - Drop existing policies if they exist
    - Create or update policies for trials table
    - Add function and trigger for trial expiration
*/

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own trial" ON trials;
DROP POLICY IF EXISTS "Users can insert own trial" ON trials;

-- Create or update policies
CREATE POLICY "Users can view own trial"
  ON trials
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own trial"
  ON trials
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Function to automatically expire trials
CREATE OR REPLACE FUNCTION check_trial_expiration()
RETURNS trigger AS $$
BEGIN
  UPDATE trials
  SET status = 'expired'
  WHERE end_date < NOW()
  AND status = 'active';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS check_trials_expiration ON trials;

-- Create trigger to check trial expiration
CREATE TRIGGER check_trials_expiration
  AFTER INSERT OR UPDATE ON trials
  FOR EACH STATEMENT
  EXECUTE FUNCTION check_trial_expiration();