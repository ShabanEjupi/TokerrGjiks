-- TokerrGjik Database Initialization Script for Neon PostgreSQL
-- Run this in your Neon SQL Editor: https://console.neon.tech

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255),
    password VARCHAR(255), -- For authentication
    coins INTEGER DEFAULT 100,
    level INTEGER DEFAULT 1,
    xp INTEGER DEFAULT 0,
    total_wins INTEGER DEFAULT 0,
    total_losses INTEGER DEFAULT 0,
    total_draws INTEGER DEFAULT 0,
    best_win_streak INTEGER DEFAULT 0,
    current_win_streak INTEGER DEFAULT 0,
    is_pro BOOLEAN DEFAULT FALSE,
    pro_expires_at TIMESTAMP,
    avatar_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_login_at TIMESTAMP
);

-- Game history table
CREATE TABLE IF NOT EXISTS game_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) NOT NULL REFERENCES users(username) ON DELETE CASCADE,
    game_mode VARCHAR(50) NOT NULL, -- 'vs_ai', 'vs_friend', 'multiplayer', 'online'
    result VARCHAR(20) NOT NULL, -- 'win', 'loss', 'draw'
    opponent_username VARCHAR(50), -- NULL for AI games
    score INTEGER DEFAULT 0,
    duration INTEGER DEFAULT 0, -- in seconds
    moves_count INTEGER DEFAULT 0,
    played_at TIMESTAMP DEFAULT NOW()
);

-- Friends table
CREATE TABLE IF NOT EXISTS friends (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_username VARCHAR(50) NOT NULL REFERENCES users(username) ON DELETE CASCADE,
    friend_username VARCHAR(50) NOT NULL REFERENCES users(username) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'blocked'
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_username, friend_username)
);

-- Multiplayer sessions table
CREATE TABLE IF NOT EXISTS game_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_username VARCHAR(50) NOT NULL REFERENCES users(username),
    guest_username VARCHAR(50) REFERENCES users(username),
    status VARCHAR(20) DEFAULT 'waiting', -- 'waiting', 'active', 'completed', 'cancelled'
    board_state JSONB, -- Store current board state
    current_turn VARCHAR(50), -- username of player whose turn it is
    winner_username VARCHAR(50),
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- Achievements table
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) NOT NULL REFERENCES users(username) ON DELETE CASCADE,
    achievement_type VARCHAR(50) NOT NULL,
    unlocked_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_total_wins ON users(total_wins DESC);
CREATE INDEX IF NOT EXISTS idx_game_history_username ON game_history(username);
CREATE INDEX IF NOT EXISTS idx_game_history_played_at ON game_history(played_at DESC);
CREATE INDEX IF NOT EXISTS idx_friends_user ON friends(user_username);
CREATE INDEX IF NOT EXISTS idx_friends_friend ON friends(friend_username);
CREATE INDEX IF NOT EXISTS idx_sessions_host ON game_sessions(host_username);
CREATE INDEX IF NOT EXISTS idx_sessions_guest ON game_sessions(guest_username);
CREATE INDEX IF NOT EXISTS idx_sessions_status ON game_sessions(status);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data for testing (optional)
INSERT INTO users (username, email, coins, level, total_wins, total_losses, total_draws) VALUES
    ('AlbinKosovar', 'albin@example.com', 500, 5, 25, 10, 3),
    ('DoraShqipja', 'dora@example.com', 350, 4, 18, 12, 5),
    ('EnisGamer', 'enis@example.com', 720, 7, 42, 8, 2),
    ('LindaPlay', 'linda@example.com', 280, 3, 12, 15, 4)
ON CONFLICT (username) DO NOTHING;

-- View for leaderboard
CREATE OR REPLACE VIEW leaderboard_view AS
SELECT 
    username,
    coins,
    level,
    xp,
    total_wins,
    total_losses,
    total_draws,
    CASE 
        WHEN (total_wins + total_losses) > 0 
        THEN ROUND((total_wins::numeric / (total_wins + total_losses)) * 100, 1)
        ELSE 0 
    END as win_rate,
    ROW_NUMBER() OVER (ORDER BY total_wins DESC, level DESC, xp DESC) as rank
FROM users
ORDER BY total_wins DESC, level DESC, xp DESC;

-- Success message
SELECT 'Database initialized successfully! ✅' as status;
