/*
  # Create trials table and related functions

  1. New Tables
    - `trials`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references profiles)
      - `business_name` (text)
      - `business_type` (text)
      - `status` (text)
      - `start_date` (timestamptz)
      - `end_date` (timestamptz)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on trials table
    - Add policies for trial access
*/

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

-- Policies
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

-- Indexes
CREATE INDEX idx_trials_user_id ON trials(user_id);
CREATE INDEX idx_trials_status ON trials(status);