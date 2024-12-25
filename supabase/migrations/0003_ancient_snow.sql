/*
  # Reviews Table Enhancements
  
  1. Changes
    - Add indexes for common query patterns
    - Add trigger for automatic timestamp updates
    - Add business_id column for future multi-business support
  
  2. Performance
    - Index on user_id for faster lookups
    - Index on platform for filtering
    - Composite index on (user_id, created_at) for timeline queries
*/

-- Add business_id column
ALTER TABLE reviews 
ADD COLUMN IF NOT EXISTS business_id UUID;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_reviews_user_id 
ON reviews(user_id);

CREATE INDEX IF NOT EXISTS idx_reviews_platform 
ON reviews(platform);

CREATE INDEX IF NOT EXISTS idx_reviews_user_timeline 
ON reviews(user_id, created_at DESC);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_reviews_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_reviews_updated_at ON reviews;

CREATE TRIGGER set_reviews_updated_at
  BEFORE UPDATE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_reviews_updated_at();