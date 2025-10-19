# 🔄 NETLIFY DEPLOYMENT GUIDE

## ⚡ Quick Overview

Your TokerrGjiks app is now configured to deploy **pre-built Flutter web files** to Netlify. This avoids the complexity of building Flutter in Netlify's environment.

---

## 📦 How It Works

1. **Build Locally** - You build the Flutter web app on your development machine
2. **Commit Built Files** - The `build/web/` directory is committed to Git
3. **Netlify Deploys** - Netlify just serves the pre-built files (no Flutter build needed)

---

## 🚀 Deployment Workflow

### When You Make Code Changes:

```bash
# 1. Navigate to Flutter project
cd tokerrgjik_mobile

# 2. Build for web (this compiles your Dart code to JavaScript)
flutter build web --release

# 3. Go back to repository root
cd ..

# 4. Commit all changes including built files
git add -A
git commit -m "Your commit message describing changes"
git push origin main

# 5. Netlify automatically deploys in ~1 minute
```

---

## ✅ What's Already Done

- ✅ `.gitignore` updated to include `build/web/` directory
- ✅ `netlify.toml` configured to use pre-built files
- ✅ Initial web build committed to repository
- ✅ Netlify configured to skip Flutter build process

---

## 🔧 Netlify Configuration

The `netlify.toml` file now uses:

```toml
[build]
  command = "echo 'Using pre-built Flutter web files'"
  publish = "tokerrgjik_mobile/build/web"
  functions = "netlify/functions"
```

This means:
- **No Flutter SDK needed** on Netlify
- **Fast deployments** (~1 minute vs 5-10 minutes)
- **No build errors** from missing Flutter dependencies

---

## 📝 Development Workflow

### Making Changes to Dart/Flutter Code:

1. Edit files in `tokerrgjik_mobile/lib/`
2. Test locally:
   ```bash
   cd tokerrgjik_mobile
   flutter run -d chrome  # or flutter run -d linux
   ```
3. When ready to deploy:
   ```bash
   flutter build web --release
   cd ..
   git add -A
   git commit -m "Description of changes"
   git push origin main
   ```

### Making Changes to Netlify Functions:

1. Edit files in `netlify/functions/`
2. Test locally (optional):
   ```bash
   cd netlify/functions
   npm install  # if dependencies changed
   cd ../..
   ```
3. Commit and push:
   ```bash
   git add netlify/functions/
   git commit -m "Update API functions"
   git push origin main
   ```

**Note:** Function changes deploy automatically, no build needed!

---

## 🎯 Database Setup (One-Time)

Students still need to:

1. **Run SQL Schema** in Neon Console
   - Open `database_schema.sql`
   - Copy and run in Neon SQL Editor

2. **Set Environment Variable** in Netlify
   - Add `NEON_DATABASE_URL` with your connection string
   - Settings → Environment variables

3. **Install Function Dependencies**
   ```bash
   cd netlify/functions
   npm install
   cd ../..
   git add netlify/functions/package-lock.json
   git commit -m "Add function dependencies"
   git push origin main
   ```

---

## 🐛 Troubleshooting

### Issue: Netlify build fails with "flutter: command not found"
**Solution:** Make sure your latest code is pushed. The `netlify.toml` should have:
```toml
command = "echo 'Using pre-built Flutter web files'"
```

### Issue: Web app shows old version after deploying
**Solution:** 
1. Rebuild locally: `flutter build web --release`
2. Commit: `git add build/web/ && git commit -m "Rebuild web app"`
3. Push: `git push origin main`

### Issue: Changes not appearing on website
**Solution:**
- Clear browser cache (Ctrl+Shift+Delete)
- Or hard refresh (Ctrl+F5)
- Check Netlify deploy logs to ensure deployment succeeded

### Issue: Functions not working
**Solution:**
1. Check Netlify Functions tab for errors
2. Verify `NEON_DATABASE_URL` is set
3. Check function logs for specific error messages

---

## 📊 Deployment Status

Check deployment status at:
- **Netlify Dashboard:** https://app.netlify.com/
- **Live Site:** https://tokerrgjik.netlify.app/
- **API Health:** https://tokerrgjik.netlify.app/.netlify/functions/health

---

## 🔄 Update Frequency

**Recommended:**
- Build and deploy after each significant feature/fix
- Rebuild at least daily if actively developing
- Always rebuild before asking students to test

**Why?** The web version serves the compiled JavaScript files. Without rebuilding, code changes won't appear online.

---

## ⚙️ Advanced: CI/CD Alternative (Optional)

If you want automatic builds, you can use GitHub Actions:

1. Create `.github/workflows/deploy.yml`
2. Configure Flutter build action
3. Auto-deploy on push

**However**, the current manual approach is simpler and sufficient for your use case.

---

## 📚 Related Documentation

- **DATABASE_SETUP_GUIDE.md** - Complete database setup instructions
- **QUICK_START.md** - 5-minute quickstart for students
- **IMPLEMENTATION_SUMMARY.md** - Technical details of all fixes

---

## ✅ Checklist for Each Deployment

- [ ] Code changes tested locally
- [ ] `flutter build web --release` completed successfully
- [ ] All files committed (`git add -A`)
- [ ] Commit has descriptive message
- [ ] Pushed to GitHub (`git push origin main`)
- [ ] Netlify deployment shows "Published" (check dashboard)
- [ ] Tested on live site (https://tokerrgjik.netlify.app/)

---

**Last Updated:** October 19, 2025
**Status:** ✅ Active and Working
