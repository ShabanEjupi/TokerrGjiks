# CI/CD Setup Guide

## Overview
This project uses two CI/CD platforms:
1. **GitHub Actions** - Free for public repos, integrated with GitHub
2. **Codemagic** - Specialized for mobile apps, offers free tier for students

---

## GitHub Actions Setup

### ✅ What's Configured
The `.github/workflows/flutter-build.yml` workflow automatically:
- Builds **Web** version on every push
- Builds **Android APK** and **App Bundle**
- Runs **tests** and **code analysis**
- Deploys to **GitHub Pages** (main branch only)
- Creates downloadable artifacts

### 🚀 Enable GitHub Pages Deployment

1. Go to your repository on GitHub
2. Click **Settings** → **Pages**
3. Under "Build and deployment":
   - **Source**: Deploy from a branch
   - **Branch**: `gh-pages` / `root`
4. Click **Save**

After the next push to `main`, your web app will be live at:
```
https://<your-username>.github.io/<repo-name>/
```

### 📦 Download Build Artifacts

After each push, GitHub Actions will build your app:
1. Go to **Actions** tab in your repo
2. Click on the latest workflow run
3. Scroll down to **Artifacts** section
4. Download:
   - `web-build` - Web version
   - `android-apk` - Android APK for testing
   - `android-appbundle` - AAB for Play Store

### 🔧 Workflow Triggers
Builds run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` branch

---

## Codemagic Setup

### 📝 Initial Setup

1. **Sign up**: Go to [codemagic.io](https://codemagic.io)
   - Use your GitHub account
   - Apply for **GitHub Student Developer Pack** for free credits

2. **Connect Repository**:
   - Click "Add application"
   - Select your repository
   - Codemagic will detect the `codemagic.yaml` file

3. **Configure Environment Variables** (Optional):
   - For Android: Add Google Play credentials
   - For iOS: Add App Store Connect credentials
   - Go to **App Settings** → **Environment variables**

### 🎯 Available Workflows

The `codemagic.yaml` file includes 4 workflows:

#### 1. **android-workflow**
- Builds Android APK and App Bundle
- Runs tests and analysis
- Artifacts: APK + AAB files

#### 2. **ios-workflow**
- Builds iOS app (requires Mac)
- Runs tests and analysis
- Artifacts: .app file

#### 3. **web-workflow**
- Builds web version
- Fastest workflow (Linux)
- Artifacts: Web build folder

#### 4. **all-platforms** (Recommended)
- Builds Android, iOS, and Web
- Runs on push to `main` or `develop`
- Complete build pipeline

### 🚀 Start a Build

**Manual Start**:
1. Go to Codemagic dashboard
2. Select your app
3. Choose a workflow
4. Click "Start new build"

**Automatic Triggers**:
- Configured in `codemagic.yaml`
- Pushes to `main` or `develop` trigger `all-platforms` workflow

### 📧 Notifications

Update the email in `codemagic.yaml`:
```yaml
publishing:
  email:
    recipients:
      - your-email@example.com  # ← Change this
```

Optional: Add Slack notifications (requires Slack integration).

---

## Comparison: GitHub Actions vs Codemagic

| Feature | GitHub Actions | Codemagic |
|---------|---------------|-----------|
| **Free Tier** | 2,000 min/month (public repos) | 500 build min/month |
| **Student Benefits** | Unlimited (public repos) | More credits with Student Pack |
| **iOS Builds** | Limited (requires macOS runner) | Full support |
| **Android Builds** | ✅ Full support | ✅ Full support |
| **Web Builds** | ✅ Fast | ✅ Fast |
| **GitHub Integration** | Native | Via webhook |
| **App Store Publishing** | Manual | Automatic |
| **Play Store Publishing** | Manual | Automatic |
| **Build Time** | ~5-10 min | ~5-15 min |

### 💡 Recommended Strategy

**For Students (with GitHub Education Pack)**:
- **GitHub Actions**: Use for Web builds and testing
- **Codemagic**: Use for iOS builds and store publishing

**Workflow**:
1. Push code → GitHub Actions runs tests
2. Merge to `main` → Both platforms build
3. Download APK/AAB from GitHub Actions for testing
4. Use Codemagic for final iOS/Android store releases

---

## Environment Setup

### Required Secrets (for Production)

#### GitHub Actions (Store Publishing)
Add these in **Settings** → **Secrets and variables** → **Actions**:

- `ANDROID_KEYSTORE_BASE64` - Your keystore file (base64 encoded)
- `ANDROID_KEYSTORE_PASSWORD` - Keystore password
- `ANDROID_KEY_ALIAS` - Key alias
- `ANDROID_KEY_PASSWORD` - Key password

#### Codemagic (Store Publishing)
Add these in **App Settings** → **Environment variables**:

**For Android (Google Play)**:
- `GOOGLE_PLAY_JSON_KEY` - Service account JSON

**For iOS (App Store)**:
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`

---

## Troubleshooting

### GitHub Actions Issues

**Build fails on tests**:
```bash
# Run locally to debug
cd tokerrgjik_mobile
flutter test
```

**Web build fails**:
```bash
# Check web dependencies
flutter build web --release
```

### Codemagic Issues

**Workflow not detected**:
- Ensure `codemagic.yaml` is in repository root
- Check YAML syntax at [yamllint.com](http://yamllint.com)

**iOS build requires signing**:
- For testing: Use `--no-codesign` flag (already configured)
- For release: Add certificates in Codemagic settings

---

## Next Steps

### 1. Push to GitHub
```bash
cd /workspaces/TokerrGjiks
git add .github/workflows/flutter-build.yml codemagic.yaml CI-CD-SETUP.md
git commit -m "Add CI/CD: GitHub Actions + Codemagic"
git push origin main
```

### 2. Enable GitHub Pages
- Go to repo Settings → Pages
- Select `gh-pages` branch
- Your app will be live!

### 3. Connect Codemagic
- Sign up at codemagic.io
- Connect GitHub repo
- Start first build

### 4. Monitor Builds
- **GitHub**: Check **Actions** tab
- **Codemagic**: Check dashboard

---

## Build Status Badges

Add to your `README.md`:

```markdown
![GitHub Actions](https://github.com/<username>/<repo>/workflows/Flutter%20Build%20&%20Deploy/badge.svg)
[![Codemagic build status](https://api.codemagic.io/apps/<app-id>/status_badge.svg)](https://codemagic.io/apps/<app-id>/latest_build)
```

Replace `<username>`, `<repo>`, and `<app-id>` with your values.

---

## Cost Optimization

### GitHub Actions (Free Tier)
- **2,000 minutes/month** for public repos
- **Storage**: 500 MB (artifacts auto-delete after 7 days)
- **Tip**: Use `flutter build web` (fastest, ~3 min)

### Codemagic (Free Tier)
- **500 build minutes/month**
- **Student Pack**: +500 extra minutes
- **Tip**: Use `web-workflow` for quick tests, `all-platforms` for releases

### Recommended Build Strategy
- **Every push**: GitHub Actions (web + tests)
- **Weekly releases**: Codemagic (all platforms)
- **Store releases**: Codemagic (automated publishing)

---

## Support

- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Codemagic Docs**: https://docs.codemagic.io
- **Flutter CI/CD**: https://docs.flutter.dev/deployment/cd

**Questions?** Check the workflow files for comments and configuration details.
