# RiskLens - AI-Powered Startup Risk Assessment

🚀 **Production-ready for Vercel Deployment**

## 📦 What's Included

This is a production-optimized static site ready for immediate deployment:
- ✅ Production-ready HTML, CSS, and JavaScript
- ✅ Optimized and minified assets
- ✅ SPA routing configuration (`vercel.json`)
- ✅ All brand assets (logo, favicon)
- ✅ Environment variable template (`.env.example`)

## 🚀 Deployment Instructions

### Step 1: Push to GitHub

1. **Initialize Git** (if not already done):
   ```bash
   git init
   git add .
   git commit -m "Initial commit - Ready for deployment"
   ```

2. **Create a new repository on GitHub**:
   - Go to [github.com](https://github.com/new)
   - Create a new repository (e.g., "risklens-app")
   - **Don't** initialize with README, .gitignore, or license

3. **Push your code**:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   git branch -M main
   git push -u origin main
   ```

### Step 2: Deploy on Vercel

1. **Import Project**:
   - Go to [vercel.com](https://vercel.com) and sign in with GitHub
   - Click **"Add New Project"** or **"Import Project"**
   - Select your GitHub repository

2. **Configure Project**:
   - Framework Preset: **Other** (or leave it to auto-detect)
   - Root Directory: `./` (default)
   - Build Command: Leave empty (static site)
   - Output Directory: Leave empty or `./`

3. **Add Environment Variables** (IMPORTANT!):
   Before clicking Deploy, add these environment variables:
   ```
   VITE_SUPABASE_URL=https://fwfycdqcmqqgcisduxqb.supabase.co
   VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3ZnljZHFjbXFxZ2Npc2R1eHFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxNTI3MjYsImV4cCI6MjA4NDcyODcyNn0.23DKSfA1Z8UOSNKMWJotSN2_F01sZH4AdaA9q9GE5mM
   ```

4. **Deploy**:
   - Click **"Deploy"**
   - Wait for deployment to complete (usually 1-2 minutes)
   - You'll get a public URL like `https://your-project.vercel.app`

### Step 3: Test Your Live Site

Once deployed, visit your Vercel URL and test:
- ✓ Homepage loads correctly
- ✓ Account creation works
- ✓ Login functionality
- ✓ All features are operational

## 🔧 Project Structure

```
startup-success-compass-main/
├── index.html              # Main HTML file
├── assets/                 # Bundled JS and CSS files
│   ├── index-ELMx1cg_.js
│   ├── index-DsKJeHns.css
│   └── ...
├── logo.png               # Brand logo
├── favicon.ico            # Site favicon
├── vercel.json            # Vercel configuration
├── .gitignore             # Git ignore rules
├── .env.example           # Environment variables template
└── README.md              # This file
```

## 🌐 Features

- AI-powered startup risk assessment
- User authentication (Supabase)
- Interactive risk analysis
- Mitigation strategy recommendations
- Modern, responsive UI

## 📝 Notes

- This is a **static site** - no build process required
- All assets are pre-bundled and optimized
- Environment variables are used for Supabase connection
- The `.env.example` file is for reference only

## 🆘 Troubleshooting

**Issue**: Blank page after deployment
- **Solution**: Make sure environment variables are added in Vercel project settings

**Issue**: Login/signup not working
- **Solution**: Verify Supabase credentials in environment variables

**Issue**: 404 on refresh
- **Solution**: The `vercel.json` file should handle this automatically

---

Built with ❤️ for professional deployment | © 2026 RiskLens
