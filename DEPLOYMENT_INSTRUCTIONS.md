# 🚨 CRITICAL: Deployment Instructions - FOLLOW IN ORDER

## ⚠️ ALL FUNCTIONS ARE CRASHING - FIX REQUIRED IMMEDIATELY

Your Netlify Functions are crashing because **NEON_DATABASE_URL is not set**. Follow these steps in order:

---

## 📋 STEP 1: Set Database Environment Variable (CRITICAL - DO THIS FIRST)

### 1.1 Get Your Neon Database URL
1. Go to: https://console.neon.tech/
2. Select your **tokerrgjiks** project
3. Click **"Connection Details"** or **"Dashboard"**
4. Copy the connection string - it looks like:
   ```
   postgresql://username:password@ep-xyz-123.region.aws.neon.tech/neondb?sslmode=require
   ```

### 1.2 Add to Netlify (THIS FIXES THE CRASHES)
1. Go to: https://app.netlify.com/
2. Select your **tokerrgjik** site
3. Go to: **Site settings** → **Environment variables**
4. Click **"Add a variable"**
5. **Key:** `NEON_DATABASE_URL`
6. **Value:** Paste your PostgreSQL connection string from Neon
7. Click **"Save"**
8. Go to **Deploys** tab → Click **"Trigger deploy"** → **"Deploy site"**

**✅ THIS WILL FIX:** All 9 functions crashing with "No database connection string" error

---

## 📋 STEP 2: Run Database Schema (FIX BLANK LEADERBOARD)

### 2.1 Execute SQL in Neon Console
1. Go to: https://console.neon.tech/
2. Click **"SQL Editor"** in left sidebar
3. Open file: `database_schema.sql` from your project
4. Copy ALL the SQL code
5. Paste into Neon SQL Editor
6. Click **"Run"** button
7. Verify success: Check that tables `users`, `game_history`, `friends`, `game_sessions`, `achievements` were created

**✅ THIS WILL FIX:** Blank leaderboard, missing user data, friends not working

---

## 📋 STEP 3: Add PayPal Credentials (FIX PAYMENTS)

### 3.1 Get PayPal Sandbox Credentials
1. Go to: https://developer.paypal.com/dashboard/
2. Login with your PayPal account
3. Go to: **Apps & Credentials** → **Sandbox**
4. If no app exists, click **"Create App"**
5. Copy these two values:
   - **Client ID** (starts with "A...")
   - **Secret** (hidden, click "Show")

### 3.2 Add to Your Flutter App
1. Open: `tokerrgjik_mobile/lib/config/payment_config.dart`
2. Find lines 8-9:
   ```dart
   static const String paypalClientId = 'YOUR_PAYPAL_CLIENT_ID_HERE';
   static const String paypalSecret = 'YOUR_PAYPAL_SECRET_HERE';
   ```
3. Replace with your actual values:
   ```dart
   static const String paypalClientId = 'AZabc123...';
   static const String paypalSecret = 'ELabc123...';
   ```
4. Save the file

**✅ THIS WILL FIX:** PayPal payment gateway not opening, payments failing

---

## 📋 STEP 4: Rebuild and Deploy Flutter Web

### 4.1 Install Dependencies
```bash
cd /workspaces/TokerrGjiks/tokerrgjik_mobile
flutter pub get
```

### 4.2 Build Flutter Web
```bash
flutter build web --release
```
*This takes 2-3 minutes. Wait for "✓ Built build/web"*

### 4.3 Deploy to Netlify
```bash
cd /workspaces/TokerrGjiks
git add -A
git commit -m "Added PayPal credentials and rebuilt web"
git push origin main
```

### 4.4 Wait for Deployment
1. Go to: https://app.netlify.com/sites/tokerrgjik/deploys
2. Wait for green checkmark (2-3 minutes)
3. Click **"Open production deploy"**

**✅ THIS COMPLETES:** Full deployment with all fixes applied

---

## 🎮 STEP 5: Test All Features

### 5.1 Test Database Connection
1. Open: https://tokerrgjik.netlify.app
2. Open browser console (F12)
3. Check for database errors - should see **NO** "No database connection" errors
4. Leaderboard should show at least 4 test users

### 5.2 Test Profile Editing
1. Click profile icon → **"Edit Profile"**
2. Change username (e.g., "ShabanEjupi" instead of "Player_1234")
3. Click **"Save"**
4. Verify username updated throughout app

### 5.3 Test PayPal Payments
1. Go to Shop screen
2. Click **"Buy 100 Coins"** or **"Get PRO"**
3. PayPal should **open in new browser tab**
4. Complete payment with sandbox test account
5. Verify coins/PRO status updated

### 5.4 Test Multiplayer Lobby
1. Click **"Play Online"** from home screen
2. Should see **"Multiplayer Lobby"** screen
3. Click **"Create Game"** button
4. Game session should appear in lobby
5. Test joining from another browser/device

### 5.5 Test Friend Requests
1. Go to Friends screen
2. Click **"+"** icon to add friend
3. Search for test username (e.g., "testuser")
4. Send friend request
5. Wait 30 seconds - requests tab should auto-refresh
6. Accept request from other account

---

## ✅ VERIFICATION CHECKLIST

