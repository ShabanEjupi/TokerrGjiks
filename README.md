# TokerrGjiks - Multiplayer Tic-Tac-Toe Game

A Flutter-based multiplayer Tic-Tac-Toe game with online features, leaderboard, friends system, and in-app purchases.

## 🎮 Features

- **Single Player**: Play against AI with 3 difficulty levels
- **Multiplayer**: Real-time online matches with friends
- **Leaderboard**: Global ranking system
- **Friends System**: Add friends and challenge them
- **Shop**: Purchase coins and PRO membership via PayPal
- **Achievements**: Unlock rewards for accomplishments
- **Customization**: Avatars and profile editing

## 🚀 Quick Start

### Prerequisites
- Flutter SDK installed
- Neon PostgreSQL database account
- Netlify account for hosting
- PayPal Developer account (for payments)

### Setup Instructions

#### 1. Clone the Repository
```bash
git clone https://github.com/ShabanEjupi/TokerrGjiks.git
cd TokerrGjiks
```

#### 2. Configure Database (REQUIRED)
1. Create a database at [Neon.tech](https://neon.tech/)
2. Get your connection string from Neon dashboard
3. Add to Netlify environment variables:
   - Go to: Netlify Dashboard → Site Settings → Environment Variables
   - Add variable: `NETLIFY_DATABASE_URL`
   - Value: Your Neon connection string (e.g., `postgresql://user:pass@ep-xyz.region.aws.neon.tech/neondb?sslmode=require`)
4. Run the database schema:
   - Go to Neon SQL Editor
   - Execute the SQL commands to create tables (users, game_history, friends, game_sessions, achievements)

#### 3. Configure PayPal (Optional - for payments)
1. Get credentials from [PayPal Developer](https://developer.paypal.com/dashboard/)
2. Edit `tokerrgjik_mobile/lib/config/payment_config.dart`:
   ```dart
   static const String paypalClientId = 'YOUR_CLIENT_ID';
   static const String paypalSecret = 'YOUR_SECRET';
   ```

#### 4. Build and Deploy
```bash
cd tokerrgjik_mobile
flutter pub get
flutter build web --release
cd ..
git add -A
git commit -m "Configured app settings"
git push origin main
```

Netlify will automatically deploy your changes!

## 🏗️ Project Structure

```
TokerrGjiks/
├── netlify/
│   └── functions/          # Serverless API endpoints
│       ├── users.mjs       # User management
│       ├── games.mjs       # Game sessions
│       ├── leaderboard.mjs # Rankings
│       ├── auth.mjs        # Authentication
│       └── ...
├── tokerrgjik_mobile/
│   ├── lib/
│   │   ├── screens/        # UI screens
│   │   ├── services/       # Business logic
│   │   ├── models/         # Data models
│   │   └── widgets/        # Reusable components
│   └── build/web/          # Built web files (deployed to Netlify)
└── netlify.toml            # Netlify configuration
```

## 🔧 Environment Variables

Set these in your Netlify dashboard under Site Settings → Environment Variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `NETLIFY_DATABASE_URL` | ✅ Yes | Neon PostgreSQL connection string |
| `NETLIFY_DATABASE_URL_UNPOOLED` | Optional | Non-pooled connection (for transactions) |

## 🎯 Features Implementation

- ✅ Database connection with Neon PostgreSQL
- ✅ User authentication and profiles
- ✅ Real-time multiplayer with HTTP polling
- ✅ PayPal payment integration
- ✅ Leaderboard and statistics
- ✅ Friends system with requests
- ✅ Local avatar storage
- ✅ Achievements system
- ✅ Sound effects and animations

## 🐛 Troubleshooting

### AdSense 400 errors in console
- **Cause**: Google Mobile Ads don't work on web, only on mobile apps
- **Solution**: Already fixed - removed invalid AdSense code from web/index.html
- **Note**: Ads will work when you build Android/iOS apps

### Functions are crashing
- **Cause**: Database environment variable not set
- **Solution**: Add `NETLIFY_DATABASE_URL` in Netlify dashboard, then redeploy

### PayPal not opening
- **Cause**: Missing PayPal credentials or old cached build
- **Solution**: 
  1. Add credentials to `payment_config.dart` 
  2. Hard refresh browser (Ctrl+Shift+R)
  3. Clear browser cache if needed

### Leaderboard is blank
- **Cause**: Database tables don't exist
- **Solution**: Run the database schema SQL in Neon console

### Username stuck as "Player" or weird random name
- **Solution**: Go to Profile → Edit Profile → Change your username
- **Note**: New users get fun random names like "SwiftTiger123" or "BraveDragon456" instead of boring "Player_1234"

### Can't find multiplayer games
- **Solution**: Click "Luaj online" button to open the multiplayer lobby
- **Tip**: Lobby auto-refreshes every 5 seconds to show new games

## 📱 Platforms

- ✅ Web (deployed on Netlify)
- ✅ Android (APK can be built)
- ✅ iOS (requires Mac for building)
- ✅ Desktop (Windows, macOS, Linux)

## 🛠️ Development

### Run locally
```bash
cd tokerrgjik_mobile
flutter run -d chrome
```

### Build for production
```bash
flutter build web --release
flutter build apk --release  # For Android
```

## 📚 API Documentation

### Endpoints
All endpoints are available at: `https://tokerrgjik.netlify.app/.netlify/functions/`

- `GET /health` - Health check
- `POST /users` - Create user
- `GET /users/:username` - Get user profile
- `PUT /users/profile` - Update profile
- `GET /leaderboard` - Get rankings
- `POST /games` - Save game result
- `POST /friends/request` - Send friend request
- And more...

## 📄 License

This is a student project for educational purposes.

## 👥 Contributors

- Students of the course

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Neon for PostgreSQL hosting
- Netlify for serverless functions and hosting
- PayPal for payment processing

---

**Note**: This is a student project. All services use free tiers and sandbox environments.
