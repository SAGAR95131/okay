-- ========================================
-- STARTUP RISK COMPASS - DATABASE SETUP
-- ========================================
-- Run this in Supabase SQL Editor to set up your fresh database
-- Go to: Supabase Dashboard → SQL Editor → New Query → Paste this code → Run

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- TABLES
-- ========================================

-- Create profiles table (for user info)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT,
  email TEXT UNIQUE,
  avatar_url TEXT,
  company TEXT,
  role TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create startup_assessments table
CREATE TABLE IF NOT EXISTS startup_assessments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  startup_name TEXT NOT NULL,
  industry TEXT,
  description TEXT,
  target_market TEXT,
  business_model TEXT,
  risk_score DECIMAL(5,2),
  financial_risk DECIMAL(5,2),
  market_risk DECIMAL(5,2),
  technical_risk DECIMAL(5,2),
  team_risk DECIMAL(5,2),
  assessment_data JSONB,
  mitigation_strategies JSONB,
  recommendations TEXT[],
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'completed', 'archived')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create saved_reports table
CREATE TABLE IF NOT EXISTS saved_reports (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  assessment_id UUID REFERENCES startup_assessments(id) ON DELETE CASCADE,
  report_name TEXT NOT NULL,
  report_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- INDEXES
-- ========================================

CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_assessments_user_id ON startup_assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_assessments_created_at ON startup_assessments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_assessments_status ON startup_assessments(status);
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON saved_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_assessment_id ON saved_reports(assessment_id);

-- ========================================
-- ROW LEVEL SECURITY (RLS)
-- ========================================

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE startup_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_reports ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view own assessments" ON startup_assessments;
DROP POLICY IF EXISTS "Users can create own assessments" ON startup_assessments;
DROP POLICY IF EXISTS "Users can update own assessments" ON startup_assessments;
DROP POLICY IF EXISTS "Users can delete own assessments" ON startup_assessments;
DROP POLICY IF EXISTS "Users can view own reports" ON saved_reports;
DROP POLICY IF EXISTS "Users can create own reports" ON saved_reports;
DROP POLICY IF EXISTS "Users can delete own reports" ON saved_reports;

-- Profiles policies
CREATE POLICY "Users can view own profile" 
  ON profiles FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
  ON profiles FOR INSERT 
  WITH CHECK (auth.uid() = id);

-- Startup assessments policies
CREATE POLICY "Users can view own assessments" 
  ON startup_assessments FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own assessments" 
  ON startup_assessments FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own assessments" 
  ON startup_assessments FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own assessments" 
  ON startup_assessments FOR DELETE 
  USING (auth.uid() = user_id);

-- Saved reports policies
CREATE POLICY "Users can view own reports" 
  ON saved_reports FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own reports" 
  ON saved_reports FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own reports" 
  ON saved_reports FOR DELETE 
  USING (auth.uid() = user_id);

-- ========================================
-- FUNCTIONS
-- ========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_assessments_updated_at ON startup_assessments;
CREATE TRIGGER update_assessments_updated_at
  BEFORE UPDATE ON startup_assessments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ========================================
-- SAMPLE DATA (OPTIONAL - FOR TESTING)
-- ========================================
-- Uncomment below if you want to insert test data

/*
-- Note: You'll need to sign up a user first to get a valid user_id
-- Then replace 'YOUR_USER_ID_HERE' with the actual UUID from auth.users

INSERT INTO startup_assessments (user_id, startup_name, industry, description, risk_score, status)
VALUES (
  'YOUR_USER_ID_HERE'::UUID,
  'TechStartup Inc.',
  'SaaS',
  'AI-powered analytics platform for e-commerce',
  6.5,
  'completed'
);
*/

-- ========================================
-- VERIFICATION QUERIES
-- ========================================
-- Run these after setup to verify everything is working

-- Check tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- Check policies
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ========================================
-- SETUP COMPLETE! 🎉
-- ========================================
-- Your database is ready to accept new user signups!
-- 
-- Next steps:
-- 1. Add environment variables to Vercel
-- 2. Redeploy your application
-- 3. Test signup functionality
