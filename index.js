const express = require('express');
const path = require('path');
const http = require('http');
const socketIO = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIO(server);
const port = 3000;

// Game state management
const rooms = new Map();
const players = new Map();
const playerStats = new Map();

// Serve static files
app.use(express.static('public'));
app.use(express.json());

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/game', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'game-multiplayer.html'));
});

// API endpoints for leaderboard
app.get('/api/leaderboard', (req, res) => {
  const leaderboard = Array.from(playerStats.values())
    .sort((a, b) => b.wins - a.wins)
    .slice(0, 10);
  res.json(leaderboard);
});

app.get('/api/stats/:playerName', (req, res) => {
  const stats = playerStats.get(req.params.playerName) || {
    name: req.params.playerName,
    wins: 0,
    losses: 0,
    draws: 0,
    totalGames: 0,
    totalPlayTime: 0
  };
  res.json(stats);
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('Player connected:', socket.id);

  socket.on('setPlayerName', (name) => {
    players.set(socket.id, { id: socket.id, name: name, room: null });
    
    if (!playerStats.has(name)) {
      playerStats.set(name, {
        name: name,
        wins: 0,
        losses: 0,
        draws: 0,
        totalGames: 0,
        totalPlayTime: 0,
        joinedAt: Date.now()
      });
    }
    
    socket.emit('nameSet', { name: name });
    console.log('Player name set:', name);
  });

  socket.on('findGame', () => {
    const player = players.get(socket.id);
    if (!player) return;

    // Find an available room or create a new one
    let foundRoom = null;
    for (const [roomId, room] of rooms.entries()) {
      if (room.players.length === 1 && !room.gameStarted) {
        foundRoom = roomId;
        break;
      }
    }

    if (foundRoom) {
      // Join existing room
      const room = rooms.get(foundRoom);
      room.players.push(player);
      player.room = foundRoom;
      player.playerNumber = 2;
      socket.join(foundRoom);

      room.gameStarted = true;
      room.startTime = Date.now();

      io.to(foundRoom).emit('gameStart', {
        room: foundRoom,
        players: room.players,
        yourNumber: player.playerNumber
      });

      console.log(`Game started in room ${foundRoom}`);
    } else {
      // Create new room
      const roomId = 'room_' + Date.now();
      const room = {
        id: roomId,
        players: [player],
        gameStarted: false,
        board: new Array(24).fill(null),
        currentPlayer: 1,
        phase: 'placing',
        piecesLeft: { 1: 9, 2: 9 },
        piecesOnBoard: { 1: 0, 2: 0 },
        messages: [],
        startTime: null
      };

      rooms.set(roomId, room);
      player.room = roomId;
      player.playerNumber = 1;
      socket.join(roomId);

      socket.emit('waitingForOpponent', { room: roomId });
      console.log(`Room created: ${roomId}`);
    }
  });

  socket.on('gameMove', (data) => {
    const player = players.get(socket.id);
    if (!player || !player.room) return;

    const room = rooms.get(player.room);
    if (!room) return;

    // Broadcast move to other players in room
    socket.to(player.room).emit('opponentMove', data);
    
    // Update room state
    if (data.board) room.board = data.board;
    if (data.currentPlayer) room.currentPlayer = data.currentPlayer;
    if (data.phase) room.phase = data.phase;
    if (data.piecesLeft) room.piecesLeft = data.piecesLeft;
    if (data.piecesOnBoard) room.piecesOnBoard = data.piecesOnBoard;
  });

  socket.on('gameOver', (data) => {
    const player = players.get(socket.id);
    if (!player || !player.room) return;

    const room = rooms.get(player.room);
    if (!room) return;

    const playTime = Date.now() - room.startTime;

    // Update stats
    room.players.forEach((p, index) => {
      const stats = playerStats.get(p.name);
      if (stats) {
        stats.totalGames++;
        stats.totalPlayTime += playTime;
        
        if (data.winner === index + 1) {
          stats.wins++;
        } else if (data.winner === 0) {
          stats.draws++;
        } else {
          stats.losses++;
        }
      }
    });

    io.to(player.room).emit('gameEnded', {
      winner: data.winner,
      winnerName: data.winnerName,
      playTime: playTime
    });

    console.log(`Game ended in room ${player.room}. Winner: ${data.winnerName}`);
  });

  socket.on('chatMessage', (message) => {
    const player = players.get(socket.id);
    if (!player || !player.room) return;

    const room = rooms.get(player.room);
    if (!room) return;

    const chatMsg = {
      playerName: player.name,
      message: message,
      timestamp: Date.now()
    };

    room.messages.push(chatMsg);
    io.to(player.room).emit('chatMessage', chatMsg);
  });

  socket.on('disconnect', () => {
    const player = players.get(socket.id);
    if (player && player.room) {
      const room = rooms.get(player.room);
      if (room) {
        socket.to(player.room).emit('opponentDisconnected');
        rooms.delete(player.room);
      }
    }
    players.delete(socket.id);
    console.log('Player disconnected:', socket.id);
  });
});

server.listen(port, '0.0.0.0', () => {
  console.log(`🎮 Tokerrgjik Multiplayer Server running on http://localhost:${port}`);
  console.log(`📊 Leaderboard API: http://localhost:${port}/api/leaderboard`);
});

// Keep the old homepage as /about
app.get('/about', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="sq">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title></title>
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          display: flex;
          justify-content: center;
          align-items: center;
          padding: 20px;
        }
        
        .container {
          background: white;
          border-radius: 20px;
          padding: 60px 80px;
          box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
          text-align: center;
          max-width: 800px;
          animation: fadeIn 0.8s ease-in;
        }
        
        @keyframes fadeIn {
          from {
            opacity: 0;
            transform: translateY(-20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        
        h1 {
          color: #667eea;
          font-size: 2.5em;
          margin-bottom: 20px;
          font-weight: 700;
          letter-spacing: 2px;
        }
        
        h2 {
          color: #764ba2;
          font-size: 2em;
          margin-bottom: 30px;
          font-weight: 600;
        }
        
        .content {
          margin-top: 40px;
          padding-top: 30px;
          border-top: 3px solid #667eea;
        }
        
        .item {
          background: linear-gradient(135deg, #667eea15 0%, #764ba215 100%);
          padding: 20px 30px;
          margin: 15px 0;
          border-radius: 10px;
          font-size: 1.3em;
          color: #333;
          font-weight: 500;
          transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .item:hover {
          transform: translateY(-5px);
          box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        
        .footer {
          margin-top: 40px;
          color: #666;
          font-size: 0.9em;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1></h1>
        <h2>Kompjutimi Cloud</h2>
        
        <div class="content">
          <div class="item">Algoritme të avancuara</div>
          <div class="item">Shkruaj një model MM</div>
        </div>
        
        <div class="footer">
          <p>Funksionon në Docker 🐳 | Node.js + Express</p>
          <p><a href="/">Shko tek Ballina</a> | <a href="/game">Luaj Tokerrgjik</a></p>
        </div>
      </div>
    </body>
    </html>
  `);
});