Run through this checklist after completing all steps:

- [ ] ✅ NEON_DATABASE_URL set in Netlify environment variables
- [ ] ✅ Database schema executed in Neon SQL Editor
- [ ] ✅ PayPal credentials added to payment_config.dart
- [ ] ✅ Flutter web rebuilt with `flutter build web --release`
- [ ] ✅ Changes committed and pushed to GitHub
- [ ] ✅ Netlify deployment completed successfully (green checkmark)
- [ ] ✅ No "database connection" errors in browser console
- [ ] ✅ Leaderboard shows test users
- [ ] ✅ Profile editing works (username changes)
- [ ] ✅ PayPal opens in browser when clicking payment buttons
- [ ] ✅ Multiplayer lobby shows available games
- [ ] ✅ Friends screen auto-refreshes every 30 seconds

---

## 🐛 TROUBLESHOOTING

### Problem: Functions still crashing after setting NEON_DATABASE_URL
**Solution:** 
1. Verify environment variable name is EXACTLY `NEON_DATABASE_URL` (case-sensitive)
2. Trigger new deploy: Deploys → Trigger deploy → Deploy site
3. Wait 2-3 minutes for deployment to complete
4. Hard refresh browser: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)

### Problem: Leaderboard still blank
**Solution:**
1. Verify database_schema.sql was executed successfully in Neon
2. Check Neon SQL Editor for any error messages
3. Try running the INSERT statements separately
4. Check browser console for API errors

### Problem: PayPal still not opening
**Solution:**
1. Verify credentials are correct (no extra spaces)
2. Ensure you're using **Sandbox** credentials, not Live
3. Check browser console for PayPal API errors
4. Verify payment_config.dart was rebuilt: `flutter build web --release`
5. Clear browser cache and hard refresh

### Problem: Username still showing "Player_1234"
**Solution:**
1. Verify database connection is working (see above)
2. Click profile → Edit Profile → Change username manually
3. If error appears, check browser console for API response
4. Verify PUT /users/profile endpoint is working: Check Netlify function logs

### Problem: Multiplayer lobby empty
**Solution:**
1. This is normal if no active games exist
2. Click "Create Game" button to start a new session
3. Open app in another browser/device to see lobby refresh
4. Sessions auto-refresh every 5 seconds

### Problem: Friend requests not appearing
**Solution:**
1. Requests auto-refresh every 30 seconds (wait)
2. Or manually leave and re-enter Friends screen
3. Verify database connection is working
4. Check that both users exist in database

---

## 📞 SUPPORT

If you're still having issues after following all steps:

1. **Check Netlify Function Logs:**
   - Go to: https://app.netlify.com/sites/tokerrgjik/functions
   - Click on any function (e.g., "users")
   - Check recent logs for errors

2. **Check Browser Console:**
   - Open app: https://tokerrgjik.netlify.app
   - Press F12 to open Developer Tools
   - Go to Console tab
   - Look for red error messages

3. **Check Neon Database:**
   - Go to: https://console.neon.tech/
   - Verify tables exist: users, game_history, friends, game_sessions
   - Try running: `SELECT * FROM users LIMIT 5;`

4. **Contact Support:**
   - Include: Screenshots of errors
   - Include: Browser console output
   - Include: Netlify function logs
   - Include: Which step failed

---

## 🎉 SUCCESS INDICATORS

You'll know everything is working when:

1. ✅ Home screen loads without errors
2. ✅ Leaderboard shows at least 4 test users
3. ✅ Username shows your actual name (not "Player_1234")
4. ✅ PayPal opens in new tab when clicking payment buttons
5. ✅ Multiplayer lobby shows your created games
6. ✅ Friend requests auto-appear within 30 seconds
7. ✅ All game modes playable (vs AI, vs Friend, Online)
8. ✅ Stats update after games (wins, losses, coins, XP)
9. ✅ Shop allows purchasing items with coins
10. ✅ Settings persist across browser sessions

---

## 📚 WHAT WAS FIXED

### Database Connection Fixes
- All 9 Netlify functions now handle missing database gracefully
- Added fallback environment variables (NEON_DATABASE_URL, NETLIFY_DATABASE_URL, DATABASE_URL)
- Clear error messages guide user to set environment variable
- Functions affected: health, users, leaderboard, games, statistics, achievements, auth, avatars, email

### PayPal Integration Fixes
- Added url_launcher package to open browser
- Extract approval URL from PayPal API response
- Launch external browser for checkout flow
- Show confirmation message after opening PayPal
- User completes payment in browser, returns to app

### Profile Editing Implementation
- Created ProfileEditScreen UI for username changes
- Username validation prevents "Player_" prefix
- Added PUT /users/profile API endpoint
- Integrated with ApiService for backend communication
- Updates username across entire app

### Multiplayer Lobby Addition
- Shows all available game sessions
- Auto-refresh every 5 seconds
- Create new game with floating action button
- Join existing games with one click
- Visual indicators for session status

### Friends Auto-Refresh
- Check for new requests every 30 seconds
- Auto-update UI without manual intervention
- Timer properly disposed when leaving screen

---

**REMEMBER: Complete ALL steps in order for full functionality!**
