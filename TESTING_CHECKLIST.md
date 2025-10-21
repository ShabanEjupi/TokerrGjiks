# 🎯 TESTING CHECKLIST - English Translation & All Features

## ✅ What Was Fixed

### 1. **Compilation Error** ✅ FIXED
- **Problem:** `CrossAxisStart` typo causing all builds to fail
- **Solution:** Already corrected in code (pushed to GitHub)
- **Status:** Waiting for GitHub Actions build to complete

### 2. **Cryptolens Security** ✅ FIXED
- **Problem:** Keys in .env file (you can access via terminal)
- **Solution:** Keys now use `--dart-define` with GitHub Secrets
- **Status:** Needs you to add 3 secrets to GitHub (see GITHUB_SECRETS_SETUP.md)

### 3. **English Translation** ✅ IMPLEMENTED
- **Problem:** Exchange students can't understand Albanian
- **Solution:** Full bilingual system with 100+ translations
- **Status:** Ready to test

---

## 📋 Step-by-Step Testing Plan

### Phase 1: Verify Build Success (Do This First!)

1. **Check GitHub Actions:**
   - URL: https://github.com/ShabanEjupi/TokerrGjiks/actions
   - Look for the latest "Build Android & iOS Apps" workflow
   - ✅ Should show green checkmark (no CrossAxisStart error)
   - ⚠️ If red: Build failed, check error logs

2. **Add GitHub Secrets (If Not Already Done):**
   - Go to: https://github.com/ShabanEjupi/TokerrGjiks/settings/secrets/actions
   - Add these 3 secrets:
     - `CRYPTOLENS_PRODUCT_ID`
     - `CRYPTOLENS_ACCESS_TOKEN`
     - `CRYPTOLENS_RSA_PUBLIC_KEY`
   - See: `GITHUB_SECRETS_SETUP.md` for instructions

3. **Download APK:**
   - Go to successful GitHub Actions run
   - Download "android-apks" artifact
   - Extract the APK file
   - Install on Android device

---

### Phase 2: Test English Translation (Exchange Students)

#### Test 1: Change Language to English

1. Open the app
2. Go to **Settings** screen
3. Find **Language** section
4. Select **English (EN)** radio button
5. ✅ **Expected:** All UI text changes to English immediately

#### Test 2: Verify All Screens Show English

| Screen | Albanian Text | English Text | ✅ |
|--------|---------------|--------------|---|
| Home | "Lojë e re" | "New game" | ☐ |
| Home | "Rregullat" | "Rules" | ☐ |
| Home | "Statistikat" | "Statistics" | ☐ |
| Home | "Lojë miqësore" | "Friendly game" | ☐ |
| Game | "Turni yt" | "Your turn" | ☐ |
| Game | "Turni i kundërshtarit" | "Opponent's turn" | ☐ |
| Game | "Nuk ka lëvizje të vlefshme" | "No valid moves" | ☐ |
| Game | "Përdor një ndihmë?" | "Use a hint?" | ☐ |
| Game | "Do ju kushton 10 monedha" | "Will cost you 10 coins" | ☐ |
| Game | "Ti fitove!" | "You won!" | ☐ |
| Game | "Ti humbët!" | "You lost!" | ☐ |
| Game | "Barazim!" | "Draw!" | ☐ |
| Profile | "Profili im" | "My profile" | ☐ |
| Profile | "Shkëmbej monedhat" | "Exchange coins" | ☐ |
| Profile | "Arritje" | "Achievements" | ☐ |
| Leaderboard | "Klasifikimi" | "Leaderboard" | ☐ |
| Leaderboard | "Fitore" | "Wins" | ☐ |
| Leaderboard | "Monedha" | "Coins" | ☐ |
| Settings | "Cilësimet" | "Settings" | ☐ |
| Settings | "Gjuha" | "Language" | ☐ |
| Settings | "Informacion licence" | "License information" | ☐ |

#### Test 3: Play Full Game in English

1. Start a new game (against AI)
2. Make moves
3. Request a hint (should show English popup)
4. Win/lose the game
5. ✅ **Expected:** All messages, dialogs, buttons in English

#### Test 4: Check Hint System (English)

