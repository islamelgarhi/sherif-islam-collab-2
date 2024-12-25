/*
  # Add Review Categories and Responses
  
  1. New Tables
    - review_categories
      - id (uuid, primary key)
      - name (text, unique) - e.g., 'Cleanliness', 'Service', 'Location'
      - description (text)
      - created_at (timestamp)
    
    - review_responses
      - id (uuid, primary key) 
      - review_id (uuid, references reviews)
      - content (text)
      - status (text) - 'draft', 'published'
      - created_at, updated_at (timestamps)
  
  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users
    
  3. Changes
    - Add category_id to reviews table
    - Add response_count to reviews table
*/

-- Create review categories table
CREATE TABLE IF NOT EXISTS review_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create review responses table
CREATE TABLE IF NOT EXISTS review_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id UUID REFERENCES reviews(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Add category support to reviews
ALTER TABLE reviews
ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES review_categories(id),
ADD COLUMN IF NOT EXISTS response_count INT DEFAULT 0;

-- Enable RLS
ALTER TABLE review_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_responses ENABLE ROW LEVEL SECURITY;

-- Policies for review categories
CREATE POLICY "Everyone can view categories"
  ON review_categories
  FOR SELECT
  TO authenticated
  USING (true);

-- Policies for review responses
CREATE POLICY "Users can view responses to their reviews"
  ON review_responses
  FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM reviews
    WHERE reviews.id = review_responses.review_id
    AND reviews.user_id = auth.uid()
  ));

CREATE POLICY "Users can create responses to their reviews"
  ON review_responses
  FOR INSERT
  TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM reviews
    WHERE reviews.id = review_responses.review_id
    AND reviews.user_id = auth.uid()
  ));

CREATE POLICY "Users can update their responses"
  ON review_responses
  FOR UPDATE
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM reviews
    WHERE reviews.id = review_responses.review_id
    AND reviews.user_id = auth.uid()
  ));

-- Create response count trigger
CREATE OR REPLACE FUNCTION update_review_response_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE reviews 
    SET response_count = response_count + 1
    WHERE id = NEW.review_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE reviews
    SET response_count = response_count - 1
    WHERE id = OLD.review_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_review_response_count ON review_responses;

CREATE TRIGGER update_review_response_count
  AFTER INSERT OR DELETE ON review_responses
  FOR EACH ROW
  EXECUTE FUNCTION update_review_response_count();

-- Insert default categories
INSERT INTO review_categories (name, description) VALUES
  ('Cleanliness', 'Reviews about cleanliness and maintenance'),
  ('Service', 'Reviews about customer service and staff interaction'),
  ('Location', 'Reviews about property location and accessibility'),
  ('Value', 'Reviews about price and value for money'),
  ('Amenities', 'Reviews about provided amenities and facilities')
ON CONFLICT (name) DO NOTHING;