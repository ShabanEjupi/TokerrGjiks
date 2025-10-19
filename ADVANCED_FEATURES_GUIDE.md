# 🚀 Advanced Features Implementation Guide

## Overview
This document explains all the advanced features implemented in TokerrGjiks, including PayPal payments, Google AdSense, Socket.IO multiplayer, authentication, avatars, achievements, and email notifications.

---

## 1. 💰 PayPal Payment Integration

### Setup Instructions

1. **Get PayPal Credentials**:
   - Go to https://developer.paypal.com/
   - Create a sandbox account
   - Get your **Client ID** and **Secret Key**

2. **Configure in Flutter App**:
   ```dart
   // lib/config/payment_config.dart
   static const String paypalClientId = 'YOUR_PAYPAL_CLIENT_ID';
   static const String paypalSecret = 'YOUR_PAYPAL_SECRET';
   static const bool useSandbox = true; // Change to false for production
   ```

3. **Test Payment Flow**:
   ```dart
   import 'package:tokerrgjik_mobile/services/paypal_service.dart';
   
   // Purchase PRO subscription
   await PayPalService().purchaseProSubscription(context, months: 12);
   
   // Purchase coins
   await PayPalService().purchaseCoins(context, coins: 500, amount: '€4.99');
   ```

### Available Packages

**PRO Subscriptions:**
- 1 Month: €2.99
- 12 Months: €20.82 (43% discount!)

**Coin Packages:**
- 100 coins: €0.99
- 500 coins: €4.99 (+50 bonus)
- 1000 coins: €8.99 (+150 bonus)
- 2500 coins: €19.99 (+500 bonus)

---

## 2. 📢 Google AdSense Integration

### Setup Instructions

1. **Get AdSense Publisher ID**:
   - Go to https://adsense.google.com/
   - Apply for AdSense account
   - Get your **Publisher ID** (ca-pub-XXXXXXXXXXXXXXXX)

2. **Configure in Web App**:
   ```html
   <!-- tokerrgjik_mobile/web/index.html -->
   <!-- UNCOMMENT these lines and add your Publisher ID -->
   <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-XXXXXXXXXXXXXXXX"
           crossorigin="anonymous"></script>
   
   <!-- Top Banner Ad -->
   <ins class="adsbygoogle"
        style="display:block"
        data-ad-client="ca-pub-XXXXXXXXXXXXXXXX"
        data-ad-slot="YOUR_AD_SLOT_ID"
        data-ad-format="auto"
        data-full-width-responsive="true"></ins>
   ```

3. **Get Ad Slot IDs**:
   - In AdSense dashboard, create ad units
   - Copy the Ad Slot IDs
   - Replace `YOUR_AD_SLOT_ID` in the HTML

### Ad Placement
- **Top Banner**: Displays at the top of the game
- **Bottom Banner**: Displays at the bottom
- **Interstitial Ads**: Shown between games (configured in `ad_service.dart`)

**Note**: Ads are automatically hidden for PRO members!

---

## 3. 🌐 Socket.IO Real-time Multiplayer

### Server Setup

1. **Deploy Socket.IO Server**:
   ```bash
   cd socketio-server
   npm install
   
   # Set environment variable
   export NEON_DATABASE_URL="your_neon_connection_string"
   
   # Start server
   npm start
   ```

2. **Deploy to Render/Heroku/Railway**:
   - Push `socketio-server/` folder to Git
   - Create new web service on Render.com (recommended)
   - Set environment variable: `NEON_DATABASE_URL`
   - Deploy automatically from Git

3. **Configure in Flutter**:
   ```dart
   // lib/services/socket_service_realtime.dart
   final url = 'https://your-socketio-server.onrender.com';
   ```

### Usage Example

```dart
import 'package:tokerrgjik_mobile/services/socket_service_realtime.dart';

final socketService = SocketServiceRealtime();

// Connect to server
await socketService.connect('username', serverUrl: 'https://...');

// Create a game session
socketService.createSession(isPrivate: false);

// Join an existing session
socketService.joinSession('session_id');

// Make a move
socketService.makeMove(
  sessionId: 'session_id',
  position: 5,
  action: 'place',
);

// Listen for events
socketService.onGameStarted = (data) {
  print('Game started: ${data}');
};

socketService.onMoveMade = (data) {
  print('Move made: ${data}');
};
```

### Features
- ✅ Real-time game synchronization
- ✅ Lobby system with player count
- ✅ Private and public game rooms
- ✅ Live chat during games
- ✅ Automatic disconnect handling

---

## 4. 🔐 User Authentication

### Features
- User registration with email
- Secure login (SHA-256 password hashing)
- Guest mode (play without account)
- Token-based authentication
- Password reset via email

### Usage Example

```dart
import 'package:tokerrgjik_mobile/services/auth_service.dart';

// Register new user
final result = await AuthService().register(
  username: 'AlbinKosovar',
  email: 'albin@example.com',
  password: 'securePassword123',
  fullName: 'Albin Shala',
);

// Login
final loginResult = await AuthService().login(
  username: 'AlbinKosovar',
  password: 'securePassword123',
);

// Check if authenticated
if (AuthService().isAuthenticated) {
  print('Logged in as: ${AuthService().currentUsername}');
}

// Logout
await AuthService().logout();
```

