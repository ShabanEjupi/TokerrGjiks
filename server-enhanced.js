const express = require('express');
const path = require('path');
const http = require('http');
const socketIO = require('socket.io');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/tokerrgjik';
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-this';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// MongoDB Connection
mongoose.connect(MONGODB_URI)
.then(() => console.log('✅ MongoDB connected successfully'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// ==================== MONGOOSE MODELS ====================

// User Model
const userSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  username: { type: String, required: true, unique: true },
  email: { type: String, sparse: true },
  password: { type: String },
  avatar: String,
  coins: { type: Number, default: 0 },
  level: { type: Number, default: 1 },
  xp: { type: Number, default: 0 },
  stats: {
    gamesPlayed: { type: Number, default: 0 },
    gamesWon: { type: Number, default: 0 },
    gamesLost: { type: Number, default: 0 },
    gamesDraw: { type: Number, default: 0 },
    winStreak: { type: Number, default: 0 },
    bestWinStreak: { type: Number, default: 0 },
    totalPlayTime: { type: Number, default: 0 },
  },
  friends: [{ type: String }],
  blockedUsers: [{ type: String }],
  settings: {
    soundEnabled: { type: Boolean, default: true },
    musicEnabled: { type: Boolean, default: true },
    notificationsEnabled: { type: Boolean, default: true },
  },
  isPremium: { type: Boolean, default: false },
  premiumExpiry: Date,
  lastLogin: Date,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

const User = mongoose.model('User', userSchema);

// Game History Model
const gameHistorySchema = new mongoose.Schema({
  gameId: { type: String, required: true, unique: true },
  roomId: String,
  gameMode: { type: String, enum: ['public', 'private', 'lan', 'friend', 'ai'], default: 'public' },
  players: [{
    userId: String,
    username: String,
    playerNumber: Number,
  }],
  winner: String, // Changed to String to accept userId
  opponentId: String,
  winnerUserId: String,
  result: { type: String, enum: ['win', 'loss', 'draw'] },
  score: {
    player: Number,
    opponent: Number,
  },
  moves: Number,
  duration: Number,
  boardState: [Number],
  createdAt: { type: Date, default: Date.now },
});

const GameHistory = mongoose.model('GameHistory', gameHistorySchema);

// Achievement Model
const achievementSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  achievementId: { type: String, required: true },
  title: String,
  description: String,
  icon: String,
  unlockedAt: { type: Date, default: Date.now },
});

achievementSchema.index({ userId: 1, achievementId: 1 }, { unique: true });
const Achievement = mongoose.model('Achievement', achievementSchema);

// ==================== IN-MEMORY GAME STATE ====================

const rooms = new Map();
const activePlayers = new Map();
const matchmakingQueue = [];

// ==================== AUTHENTICATION MIDDLEWARE ====================

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    req.user = await User.findOne({ userId: decoded.userId });
    next();
  } catch (err) {
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
};

// ==================== REST API ENDPOINTS ====================

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: Date.now(),
    mongodb: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
  });
});

