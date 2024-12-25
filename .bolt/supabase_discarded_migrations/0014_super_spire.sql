/*
  # Fix Subscription Plans Migration
  
  1. Changes
    - Drop and recreate subscription_plans table with proper constraints
    - Add proper indexes and policies
    - Insert default plans with proper error handling
  
  2. Security
    - Enable RLS
    - Add proper policies with safety checks
*/

-- Drop existing table and policies
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;

-- Create subscription_plans table with proper constraints
CREATE TABLE subscription_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  price numeric NOT NULL CHECK (price >= 0),
  interval text NOT NULL CHECK (interval IN ('month', 'year')),
  features jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Create subscriptions table with proper constraints
CREATE TABLE subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  plan_id uuid REFERENCES subscription_plans(id) NOT NULL,
  status text NOT NULL CHECK (status IN ('active', 'canceled', 'past_due', 'trialing')),
  current_period_start timestamptz NOT NULL DEFAULT now(),
  current_period_end timestamptz NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Add policies
CREATE POLICY "Anyone can view plans"
  ON subscription_plans
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can view own subscription"
  ON subscriptions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own subscription"
  ON subscriptions
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id);

-- Add indexes
CREATE INDEX idx_subscription_plans_name ON subscription_plans(name);
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_plan_id ON subscriptions(plan_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- Insert default plans with DO block for better error handling
DO $$
BEGIN
  -- Insert Starter Plan
  INSERT INTO subscription_plans (name, price, interval, features)
  VALUES (
    'Starter',
    9.99,
    'month',
    '["Up to 100 review monitoring", "Basic response templates", "Email alerts", "Standard support", "Single platform integration"]'::jsonb
  )
  ON CONFLICT (name) 
  DO UPDATE SET 
    price = EXCLUDED.price,
    features = EXCLUDED.features;

  -- Insert Professional Plan
  INSERT INTO subscription_plans (name, price, interval, features)
  VALUES (
    'Professional',
    19.99,
    'month',
    '["Up to 500 review monitoring", "AI-powered response suggestions", "Priority review alerts", "Priority support", "Multi-platform integration", "Review removal assistance", "Monthly performance reports"]'::jsonb
  )
  ON CONFLICT (name) 
  DO UPDATE SET 
    price = EXCLUDED.price,
    features = EXCLUDED.features;

  -- Insert Enterprise Plan
  INSERT INTO subscription_plans (name, price, interval, features)
  VALUES (
    'Enterprise',
    29.99,
    'month',
    '["Unlimited review monitoring", "Advanced AI analysis", "Real-time alerts", "Dedicated account manager", "All platform integrations", "Priority review removal", "Custom API access"]'::jsonb
  )
  ON CONFLICT (name) 
  DO UPDATE SET 
    price = EXCLUDED.price,
    features = EXCLUDED.features;

  -- Verify plans were created
  IF NOT EXISTS (SELECT 1 FROM subscription_plans WHERE name = 'Professional') THEN
    RAISE EXCEPTION 'Failed to create Professional plan';
  END IF;
END $$;