1. Start a game
2. Click hint button
3. ✅ **Expected:** English message: "Use a hint? Will cost you 10 coins"
4. Accept hint
5. ✅ **Expected:** Pulsing white indicator appears on board
6. ✅ **Expected:** English hint text shown (e.g., "Capture opponent's piece")

#### Test 5: Persistence Test

1. Set language to English
2. Close the app completely
3. Reopen the app
4. ✅ **Expected:** Still shows English (language saved)

---

### Phase 3: Test Dual-Save System

#### Test 1: Local Save

1. Play a game
2. Turn OFF internet/WiFi
3. Finish the game
4. ✅ **Expected:** Game result saved locally (no errors)
5. Check profile → coins should update

#### Test 2: Cloud Backup

1. Turn ON internet
2. Play a game
3. Finish the game
4. ✅ **Expected:** Game saved to both:
   - Local (SharedPreferences)
   - Cloud (Neon database)
5. Check console logs for "Synced to cloud" message

#### Test 3: Offline → Online Sync

1. Turn OFF internet
2. Play 3 games
3. Turn ON internet
4. Wait 10 seconds
5. ✅ **Expected:** Old games sync to cloud automatically
6. Check console for "Background sync" messages

---

### Phase 4: Test Cryptolens License Protection

#### Test 1: Development Mode (No Secrets)

1. Build APK without GitHub Secrets
2. Open Settings
3. Tap "License information"
4. ✅ **Expected:** Shows "Development Mode - All features unlocked"

#### Test 2: Production Mode (With Secrets)

1. Add GitHub Secrets (see Phase 1)
2. Rebuild APK from GitHub Actions
3. Install APK
4. Open Settings → License information
5. ✅ **Expected:** Shows license status (Active/Inactive)

---

### Phase 5: Regression Testing (Make Sure Nothing Broke)

| Feature | Test | ✅ |
|---------|------|---|
| Login | Can create new account | ☐ |
| Login | Can login with existing account | ☐ |
| Game | Board centered properly | ☐ |
| Game | Can make valid moves | ☐ |
| Game | Shilevek bonus works | ☐ |
| Game | Coins awarded after win | ☐ |
| Hints | White pulsing indicator appears | ☐ |
| Hints | Hint text shows | ☐ |
| Hints | Costs 10 coins | ☐ |
| Profile | Avatar upload works | ☐ |
| Profile | Stats display correctly | ☐ |
| Leaderboard | Shows top players | ☐ |
| Multiplayer | Can create lobby | ☐ |
| Multiplayer | Can join lobby | ☐ |

---

## 🐛 If Something Breaks

### Build Fails on GitHub Actions:
- Check error logs in workflow
- Verify GitHub Secrets are set
- Make sure all 3 secrets have correct names

### Translation Not Working:
- Check console logs for "Translations loaded"
- Verify `translations.dart` exists in services folder
- Try restarting app after language change

### Dual-Save Not Working:
- Check console for "Synced to cloud" messages
- Verify Neon database is online
- Check network connectivity

### Cryptolens Not Working:
- Make sure GitHub Secrets are set
- Check if APK was built with secrets (production build)
- Development builds work without secrets

---

## 📞 Quick Help Commands

```bash
# Build APK locally (without Cryptolens)
cd tokerrgjik_mobile
flutter clean
flutter pub get
flutter build apk --release

# Build with Cryptolens (production)
flutter build apk --release \
  --dart-define=CRYPTOLENS_PRODUCT_ID="12345" \
  --dart-define=CRYPTOLENS_ACCESS_TOKEN="your_token" \
  --dart-define=CRYPTOLENS_RSA_PUBLIC_KEY="your_key"

# Check GitHub Actions status
gh run list --limit 5

# View latest build logs
gh run view --log
```

---

## ✅ Success Criteria

- ☐ GitHub Actions build passes (green checkmark)
- ☐ APK installs on Android device
- ☐ Can switch between Albanian and English
- ☐ All screens show English text correctly
- ☐ Exchange students can understand the app
- ☐ Games save locally and to cloud
- ☐ License protection working (if secrets added)
- ☐ No compilation errors
- ☐ No crashes

---

**Current Status:** 
✅ Code pushed to GitHub  
⏳ Waiting for you to add GitHub Secrets  
⏳ Waiting for GitHub Actions build to complete  
⏳ Ready for testing once build succeeds