### Security Notes
- Passwords are hashed with SHA-256 before transmission
- Tokens are stored in SharedPreferences
- Automatic token verification on app start
- Session timeout after 7 days

---

## 5. 🖼️ Profile Avatars

### Setup Instructions

1. **Choose Storage Provider** (Pick one):
   - **Cloudinary** (Recommended): https://cloudinary.com/
   - **AWS S3**: https://aws.amazon.com/s3/
   - **Firebase Storage**: https://firebase.google.com/

2. **Configure Cloudinary (Example)**:
   ```dart
   // lib/services/avatar_service.dart
   static const String cloudinaryUploadUrl = 'https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/image/upload';
   static const String cloudinaryUploadPreset = 'YOUR_UPLOAD_PRESET';
   ```

3. **Usage Example**:
   ```dart
   import 'package:tokerrgjik_mobile/services/avatar_service.dart';
   import 'package:image_picker/image_picker.dart';
   
   // Pick and upload avatar
   final avatarUrl = await AvatarService().changeAvatar(
     username: 'AlbinKosovar',
     source: ImageSource.gallery, // or ImageSource.camera
   );
   
   if (avatarUrl != null) {
     print('Avatar uploaded: $avatarUrl');
   }
   ```

### Features
- ✅ Pick from gallery or camera
- ✅ Automatic image compression (512x512, 85% quality)
- ✅ Circular avatar display
- ✅ Default avatars if not uploaded
- ✅ Cached images for performance

---

## 6. 🏆 Achievements System

### Available Achievements

| Icon | Achievement | Description | Requirement |
|------|------------|-------------|-------------|
| 🏆 | Fitorja e Parë | Win your first game | 1 win |
| 🔥 | Seri Fitore 5 | Win 5 games in a row | 5 win streak |
| ⚡ | Seri Fitore 10 | Win 10 games in a row | 10 win streak |
| 🎮 | Veteran | Play 100 games | 100 games |
| 👑 | Mjeshtër | Play 500 games | 500 games |
| ⭐ | Nivel 10 | Reach level 10 | Level 10 |
| 💎 | Nivel 50 | Reach level 50 | Level 50 |
| 👔 | Anëtar PRO | Purchase PRO membership | Buy PRO |
| 💰 | I Pasur | Collect 1000 coins | 1000 coins |
| 👥 | Popullor | Add 10 friends | 10 friends |

### Usage Example

```dart
import 'package:tokerrgjik_mobile/services/achievements_service.dart';

// Get all achievements
final achievements = await AchievementsService().getUserAchievements('AlbinKosovar');

// Check and unlock after a game
final newlyUnlocked = await AchievementsService().checkAndUnlockAchievements(
  username: 'AlbinKosovar',
  totalWins: 5,
  currentWinStreak: 3,
  totalGames: 10,
  userLevel: 5,
  coins: 500,
  friendsCount: 3,
  isPro: false,
);

// Show notification for new achievements
for (final achievement in newlyUnlocked) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('${achievement.icon} ${achievement.title}'),
      content: Text(achievement.description),
    ),
  );
}
```

### Features
- ✅ 10 predefined achievements
- ✅ Automatic unlock detection
- ✅ Progress tracking
- ✅ Email notifications on unlock
- ✅ Beautiful UI with icons

---

## 7. 📧 Email Notifications

### Setup Instructions

1. **Choose Email Provider** (Pick one):
   - **SendGrid** (Recommended): https://sendgrid.com/
   - **Mailgun**: https://mailgun.com/
   - **AWS SES**: https://aws.amazon.com/ses/

2. **Configure SendGrid (Example)**:
   ```javascript
   // netlify/functions/email.mjs
   const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;
   
   // Uncomment SendGrid integration code (line 20-30)
   const sgMail = require('@sendgrid/mail');
   sgMail.setApiKey(SENDGRID_API_KEY);
   
   const msg = {
     to,
     from: 'noreply@tokerrgjik.app',
     subject,
     html,
   };
   
   await sgMail.send(msg);
   ```

3. **Set Environment Variable in Netlify**:
   - Go to Netlify Dashboard → Site Settings → Environment Variables
   - Add: `SENDGRID_API_KEY = your_api_key_here`

### Email Types

- **Friend Request**: Notification when someone sends a friend request
- **Game Invite**: Notification when invited to a game
- **Achievement Unlocked**: Notification when unlocking an achievement
- **PRO Purchase**: Confirmation email after buying PRO
- **Coins Purchase**: Confirmation email after buying coins
- **Password Reset**: Link to reset password

### Usage Example

```dart
import 'package:tokerrgjik_mobile/services/email_service.dart';

// Send friend request email
await EmailService().sendFriendRequestEmail(
  toUsername: 'DoraShqipja',
  fromUsername: 'AlbinKosovar',
);

// Send achievement email
await EmailService().sendAchievementEmail(
  username: 'AlbinKosovar',
  achievementTitle: 'Fitorja e Parë',
  achievementDescription: 'Fitoni lojën tuaj të parë',
  achievementIcon: '🏆',
);

// Send purchase confirmation
await EmailService().sendProPurchaseEmail(
  username: 'AlbinKosovar',
  months: 12,
  amount: '€20.82',
);
```

