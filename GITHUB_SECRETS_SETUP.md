# 🔐 GitHub Secrets Setup for Cryptolens

## ⚠️ CRITICAL: Set These Secrets BEFORE Builds Will Work

Your GitHub Actions builds need these 3 secrets to compile successfully:

### Required Secrets

1. **CRYPTOLENS_PRODUCT_ID**
   - Your Cryptolens product ID (numeric)
   - Example: `12345`

2. **CRYPTOLENS_ACCESS_TOKEN**
   - Your Cryptolens API access token
   - Example: `WyI4NjQzIiwiU0...` (long string)

3. **CRYPTOLENS_RSA_PUBLIC_KEY**
   - Your Cryptolens RSA public key (XML format)
   - Example: `<RSAKeyValue><Modulus>sGbvxw...`

---

## 📝 How to Add Secrets to GitHub

### Method 1: GitHub Web UI

1. Go to: https://github.com/ShabanEjupi/TokerrGjiks/settings/secrets/actions

2. Click **"New repository secret"**

3. Add each secret:
   ```
   Name: CRYPTOLENS_PRODUCT_ID
   Value: [paste your product ID]
   ```

4. Repeat for `CRYPTOLENS_ACCESS_TOKEN` and `CRYPTOLENS_RSA_PUBLIC_KEY`

### Method 2: GitHub CLI (Automated Script)

Run this script to set all secrets at once:

```bash
# Run from the repository root
./scripts/setup_github_secrets.sh
```

It will prompt you to paste each secret value.

---

## 🧪 Testing Without Cryptolens (Development Mode)

If you don't have Cryptolens keys yet, the app runs in **development mode**:

- ✅ All features unlocked
- ✅ No license checks
- ⚠️ Shows "Development Mode" in Settings

To build locally without secrets:

```bash
cd tokerrgjik_mobile
flutter build apk --release
# Cryptolens will default to development mode
```

---

## ✅ Verify Setup

After adding secrets, check:

1. Go to: https://github.com/ShabanEjupi/TokerrGjiks/actions
2. Find the latest workflow run
3. Check if builds complete without errors
4. Download APK/IPA artifacts to test

---

## 🔒 Security Notes

✅ **GOOD:**
- Secrets stored in GitHub (encrypted)
- Keys injected at build time via `--dart-define`
- Never committed to repository

❌ **BAD (Don't do this):**
- ~~Hardcode keys in code~~
- ~~Store in .env files~~
- ~~Commit keys to Git~~

---

## 📞 Get Cryptolens Keys

1. Sign up: https://cryptolens.io/
2. Create a new product: "tokerrgjik"
3. Get your Product ID, Access Token, and RSA Public Key
4. Add them to GitHub Secrets (see above)

---

## 🚀 Next Steps

1. ✅ Set GitHub Secrets (3 keys)
2. ✅ Push code (triggers build automatically)
3. ✅ Wait for GitHub Actions to complete
4. ✅ Download APK/IPA from Artifacts
5. ✅ Test English translation on device

**Current Status:** Code is pushed, waiting for you to add secrets!