// Register user
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Check if user exists
    const existingUser = await User.findOne({ 
      $or: [{ username }, { email }] 
    });

    if (existingUser) {
      return res.status(400).json({ error: 'Username or email already exists' });
    }

    // Hash password if provided
    let hashedPassword = null;
    if (password) {
      hashedPassword = await bcrypt.hash(password, 10);
    }

    // Create user
    const userId = 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    const user = new User({
      userId,
      username,
      email,
      password: hashedPassword,
      lastLogin: new Date(),
    });

    await user.save();

    // Generate token
    const token = jwt.sign({ userId: user.userId }, JWT_SECRET, { expiresIn: '30d' });

    res.status(201).json({
      success: true,
      token,
      user: {
        userId: user.userId,
        username: user.username,
        email: user.email,
        coins: user.coins,
        level: user.level,
        stats: user.stats,
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// Login user
app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Verify password if set
    if (user.password) {
      const validPassword = await bcrypt.compare(password, user.password);
      if (!validPassword) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    // Generate token
    const token = jwt.sign({ userId: user.userId }, JWT_SECRET, { expiresIn: '30d' });

    res.json({
      success: true,
      token,
      user: {
        userId: user.userId,
        username: user.username,
        email: user.email,
        coins: user.coins,
        level: user.level,
        stats: user.stats,
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Get user profile
app.get('/api/user/profile', authenticateToken, async (req, res) => {
  try {
    const user = req.user;
    res.json({
      userId: user.userId,
      username: user.username,
      email: user.email,
      avatar: user.avatar,
      coins: user.coins,
      level: user.level,
      xp: user.xp,
      stats: user.stats,
      isPremium: user.isPremium,
      createdAt: user.createdAt,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

// Update user profile
app.put('/api/user/profile', authenticateToken, async (req, res) => {
  try {
    const { username, email, avatar } = req.body;
    const user = req.user;

    if (username) user.username = username;
    if (email) user.email = email;
    if (avatar) user.avatar = avatar;
    user.updatedAt = new Date();

    await user.save();

    res.json({ success: true, user });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

// Sync user data from mobile
app.post('/api/user/sync', authenticateToken, async (req, res) => {
  try {
    const { stats, coins, level, xp, settings } = req.body;
    const user = req.user;

    if (stats) Object.assign(user.stats, stats);
    if (coins !== undefined) user.coins = coins;
    if (level !== undefined) user.level = level;
    if (xp !== undefined) user.xp = xp;
    if (settings) Object.assign(user.settings, settings);
    user.updatedAt = new Date();

    await user.save();

    res.json({ success: true, user });
  } catch (error) {
    res.status(500).json({ error: 'Sync failed' });
  }
});

// Get leaderboard
app.get('/api/leaderboard', async (req, res) => {
  try {
    const { limit = 100, sortBy = 'wins' } = req.query;
    
    let sortField = 'stats.gamesWon';
    if (sortBy === 'level') sortField = 'level';
    if (sortBy === 'coins') sortField = 'coins';

    const users = await User.find()
      .select('userId username avatar level coins stats isPremium')
      .sort({ [sortField]: -1 })
      .limit(parseInt(limit));

    res.json({ success: true, leaderboard: users });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

// Save game history
app.post('/api/game/history', authenticateToken, async (req, res) => {
  try {
    const gameHistory = new GameHistory({
      ...req.body,
      gameId: 'game_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9),
    });

    await gameHistory.save();

    // Update user stats
    if (req.body.players) {
      for (const player of req.body.players) {
        const user = await User.findOne({ userId: player.userId });
        if (user) {
          user.stats.gamesPlayed++;
          
          if (player.userId === req.body.winnerUserId) {
            user.stats.gamesWon++;
            user.stats.winStreak++;
            if (user.stats.winStreak > user.stats.bestWinStreak) {
              user.stats.bestWinStreak = user.stats.winStreak;
            }
          } else if (req.body.result === 'draw') {
            user.stats.gamesDraw++;
            user.stats.winStreak = 0;
          } else {
            user.stats.gamesLost++;
            user.stats.winStreak = 0;
          }

          if (req.body.duration) {
            user.stats.totalPlayTime += req.body.duration;
          }

          await user.save();
        }
      }
    }

    res.json({ success: true, gameId: gameHistory.gameId });
  } catch (error) {
    console.error('Error saving game history:', error);
    res.status(500).json({ error: 'Failed to save game history' });
  }
});

// Get user game history
app.get('/api/game/history/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 50, skip = 0 } = req.query;

    const games = await GameHistory.find({
      'players.userId': userId
    })
    .sort({ createdAt: -1 })
    .limit(parseInt(limit))
    .skip(parseInt(skip));

    res.json({ success: true, games });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch game history' });
  }
});

// Unlock achievement
app.post('/api/achievements/unlock', authenticateToken, async (req, res) => {
  try {
    const { achievementId, title, description, icon } = req.body;

    const achievement = new Achievement({
      userId: req.userId,
      achievementId,
      title,
      description,
      icon,
    });

    await achievement.save();

    res.json({ success: true, achievement });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ error: 'Achievement already unlocked' });
    }
    res.status(500).json({ error: 'Failed to unlock achievement' });
  }
});

// Get user achievements
app.get('/api/achievements/:userId', async (req, res) => {
  try {
    const achievements = await Achievement.find({ userId: req.params.userId });
    res.json({ success: true, achievements });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch achievements' });
  }
});

// ==================== SOCKET.IO MULTIPLAYER ====================

io.on('connection', (socket) => {
  console.log('🎮 Player connected:', socket.id);

  // Set player info
  socket.on('setPlayerName', (data) => {
    const { playerName, userId } = data;
    activePlayers.set(socket.id, {
      id: socket.id,
      name: playerName,
      userId: userId || null,
      room: null,
    });
    socket.emit('nameSet', { name: playerName });
    console.log('👤 Player name set:', playerName);
  });

  // Join public matchmaking queue
  socket.on('join_public_queue', (data) => {
    const player = activePlayers.get(socket.id);
    if (!player) return;

    matchmakingQueue.push({ socket, player, ...data });
    console.log('🔍 Player joined queue:', player.name);

    // Try to match players
    if (matchmakingQueue.length >= 2) {
      const player1Data = matchmakingQueue.shift();
      const player2Data = matchmakingQueue.shift();

      const roomId = 'room_' + Date.now();
      createRoom(roomId, 'public', [player1Data, player2Data]);
    } else {
      socket.emit('queue_joined', { position: matchmakingQueue.length });
    }
  });

  // Create private room
  socket.on('create_private_room', (data, callback) => {
    const player = activePlayers.get(socket.id);
    if (!player) return;

    const roomCode = generateRoomCode();
    const roomId = 'private_' + roomCode;
    
    const room = {
      id: roomId,
      code: roomCode,
      type: 'private',
      host: player,
      players: [],
      password: data.password || null,
      maxPlayers: data.maxPlayers || 2,
      gameMode: data.gameMode || 'standard',
      customSettings: data.customSettings || {},
      gameStarted: false,
      createdAt: Date.now(),
    };

    rooms.set(roomId, room);
    
    // Host joins the room
    joinRoom(socket, player, roomId);

    callback({ success: true, room_code: roomCode, room_id: roomId });
    console.log('🏠 Private room created:', roomCode);
  });

  // Join private room
  socket.on('join_private_room', (data, callback) => {
    const player = activePlayers.get(socket.id);
    if (!player) {
      return callback({ success: false, error: 'Player not found' });
    }

    const roomId = 'private_' + data.room_code;
    const room = rooms.get(roomId);

    if (!room) {
      return callback({ success: false, error: 'Room not found' });
    }

    if (room.password && room.password !== data.password) {
      return callback({ success: false, error: 'Invalid password' });
    }

    if (room.players.length >= room.maxPlayers) {
      return callback({ success: false, error: 'Room is full' });
    }

    joinRoom(socket, player, roomId);
    callback({ success: true });

    // Start game if room is full
    if (room.players.length === room.maxPlayers) {
      startGame(roomId);
    }
  });

  // Make game move
  socket.on('make_move', (data) => {
    const player = activePlayers.get(socket.id);
    if (!player || !player.room) return;

    const room = rooms.get(player.room);
    if (!room) return;

    // Broadcast move to other players
    socket.to(player.room).emit('move_made', {
      playerId: socket.id,
      playerName: player.name,
      ...data.move_data,
    });

    // Update room state
    if (data.move_data) {
      Object.assign(room, data.move_data);
    }
  });

  // Chat message
  socket.on('chat_message', (data) => {
    const player = activePlayers.get(socket.id);
    if (!player || !player.room) return;

    const message = {
      id: Date.now() + '_' + Math.random().toString(36).substr(2, 9),
      sender_id: socket.id,
      sender_name: player.name,
      message: data.message,
      timestamp: new Date().toISOString(),
      type: data.type || 'text',
    };

    io.to(player.room).emit('chat_message', message);
  });

  // Leave room
  socket.on('leave_room', () => {
    handlePlayerLeave(socket);
  });

  // Disconnect
  socket.on('disconnect', () => {
    handlePlayerLeave(socket);
    activePlayers.delete(socket.id);
    
    // Remove from matchmaking queue
    const queueIndex = matchmakingQueue.findIndex(item => item.socket.id === socket.id);
    if (queueIndex !== -1) {
      matchmakingQueue.splice(queueIndex, 1);
    }

    console.log('👋 Player disconnected:', socket.id);
  });
});

// Helper functions
function createRoom(roomId, type, playerDataArray) {
  const room = {
    id: roomId,
    type,
    players: [],
    gameStarted: true,
    board: new Array(24).fill(null),
    currentPlayer: 1,
    phase: 'placing',
    startTime: Date.now(),
  };

  rooms.set(roomId, room);

  playerDataArray.forEach((playerData, index) => {
    const { socket, player } = playerData;
    player.room = roomId;
    player.playerNumber = index + 1;
    room.players.push(player);
    socket.join(roomId);
  });

  // Notify all players
  playerDataArray.forEach((playerData, index) => {
    playerData.socket.emit('game_started', {
      room_id: roomId,
      your_number: index + 1,
      players: room.players.map(p => ({ id: p.id, name: p.name, number: p.playerNumber })),
    });
  });

  console.log(`🎮 Game started in room ${roomId}`);
}

function joinRoom(socket, player, roomId) {
  const room = rooms.get(roomId);
  if (!room) return;

  player.room = roomId;
  player.playerNumber = room.players.length + 1;
  room.players.push(player);
  socket.join(roomId);

  socket.emit('room_joined', {
    room_id: roomId,
    room_code: room.code,
    your_number: player.playerNumber,
    players: room.players,
  });

  socket.to(roomId).emit('player_joined', {
    player_id: socket.id,
    player_name: player.name,
    player_number: player.playerNumber,
  });
}

function startGame(roomId) {
  const room = rooms.get(roomId);
  if (!room) return;

  room.gameStarted = true;
  room.startTime = Date.now();

  io.to(roomId).emit('game_started', {
    room_id: roomId,
    players: room.players.map((p, i) => ({ id: p.id, name: p.name, number: i + 1 })),
  });
}

function handlePlayerLeave(socket) {
  const player = activePlayers.get(socket.id);
  if (!player || !player.room) return;

  const room = rooms.get(player.room);
  if (room) {
    socket.to(player.room).emit('player_left', {
      player_id: socket.id,
      player_name: player.name,
    });

    // Remove player from room
    room.players = room.players.filter(p => p.id !== socket.id);

    // Delete room if empty
    if (room.players.length === 0) {
      rooms.delete(player.room);
      console.log(`🗑️  Room deleted: ${player.room}`);
    }
  }

  player.room = null;
  socket.leave(player.room);
}

function generateRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

// ==================== START SERVER ====================

server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Tokerrgjik Server running on http://localhost:${PORT}`);
  console.log(`📊 API: http://localhost:${PORT}/api/health`);
  console.log(`🎮 WebSocket: ws://localhost:${PORT}`);
});

module.exports = { app, server, io };
