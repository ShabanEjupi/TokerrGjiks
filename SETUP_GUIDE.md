# 🔐 API Keys & Service Setup Guide

This guide will help you set up all the necessary API keys and services for the TokerrGjiks app.

## 📋 Table of Contents
1. [GitHub Secrets Setup](#github-secrets-setup)
2. [AdMob Configuration](#admob-configuration)
3. [Netlify Deployment](#netlify-deployment)
4. [Stripe Payment Setup](#stripe-payment-setup)
5. [Sentry Error Tracking](#sentry-error-tracking)
6. [Backend Server Setup](#backend-server-setup)
7. [Analytics & Other Services](#analytics--other-services)

---

## 🔒 GitHub Secrets Setup

To make GitHub Actions work, you need to add your API keys as secrets:

1. Go to your repository: https://github.com/ShabanEjupi/TokerrGjiks
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add the following:

### Required Secrets:

```bash
# AdMob Secrets (You already have these from your students)
ADMOB_APP_ID_ANDROID = "ca-app-pub-8491001524308476~9753001043"
ADMOB_APP_ID_IOS = "ca-app-pub-8491001524308476~5326670873"
ADMOB_BANNER_ANDROID = "ca-app-pub-8491001524308476/7116257088"
ADMOB_BANNER_IOS = "ca-app-pub-8491001524308476/4681665438"
ADMOB_INTERSTITIAL_ANDROID = "ca-app-pub-8491001524308476/9581997693"
ADMOB_INTERSTITIAL_IOS = "ca-app-pub-8491001524308476/5179718251"
ADMOB_REWARDED_ANDROID = "ca-app-pub-8491001524308476/8248347684"
ADMOB_REWARDED_IOS = "ca-app-pub-8491001524308476/3041280706"
```

### Quick Command to Add Secrets via GitHub CLI:

```bash
# AdMob Android
gh secret set ADMOB_APP_ID_ANDROID -b "ca-app-pub-8491001524308476~9753001043"
gh secret set ADMOB_BANNER_ANDROID -b "ca-app-pub-8491001524308476/7116257088"
gh secret set ADMOB_INTERSTITIAL_ANDROID -b "ca-app-pub-8491001524308476/9581997693"
gh secret set ADMOB_REWARDED_ANDROID -b "ca-app-pub-8491001524308476/8248347684"

# AdMob iOS
gh secret set ADMOB_APP_ID_IOS -b "ca-app-pub-8491001524308476~5326670873"
gh secret set ADMOB_BANNER_IOS -b "ca-app-pub-8491001524308476/4681665438"
gh secret set ADMOB_INTERSTITIAL_IOS -b "ca-app-pub-8491001524308476/5179718251"
gh secret set ADMOB_REWARDED_IOS -b "ca-app-pub-8491001524308476/3041280706"

# Optional: Add other service keys when you get them
gh secret set STRIPE_PUBLISHABLE_KEY -b "your-key-here"
gh secret set SENTRY_DSN -b "your-dsn-here"
gh secret set NEW_RELIC_LICENSE_KEY -b "your-key-here"
```

---

## 📱 AdMob Configuration

✅ **Already configured!** Your students provided:
- App IDs for Android & iOS
- Banner, Interstitial, and Rewarded ad unit IDs
- Rewarded ads now give **2 points** per watch

### Testing AdMob Locally:
The app uses your production IDs. When you run the app locally, ads will show in test mode initially.

---

## 🌐 Netlify Deployment

### Option 1: Link via Netlify CLI (Recommended)

```bash
# Login to Netlify
netlify login

# Link to existing site or create new one
netlify link

# Deploy manually
netlify deploy --prod

# Or let GitHub Actions handle it automatically
```

### Option 2: Connect via Netlify Dashboard

1. Go to https://app.netlify.com
2. Click **Add new site** → **Import an existing project**
3. Connect your GitHub repository: `ShabanEjupi/TokerrGjiks`
4. Netlify will auto-detect the `netlify.toml` configuration
5. Click **Deploy site**

**Note:** The `netlify.toml` file is already configured to:
- Build the Flutter web app with CanvasKit renderer
- Serve from `tokerrgjik_mobile/build/web`
- Handle routing for single-page application
- Set security headers and caching

---

## 💳 Stripe Payment Setup

If you want to add in-app purchases or payments:

1. **Create Stripe Account:** https://dashboard.stripe.com/register
2. **Get API Keys:** https://dashboard.stripe.com/apikeys
   - Copy **Publishable key** (starts with `pk_test_` or `pk_live_`)
   - Copy **Secret key** (starts with `sk_test_` or `sk_live_`)

3. **Add to your local config:**
   ```bash
   # Edit tokerrgjik_mobile/lib/config/api_keys.dart
   # Replace the Stripe keys
   ```

4. **Add to GitHub Secrets:**
   ```bash
   gh secret set STRIPE_PUBLISHABLE_KEY -b "pk_test_your_key"
   gh secret set STRIPE_SECRET_KEY -b "sk_test_your_key"
   ```

---

## 🐛 Sentry Error Tracking

Track crashes and errors in production:

1. **Create Sentry Account:** https://sentry.io/signup/
2. **Create a new Flutter project**
3. **Get DSN:** https://sentry.io/settings/[your-org]/projects/[your-project]/keys/
4. **Add DSN to config:**
   ```bash
   # Via command:
   gh secret set SENTRY_DSN -b "https://xxx@oXXX.ingest.sentry.io/XXX"
   
   # Or manually edit api_keys.dart for local development
   ```

The app already has Sentry integrated in `lib/services/sentry_service.dart`!

---

## 🖥️ Backend Server Setup

You have multiple options for hosting:

### Option 1: DigitalOcean App Platform (Recommended for students)
- Free $200 credit via GitHub Education Pack
- Easy deployment from GitHub
- Managed database included

### Option 2: Railway.app
- Free tier available
- Simple deployment
- Good for Node.js/Express backends

### Option 3: Heroku
- Free tier (with credit card verification)
- Easy to use

### Setup Backend URLs:
```bash
# Local development
SERVER_URL=http://10.0.2.2:3000  # Android emulator
WEBSOCKET_URL=ws://10.0.2.2:3000

# Production
SERVER_URL_PROD=https://your-app.digitalocean.app
WEBSOCKET_URL_PROD=wss://your-app.digitalocean.app
```

---

## 📊 Analytics & Other Services

### New Relic APM
1. Sign up: https://newrelic.com/signup
2. Get license key from dashboard
3. Add to secrets: `gh secret set NEW_RELIC_LICENSE_KEY -b "your-key"`

### DevCycle Feature Flags
1. Sign up: https://devcycle.com
2. Create project and get SDK key
3. Add to secrets: `gh secret set DEVCYCLE_SDK_KEY -b "your-key"`

### Blockchair API (Blockchain Data)
1. Get API key: https://blockchair.com/api
2. Add to secrets: `gh secret set BLOCKCHAIR_API_KEY -b "your-key"`

### Icons8 (If using their API)
1. Get API key: https://icons8.com/api
2. Add to secrets: `gh secret set ICONS8_API_KEY -b "your-key"`

---

## 🚀 Quick Start Commands

Run these commands in your terminal to set up everything:

```bash
# Navigate to project
cd /workspaces/TokerrGjiks

# Set up GitHub secrets for AdMob (already have the keys)
gh secret set ADMOB_APP_ID_ANDROID -b "ca-app-pub-8491001524308476~9753001043"
gh secret set ADMOB_APP_ID_IOS -b "ca-app-pub-8491001524308476~5326670873"
gh secret set ADMOB_BANNER_ANDROID -b "ca-app-pub-8491001524308476/7116257088"
gh secret set ADMOB_BANNER_IOS -b "ca-app-pub-8491001524308476/4681665438"
gh secret set ADMOB_INTERSTITIAL_ANDROID -b "ca-app-pub-8491001524308476/9581997693"
gh secret set ADMOB_INTERSTITIAL_IOS -b "ca-app-pub-8491001524308476/5179718251"
gh secret set ADMOB_REWARDED_ANDROID -b "ca-app-pub-8491001524308476/8248347684"
gh secret set ADMOB_REWARDED_IOS -b "ca-app-pub-8491001524308476/3041280706"

# Login to Netlify and deploy
netlify login
netlify link
netlify deploy --prod

# Optional: Add other secrets as you get them
# gh secret set STRIPE_PUBLISHABLE_KEY -b "pk_test_..."
# gh secret set SENTRY_DSN -b "https://..."
# gh secret set NEW_RELIC_LICENSE_KEY -b "..."
```

---

## ✅ Verification

After setting up:

1. **Check GitHub Actions:** https://github.com/ShabanEjupi/TokerrGjiks/actions
   - Should build successfully now with secrets
   
2. **Check Netlify:** https://app.netlify.com
   - Web app should be deployed
   
3. **Test the app:**
   - Download APK from GitHub Actions artifacts
   - Visit Netlify URL for web version

---

## 📝 Notes

- **Rewarded ads:** Now give **2 points** per watch (updated in `ad_service.dart`)
- **Favicons:** Generated from `tokerrgjik_icon.png` and added to web app
- **API Keys:** Stored in `api_keys.dart` (gitignored for security)
- **CI/CD:** GitHub Actions auto-generates `api_keys.dart` from secrets
- **Netlify:** Auto-deploys web app on every push to main

---

## 🆘 Need Help?

If you encounter issues:
1. Check GitHub Actions logs for build errors
2. Verify all secrets are set correctly
3. Ensure Netlify is connected to the repository
4. Check that `netlify.toml` is in the root directory

**Current Status:**
- ✅ AdMob configured with 2-point rewards
- ✅ Favicons generated
- ✅ GitHub Actions fixed with API key generation
- ✅ Netlify configuration ready
- ⏳ Waiting for you to add secrets and deploy
