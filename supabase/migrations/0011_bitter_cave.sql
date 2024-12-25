/*
  # Add Subscriptions Support

  1. New Tables
    - `subscription_plans`
      - `id` (uuid, primary key)
      - `name` (text)
      - `price` (numeric)
      - `interval` (text)
      - `features` (jsonb)
      - `created_at` (timestamptz)
    
    - `subscriptions`
      - `id` (uuid, primary key) 
      - `user_id` (uuid, references auth.users)
      - `plan_id` (uuid, references subscription_plans)
      - `status` (text)
      - `current_period_start` (timestamptz)
      - `current_period_end` (timestamptz)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users
*/

-- Create subscription_plans table
CREATE TABLE IF NOT EXISTS subscription_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  price numeric NOT NULL,
  interval text NOT NULL CHECK (interval IN ('month', 'year')),
  features jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- Create subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
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

-- Policies for subscription_plans
CREATE POLICY "Anyone can view plans"
  ON subscription_plans
  FOR SELECT
  TO authenticated
  USING (true);

-- Policies for subscriptions
CREATE POLICY "Users can view own subscription"
  ON subscriptions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own subscription"
  ON subscriptions
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_plan_id ON subscriptions(plan_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- Insert default plans
INSERT INTO subscription_plans (name, price, interval, features) VALUES
  ('Starter', 9.99, 'month', '["Up to 100 review monitoring", "Basic response templates", "Email alerts", "Standard support", "Single platform integration"]'::jsonb),
  ('Professional', 19.99, 'month', '["Up to 500 review monitoring", "AI-powered response suggestions", "Priority review alerts", "Priority support", "Multi-platform integration", "Review removal assistance", "Monthly performance reports"]'::jsonb),
  ('Enterprise', 29.99, 'month', '["Unlimited review monitoring", "Advanced AI analysis", "Real-time alerts", "Dedicated account manager", "All platform integrations", "Priority review removal", "Custom API access"]'::jsonb)
ON CONFLICT DO NOTHING;