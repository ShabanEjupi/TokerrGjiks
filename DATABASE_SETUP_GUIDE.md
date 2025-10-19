# 🚀 DATABASE SETUP GUIDE - TokerrGjiks with Neon PostgreSQL

## 📋 Overview
This guide will help you set up the Neon PostgreSQL database and connect it to your Netlify deployment so that:
- ✅ Real users are saved and loaded (no more "Player Player")
- ✅ Leaderboard shows actual player stats
- ✅ Statistics page works with real data
- ✅ Friends can find each other by username
- ✅ Game history is persisted
- ✅ Points and coins are saved

---

## 🎯 Step 1: Set Up Neon Database

### 1.1 Access Neon Console
1. Go to [Neon Console](https://console.neon.tech/)
2. Log in with your account (you should already have this set up)
3. Select your project or create a new one

### 1.2 Run the Database Schema
1. In the Neon console, click on **SQL Editor** (left sidebar)
2. Open the file `database_schema.sql` from your repository root
3. Copy ALL the contents of that file
4. Paste it into the Neon SQL Editor
5. Click **Run** button (or press Ctrl+Enter)
6. You should see: ✅ Success messages for all tables created

**What this does:**
- Creates `users` table (username, coins, wins, losses, etc.)
- Creates `game_history` table (all past games)
- Creates `friends` table (friend relationships)
- Creates `game_sessions` table (multiplayer sessions)
- Adds indexes for fast queries
- Inserts sample data (AlbinKosovar, DoraShqipja, EnisGamer, LindaPlay)

---

## 🎯 Step 2: Get Database Connection String

### 2.1 Copy Connection String
1. In Neon console, go to **Dashboard**
2. Find the **Connection Details** section
3. Select **Pooled connection** (recommended for serverless)
4. Copy the connection string (looks like):
   ```
   postgresql://neondb_owner:npg_xxx...@ep-xxx.aws.neon.tech/neondb?sslmode=require
   ```
5. Keep this safe - you'll need it in the next step

**Note:** The connection string is already in your `api_keys.dart` file, but you need to add it to Netlify too!

---

## 🎯 Step 3: Configure Netlify Environment Variables

### 3.1 Access Netlify Site Settings
1. Go to [Netlify Dashboard](https://app.netlify.com/)
2. Select your **tokerrgjik** site
3. Click on **Site configuration** (or **Site settings**)
4. Click on **Environment variables** in the left sidebar

### 3.2 Add Database Environment Variable
1. Click **Add a variable** → **Add a single variable**
2. **Key:** `NEON_DATABASE_URL`
3. **Value:** Paste your Neon connection string from Step 2.1
4. **Scopes:** Select all (Production, Deploy previews, Branch deploys)
5. Click **Create variable**

### 3.3 Verify Environment Variable
You should see:
```
NEON_DATABASE_URL = postgresql://neondb_owner:npg_xxx...
```

---

## 🎯 Step 4: Install Node Dependencies for Netlify Functions

### 4.1 Navigate to Functions Directory
```bash
cd netlify/functions
```

### 4.2 Install Dependencies
```bash
npm install
```

This installs:
- `@neondatabase/serverless` - Neon PostgreSQL driver
- `@netlify/functions` - Netlify functions SDK

### 4.3 Return to Root
```bash
cd ../..
```

---

## 🎯 Step 5: Deploy to Netlify

### 5.1 Commit All Changes
```bash
git add .
git commit -m "Add Neon database integration with API endpoints"
git push origin main
```

### 5.2 Wait for Deployment
1. Netlify will automatically detect the push
2. Go to **Deploys** tab in Netlify dashboard
3. Wait for deployment to complete (usually 2-5 minutes)
4. You should see: ✅ **Published**

### 5.3 Check Function Logs
1. In Netlify, go to **Functions** tab
2. You should see 5 functions listed:
   - `health` - Health check
   - `users` - User registration & management
   - `leaderboard` - Leaderboard data
   - `games` - Game history
   - `statistics` - User statistics

---

## 🎯 Step 6: Test the API

### 6.1 Test Health Endpoint
Open in browser:
```
https://tokerrgjik.netlify.app/.netlify/functions/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "TokerrGjiks API is running",
  "database": "connected",
  "timestamp": "2025-10-19T..."
}
```

### 6.2 Test Leaderboard
Open in browser:
```
https://tokerrgjik.netlify.app/.netlify/functions/leaderboard
```

Expected response (sample data):
```json
{
  "leaderboard": [
    {
      "username": "EnisGamer",
      "coins": 720,
      "total_wins": 42,
      "total_losses": 8,
      "level": 7,
      "rank": 1
    },
    ...
  ]
}
```

### 6.3 Test User Search
Open in browser:
```
https://tokerrgjik.netlify.app/.netlify/functions/users/search?q=enis
```

Expected response:
```json
{
  "users": [
    {
      "username": "EnisGamer",
      "coins": 720,
      "total_wins": 42,
      "level": 7
    }
  ]
}
```

---

## 🎯 Step 7: Test in the App

### 7.1 Open Web App
Go to: https://tokerrgjik.netlify.app/

### 7.2 Test Leaderboard
1. Click on **Leaderboard** icon
2. You should see **real usernames** (AlbinKosovar, DoraShqipja, EnisGamer, LindaPlay)
3. No more "Player Player" dummy data! ✅

### 7.3 Test Friend Search
1. Click on **Friends** icon
2. Click **Add Friend** button
3. Search for "enis"
4. You should see "EnisGamer" appear ✅

### 7.4 Test Statistics
1. Go to **Settings** or **Profile**
2. Click on **Statistics**
3. Should show your real game history (once you play games) ✅

---

## 🎯 Step 8: Create Your Own User Account

### 8.1 Register New User
When you first open the app, it should automatically create a user. Or you can manually register:

**Option A: Via App**
1. Open the app
2. Go to Settings → Change Username
3. Enter your desired username
4. App will automatically register you in the database

**Option B: Via SQL (Advanced)**
In Neon SQL Editor:
```sql
INSERT INTO users (username, email, coins, level, total_wins, total_losses, total_draws)
VALUES ('YourUsername', 'your@email.com', 100, 1, 0, 0, 0);
```

---

## 🎯 Step 9: Play Games to Populate Data

### 9.1 Play Some Games
1. Play against AI
2. Play against friends
3. Each game result will be saved to database automatically

### 9.2 Verify Data is Saved
After playing, check Neon SQL Editor:
```sql
SELECT * FROM game_history ORDER BY played_at DESC LIMIT 10;
```

You should see your recent games! ✅

---

## 🔧 Troubleshooting

### Issue: Leaderboard still shows empty
**Solution:**
1. Check Netlify function logs for errors
2. Verify `NEON_DATABASE_URL` is set correctly
3. Check browser console for API errors
4. Test health endpoint to verify database connection

### Issue: "User not found" when searching friends
**Solution:**
1. Make sure users exist in database
2. Run sample data insert from `database_schema.sql`
3. Or register new users via the app

### Issue: Statistics not showing
**Solution:**
1. Play at least one game first
2. Check `game_history` table has data:
   ```sql
   SELECT COUNT(*) FROM game_history;
   ```
3. Verify API endpoint is working:
   ```
   https://tokerrgjik.netlify.app/.netlify/functions/statistics/YourUsername
   ```

### Issue: Function deployment failed
**Solution:**
1. Check `netlify/functions/package.json` exists
2. Verify all `.mjs` files are present
3. Check Netlify build logs for specific errors
4. Make sure `netlify.toml` is in repository root

---

## 📊 Database Schema Overview

### Users Table
- `id` - UUID (auto)
- `username` - Unique username
- `coins` - User coins/currency
- `level` - User level
- `total_wins/losses/draws` - Game statistics
- `created_at` - Registration date

### Game History Table
- `id` - UUID (auto)
- `username` - Player reference
- `game_mode` - vs_ai, multiplayer, etc.
- `result` - win/loss/draw
- `opponent_username` - Opponent (if applicable)
- `played_at` - Game timestamp

### Friends Table
- `user_username` - User requesting
- `friend_username` - Friend being added
- `status` - pending/accepted/blocked

---

## 🎮 What Works Now

After completing this setup:

✅ **Leaderboard** - Shows real players ranked by wins
✅ **Statistics** - Real game history and stats
✅ **Friend Search** - Find users by username
✅ **User Profiles** - Persistent user data
✅ **Game History** - All games recorded
✅ **Coins & Level** - Saved across sessions
✅ **Web App** - Fully functional on tokerrgjik.netlify.app

---

## 📝 Next Steps

1. **Add more users** - Invite friends to register
2. **Play games** - Build up the leaderboard
3. **Test multiplayer** - Challenge friends online
4. **Monitor database** - Check Neon dashboard for usage
5. **Scale up** - Neon free tier supports 512 MB, upgrade if needed

---

## 🆘 Need Help?

- **Neon Documentation:** https://neon.tech/docs
- **Netlify Functions:** https://docs.netlify.com/functions/overview/
- **Check Logs:**
  - Netlify: Functions tab → Click function → View logs
  - Neon: SQL Editor → Run queries to check data
- **Browser Console:** F12 → Console tab (check for API errors)

---

## ✅ Checklist

Before asking for help, verify:
- [ ] Ran `database_schema.sql` in Neon SQL Editor
- [ ] Added `NEON_DATABASE_URL` to Netlify environment variables
- [ ] Deployed latest code to Netlify (git push)
- [ ] Health endpoint returns `"status": "ok"`
- [ ] Sample users exist (check with leaderboard endpoint)
- [ ] Browser console shows no CORS errors

---

**Created:** October 2025
**Last Updated:** After Neon integration
**Status:** ✅ Ready for production
