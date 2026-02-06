# 🗄️ Supabase Database Setup Guide

## Option 1: Use Existing Database (Quickest Fix)

If you just want to fix the current error:

1. **Add Environment Variables in Vercel:**
   - Go to https://vercel.com
   - Select your project
   - Settings → Environment Variables
   - Add:
     ```
     VITE_SUPABASE_URL=https://fwfycdqcmqqgcisduxqb.supabase.co
     VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3ZnljZHFjbXFxZ2Npc2R1eHFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNTI3MjYsImV4cCI6MjA4NDcyODcyNn0.23DKSfA1Z8UOSNKMWJotSN2_F01sZH4AdaA9q9GE5mM
     ```
   - Select: Production, Preview, Development
   - Click Save

2. **Redeploy:**
   - Go to Deployments tab
   - Click ••• on latest deployment
   - Click "Redeploy"

---

## Option 2: Create Fresh Supabase Database (Recommended for New Project)

### Step 1: Create New Supabase Project

1. Go to **https://supabase.com**
2. Click **"Start your project"** or **"Sign In"**
3. Sign in with GitHub
4. Click **"New Project"**
5. Fill in:
   - **Name:** `startup-risk-database` (or your preferred name)
   - **Database Password:** Create a strong password (save it!)
   - **Region:** Choose closest to your users (e.g., `ap-south-1` for India)
   - **Pricing Plan:** Free
6. Click **"Create new project"**
7. Wait 2-3 minutes for setup to complete

### Step 2: Get Your Credentials

1. Once created, go to **Project Settings** (gear icon ⚙️)
2. Click **API** in the left sidebar
3. You'll see:
   - **Project URL** → This is your `VITE_SUPABASE_URL`
   - **Project API keys** → Copy the `anon` `public` key → This is your `VITE_SUPABASE_PUBLISHABLE_KEY`

### Step 3: Set Up Database Tables

1. Go to **SQL Editor** in Supabase dashboard
2. Click **"New Query"**
3. Copy and paste this SQL code:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table (for user info)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT,
  email TEXT UNIQUE,
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
  risk_score DECIMAL(5,2),
  assessment_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_assessments_user_id ON startup_assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_assessments_created_at ON startup_assessments(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE startup_assessments ENABLE ROW LEVEL SECURITY;

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

-- Create function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

4. Click **"Run"** or press `Ctrl+Enter`
5. Wait for success message

### Step 4: Configure Email Authentication (Optional but Recommended)

1. Go to **Authentication** → **Providers** in Supabase
2. Make sure **Email** is enabled
3. Configure email templates if needed
4. For testing, you can **disable email confirmation**:
   - Go to **Authentication** → **Email Templates**
   - Or disable in **Settings** → **Authentication** → **Email Auth**

### Step 5: Update Your Project

1. **Update `.env.example` file** with new credentials (for reference)
2. **Update Vercel Environment Variables:**
   - Go to https://vercel.com → Your Project → Settings → Environment Variables
   - Update or add:
     - `VITE_SUPABASE_URL` = YOUR_NEW_PROJECT_URL
     - `VITE_SUPABASE_PUBLISHABLE_KEY` = YOUR_NEW_ANON_KEY
   - Select all environments (Production, Preview, Development)
   - Click Save

3. **Redeploy on Vercel:**
   - Deployments → ••• → Redeploy

---

## ✅ Testing Your Database

After deployment:

1. Visit your Vercel URL
2. Try signing up with a new account:
   - Full Name: Test User
   - Email: test@example.com
   - Password: Test123!@#
3. Check Supabase dashboard:
   - Go to **Authentication** → **Users** to see registered users
   - Go to **Table Editor** → **profiles** to see user profiles

---

## 🔧 Troubleshooting

### "Failed to fetch" error persists:
- ✅ Check environment variables are saved in Vercel
- ✅ Verify you redeployed after adding env vars
- ✅ Check Supabase project is active (not paused)
- ✅ Verify Supabase URL and API key are correct

### Users can't sign up:
- ✅ Check SQL tables were created (Table Editor in Supabase)
- ✅ Verify RLS policies are enabled
- ✅ Check email confirmation isn't blocking (if disabled in settings)

### "Anonymous sign-ins are disabled":
- Go to Supabase → Authentication → Providers
- Enable Email provider

---

## 📊 Database Schema Summary

Your database will have:

1. **`profiles`** - User profile information
   - id (UUID, links to auth.users)
   - full_name (TEXT)
   - email (TEXT)
   - created_at, updated_at

2. **`startup_assessments`** - Risk assessment data
   - id (UUID)
   - user_id (UUID, links to profiles)
   - startup_name (TEXT)
   - industry (TEXT)
   - description (TEXT)
   - risk_score (DECIMAL)
   - assessment_data (JSONB) - stores detailed analysis
   - created_at, updated_at

---

## 🎉 You're All Set!

Your fresh database is ready to accept new users. They can:
- ✅ Sign up with email/password
- ✅ Store their startup assessments
- ✅ View their historical data
- ✅ Get AI-powered risk analysis

---

Need help? Check the Supabase docs: https://supabase.com/docs
