# 🚀 Quick Setup Guide for Students

## ⚠️ CRITICAL: Do This First!

### 1. Setup Neon Database (Required for ALL features)

**Without this step, login, leaderboard, multiplayer, and statistics won't work!**

#### Step-by-Step:

1. **Create Database**:
   ```
   • Go to: https://console.neon.tech
   • Click "Create Project"
   • Copy the connection string (looks like):
     postgresql://user:password@ep-abc123.region.aws.neon.tech/neondb?sslmode=require
   ```

2. **Initialize Database**:
   ```
   • In Neon Console, click "SQL Editor"
   • Open file: scripts/init_neon_database.sql
   • Copy ALL contents
   • Paste into SQL Editor
   • Click "Run"
   • Wait for: "Database initialized successfully! ✅"
   ```

3. **Configure Netlify** (CRITICAL):
   ```
   • Go to: https://app.netlify.com
   • Select your site
   • Site Settings → Environment Variables
   • Click "Add a variable"
   • Key: NEON_DATABASE_URL
   • Value: [paste your connection string from step 1]
   • Save
   • Deploy → Trigger deploy
   ```

### 2. Test Your Setup

After deploying, test these endpoints:

```bash
# Health check
curl https://your-site.netlify.app/.netlify/functions/health

# Should return: {"status":"ok","message":"API is running"}
```

## 🛠️ Build Commands

### Web Version
```bash
cd tokerrgjik_mobile
flutter build web --release
```

### Android APK
```bash
cd tokerrgjik_mobile
flutter build apk --release --split-per-abi
```

### iOS (macOS only)
```bash
cd tokerrgjik_mobile
flutter build ios --release --no-codesign
```

## ✅ What's Fixed

| Issue | Status | How to Verify |
|-------|--------|---------------|
| Compilation errors | ✅ Fixed | `flutter analyze` shows no errors |
| APK build fails | ✅ Fixed | APK builds without Gradle errors |
| Web build fails | ✅ Fixed | Web compiles successfully |
| iOS build fails | ✅ Fixed | iOS builds without errors |
| Login not working | ✅ Fixed | Users can register and login |
| Leaderboard empty | ✅ Fixed | Shows users sorted by wins |
| Statistics not saved | ✅ Fixed | Game results save to database |
| No coins for wins | ✅ Fixed | Coins awarded after games |
| Hints not working | ✅ Fixed | Can buy and use hints |
| Multiplayer lobby empty | ✅ Fixed | Can create and join sessions |
| PayPal not opening | ✅ Fixed | Opens sandbox checkout |
| Ads not respecting PRO | ✅ Fixed | PRO users see no ads |

## 🧪 Quick Test Checklist

1. **Database Connection**:
   ```
   - [ ] Open the app
   - [ ] Click "Register" 
   - [ ] Create account
   - [ ] Login succeeds
   ```

2. **Game Functions**:
   ```
   - [ ] Play vs AI
   - [ ] Win a game
   - [ ] Check coins increased
   - [ ] View statistics updated
   ```

3. **Leaderboard**:
   ```
   - [ ] Navigate to Leaderboard
   - [ ] See list of players
   - [ ] Your username appears
   ```

4. **Multiplayer**:
   ```
   - [ ] Click "Multiplayer"
   - [ ] Click "Create Game"
   - [ ] Session appears in lobby
   - [ ] Other players can join
   ```

5. **Shop/PayPal**:
   ```
   - [ ] Go to Shop
   - [ ] Select PRO subscription
   - [ ] PayPal opens
   - [ ] Shows sandbox.paypal.com
   ```

## 🚨 Common Problems

### Problem: "Database not configured"
**Solution**: You forgot step 1.3 - Add NEON_DATABASE_URL to Netlify

### Problem: Multiplayer lobby empty
**Solution**: 
1. Check Netlify deploy succeeded
2. Verify NEON_DATABASE_URL is set
3. Try creating a session first

### Problem: PayPal doesn't open
**Solution**: 
1. Check `payment_config.dart` has valid credentials
2. Make sure `useSandbox = true` for testing

### Problem: APK build fails
**Solution**:
```bash
cd tokerrgjik_mobile
flutter clean
flutter pub get
flutter build apk --release
```

### Problem: Can't login
**Solution**:
1. Check Netlify function logs
2. Verify database connection string is correct
3. Try guest login first

## 📱 Testing on Real Devices

### Android:
```bash
# After building APK
adb install build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

### iOS:
```bash
# After building IPA
# Use Xcode or TestFlight to install
```

### Web:
```bash
# Deploy to Netlify
netlify deploy --prod --dir=tokerrgjik_mobile/build/web
```

## 📞 Need Help?

If something doesn't work:

1. **Check Netlify Logs**:
   - Netlify Dashboard → Functions → View logs
   
2. **Check Browser Console**:
   - Press F12 → Console tab
   
3. **Check Flutter Logs**:
   - `flutter run` shows live logs

4. **Verify Database**:
   - Neon Console → SQL Editor
   - Run: `SELECT * FROM users LIMIT 5;`
   - Should show users

## 🎓 What You Learned

- How to connect Flutter to PostgreSQL
- How to use Netlify Functions as backend
- How to integrate PayPal payments
- How to handle multiplayer game sessions
- How to manage user authentication
- How to deploy web apps

Good luck! 🍀
