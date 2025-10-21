# 🎮 TokerrGjik - Loja tradicionale shqiptare

Aplikacion mobil për lojën tradicionale shqiptare TokerrGjik.

## 📱 Platformat
- ✅ Android (APK)
- ✅ iOS (IPA)
- ✅ Web (HTML)

## 🚀 Si të Ekzekutosh

### Web
```bash
cd tokerrgjik_mobile
flutter build web --release
```

### Android (APK)
```bash
cd tokerrgjik_mobile
flutter build apk --release --split-per-abi
```

### iOS (IPA)
```bash
cd tokerrgjik_mobile
flutter build ios --release --no-codesign
```

## 🗄️ Database (Neon PostgreSQL)

1. Shko te https://console.neon.tech/
2. Hap SQL Editor
3. Kopjo dhe ekzekuto `scripts/init_neon_database.sql`
4. Kopjo connection string
5. Shko te Netlify → Environment Variables
6. Shto `NEON_DATABASE_URL=your_connection_string`
7. Trigger deploy

## �� PayPal (Sandbox Mode)

PayPal është në sandbox mode për testing.

## 🎨 Karakteristikat

- 🤖 Luaj kundër AI
- 👥 Luaj me shokët (online/offline)
- 🪙 Fito monedha
- 🎨 Zhblloko tema
- 🏆 Renditje (Leaderboard)
- 💎 PRO Membership
- 📊 Statistika

## 👨‍💻 Zhvilluar nga

**Shaban Ejupi**  
Kosovë 🇽🇰

## 📄 Licensa

© 2025 Shaban Ejupi. All rights reserved.
