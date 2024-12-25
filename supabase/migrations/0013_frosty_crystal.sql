/*
  # Fix Subscription Plans Migration

  1. Changes
    - Drop existing policy if it exists
    - Recreate subscription_plans table with proper constraints
    - Add proper indexes and policies
    - Insert default plans
  
  2. Security
    - Enable RLS
    - Add proper policies with safety checks
*/

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Anyone can view plans" ON subscription_plans;

-- Recreate subscription_plans with proper constraints
CREATE TABLE IF NOT EXISTS subscription_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  price numeric NOT NULL CHECK (price >= 0),
  interval text NOT NULL CHECK (interval IN ('month', 'year')),
  features jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Anyone can view plans"
  ON subscription_plans
  FOR SELECT
  TO authenticated
  USING (true);

-- Insert default plans
INSERT INTO subscription_plans (name, price, interval, features) VALUES
  ('Starter', 9.99, 'month', 
   '["Up to 100 review monitoring", "Basic response templates", "Email alerts", "Standard support", "Single platform integration"]'::jsonb),
  ('Professional', 19.99, 'month',
   '["Up to 500 review monitoring", "AI-powered response suggestions", "Priority review alerts", "Priority support", "Multi-platform integration", "Review removal assistance", "Monthly performance reports"]'::jsonb),
  ('Enterprise', 29.99, 'month',
   '["Unlimited review monitoring", "Advanced AI analysis", "Real-time alerts", "Dedicated account manager", "All platform integrations", "Priority review removal", "Custom API access"]'::jsonb)
ON CONFLICT (name) 
DO UPDATE SET 
  price = EXCLUDED.price,
  features = EXCLUDED.features;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_subscription_plans_name ON subscription_plans(name);