---

## 8. 🔄 Complete Integration Flow

### After a Game Ends:

1. **Save Game Result** → `lib/services/api_service.dart`
2. **Update User Stats** → Wins, losses, level, coins
3. **Check Achievements** → `AchievementsService().checkAndUnlockAchievements()`
4. **Send Email Notifications** → For new achievements
5. **Update Leaderboard** → Real-time rank calculation
6. **Award Coins** → Based on win/loss/streak

### After a Payment:

1. **Process Payment** → PayPal API
2. **Update User Account** → Add PRO status or coins
3. **Send Confirmation Email** → Purchase receipt
4. **Unlock PRO Achievement** → If first time
5. **Show Success Message** → In-app notification

---

## 9. 🛠️ Testing Checklist

### PayPal Payments
- [ ] Create sandbox account
- [ ] Test PRO subscription purchase
- [ ] Test coin purchase
- [ ] Verify order creation
- [ ] Verify payment capture
- [ ] Check user balance update

### Google AdSense
- [ ] Apply for AdSense account
- [ ] Add Publisher ID to HTML
- [ ] Create ad units
- [ ] Test ad display on web
- [ ] Verify ads hidden for PRO users

### Socket.IO Multiplayer
- [ ] Deploy Socket.IO server
- [ ] Test connection from Flutter app
- [ ] Create game session
- [ ] Join game session
- [ ] Make moves in real-time
- [ ] Test chat functionality
- [ ] Test disconnect handling

### Authentication
- [ ] Register new user
- [ ] Login with credentials
- [ ] Test guest mode
- [ ] Verify token persistence
- [ ] Test logout
- [ ] Test password change

### Avatars
- [ ] Configure Cloudinary/S3
- [ ] Pick image from gallery
- [ ] Upload avatar
- [ ] Display avatar in profile
- [ ] Test default avatars

### Achievements
- [ ] Play games and check unlocks
- [ ] Verify all 10 achievements
- [ ] Test achievement notifications
- [ ] Check progress tracking

### Email Notifications
- [ ] Configure SendGrid
- [ ] Send test friend request email
- [ ] Send test achievement email
- [ ] Send test purchase email
- [ ] Verify email delivery

---

## 10. 📝 Environment Variables

Create a `.env` file in your project root (for local testing):

```env
# Neon Database
NEON_DATABASE_URL=postgresql://user:password@host/database

# PayPal
PAYPAL_CLIENT_ID=your_client_id
PAYPAL_SECRET=your_secret
PAYPAL_MODE=sandbox

# Google AdSense
ADSENSE_PUBLISHER_ID=ca-pub-XXXXXXXXXXXXXXXX

# SendGrid Email
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxx

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Socket.IO Server
SOCKETIO_SERVER_URL=https://your-server.onrender.com
```

**For Netlify Deployment**:
- Add all environment variables in: Site Settings → Environment Variables

---

## 11. 🚀 Final Deployment

### Build Flutter Web:
```bash
cd tokerrgjik_mobile
flutter build web --release
```

### Commit and Push:
```bash
git add -A
git commit -m "✨ Add PayPal, AdSense, Socket.IO, Auth, Avatars, Achievements, Emails"
git push origin main
```

### Deploy Socket.IO Server:
1. Create new project on Render.com
2. Connect your GitHub repository
3. Select `socketio-server` directory
4. Add environment variable: `NEON_DATABASE_URL`
5. Deploy!

### Verify Netlify Deployment:
1. Go to https://app.netlify.com/
2. Check deployment logs
3. Verify all Netlify Functions deployed
4. Test live site: https://tokerrgjik.netlify.app/

---

## 12. 🎓 For Students

**You have successfully implemented:**
- ✅ Payment gateway integration (PayPal)
- ✅ Ad monetization (Google AdSense)
- ✅ Real-time multiplayer (Socket.IO)
- ✅ User authentication system
- ✅ File upload & cloud storage (Avatars)
- ✅ Gamification (Achievements)
- ✅ Email notification system
- ✅ Serverless functions (Netlify Functions)
- ✅ PostgreSQL database (Neon)
- ✅ Full-stack Flutter web app

**What you learned:**
- Backend development with Node.js
- Frontend development with Flutter
- Database design and queries
- API integration (PayPal, AdSense, SendGrid)
- Real-time communication (WebSockets)
- Cloud deployment (Netlify, Render)
- Authentication & security
- Payment processing
- Email services

**This project showcases:**
- Full-stack development skills
- Cloud architecture knowledge
- Third-party API integration
- Real-world app monetization
- Production-ready code

---

## 📞 Support

If you need help:
1. Check the code comments in each service file
2. Read the API documentation for each provider
3. Test in sandbox/demo mode first
4. Check browser console for errors (F12)
5. Review Netlify Function logs

**Happy coding! 🚀**
