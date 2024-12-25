/*
  # Add trials table and related functions
  
  1. New Tables
    - trials: Stores free trial information
      - id (uuid, primary key)
      - user_id (uuid, references auth.users)
      - business_name (text)
      - business_type (text, enum)
      - status (text, enum)
      - start_date (timestamptz)
      - end_date (timestamptz)
      - created_at (timestamptz)
  
  2. Security
    - Enable RLS
    - Add policies for trial access
    
  3. Functions
    - Auto-expiration of trials
*/

-- Create trials table if it doesn't exist
CREATE TABLE IF NOT EXISTS trials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  business_name TEXT NOT NULL,
  business_type TEXT CHECK (business_type IN ('rental', 'restaurant')) NOT NULL,
  status TEXT CHECK (status IN ('active', 'expired', 'converted')) DEFAULT 'active',
  start_date TIMESTAMPTZ DEFAULT now(),
  end_date TIMESTAMPTZ DEFAULT (now() + interval '14 days'),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE trials ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own trial" ON trials;
DROP POLICY IF EXISTS "Users can insert own trial" ON trials;

-- Create policies
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_trials_user_id ON trials(user_id);
CREATE INDEX IF NOT EXISTS idx_trials_status ON trials(status);

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