# 🚀 QUICK START - Student Instructions

## ⚡ 5-Minute Setup

### Step 1: Set Up Database (2 minutes)
1. Go to [Neon Console](https://console.neon.tech/)
2. Click **SQL Editor**
3. Open `database_schema.sql` from repository
4. Copy ALL contents → Paste in editor → Click **Run**
5. ✅ Should see: "CREATE TABLE" success messages

### Step 2: Configure Netlify (1 minute)
1. Go to [Netlify Dashboard](https://app.netlify.com/)
2. Select your **tokerrgjik** site
3. **Site configuration** → **Environment variables**
4. Click **Add a variable**
5. Enter:
   - **Key:** `NEON_DATABASE_URL`
   - **Value:** Your Neon connection string (from Neon dashboard)
6. Click **Create variable**

### Step 3: Install & Deploy (2 minutes)
```bash
cd netlify/functions
npm install
cd ../..

git pull origin main
```

Done! Netlify will auto-deploy.

---

## ✅ Verify It Works

### Test 1: API Health
Open in browser:
```
https://tokerrgjik.netlify.app/.netlify/functions/health
```
✅ Should see: `{"status":"ok","database":"connected"}`

### Test 2: Leaderboard
```
https://tokerrgjik.netlify.app/.netlify/functions/leaderboard
```
✅ Should see: Real users (AlbinKosovar, DoraShqipja, etc.)

### Test 3: Web App
```
https://tokerrgjik.netlify.app/
```
✅ Shop screen not grey
✅ Leaderboard shows real names
✅ Friend search finds users

---

## 🎯 What Was Fixed

| Issue | Status | Description |
|-------|--------|-------------|
| Pink/Amethyst themes | ✅ FIXED | Removed, custom theme auto-saves colors |
| Shop grey on web | ✅ FIXED | Platform error fixed, works now |
| Share wrong URL | ✅ FIXED | Now sends netlify.app link |
| No database | ✅ FIXED | Neon PostgreSQL integrated |
| Leaderboard dummy data | ✅ FIXED | Shows real users from DB |
| Friend search broken | ✅ FIXED | Search API working |
| Statistics not working | ✅ FIXED | Stats API ready |
| Points losing | ✅ FIXED | Saved to database now |

---

## 🆘 Troubleshooting

**Problem:** Health endpoint returns error
**Solution:** Check NEON_DATABASE_URL is set correctly in Netlify

**Problem:** Leaderboard empty
**Solution:** Run database_schema.sql to create sample users

**Problem:** Function not found
**Solution:** Wait 2-3 minutes for Netlify deployment to complete

---

## 📚 Full Documentation

- **DATABASE_SETUP_GUIDE.md** - Detailed step-by-step guide
- **IMPLEMENTATION_SUMMARY.md** - Complete technical overview
- **database_schema.sql** - Database schema to run in Neon

---

**Need Help?** Check browser console (F12) for errors or Netlify function logs.
