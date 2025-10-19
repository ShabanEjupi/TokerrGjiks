import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.NEON_DATABASE_URL);

// Predefined achievements
const ACHIEVEMENTS = [
  { id: 'first_win', title: 'Fitorja e parë', description: 'Fitoni lojën tuaj të parë', icon: '🏆', points_required: 1 },
  { id: 'win_streak_5', title: 'Seri fitore 5', description: 'Fitoni 5 lojëra në seri', icon: '🔥', points_required: 5 },
  { id: 'win_streak_10', title: 'Seri fitore 10', description: 'Fitoni 10 lojëra në seri', icon: '⚡', points_required: 10 },
  { id: 'games_100', title: 'Veteran', description: 'Luani 100 lojëra', icon: '🎮', points_required: 100 },
  { id: 'games_500', title: 'Mjeshtër', description: 'Luani 500 lojëra', icon: '👑', points_required: 500 },
  { id: 'level_10', title: 'Nivel 10', description: 'Arrini nivelin 10', icon: '⭐', points_required: 10 },
  { id: 'level_50', title: 'Nivel 50', description: 'Arrini nivelin 50', icon: '💎', points_required: 50 },
  { id: 'pro_member', title: 'Anëtar PRO', description: 'Blini pajtimin PRO', icon: '👔', points_required: 1 },
  { id: 'coins_1000', title: 'I pasur', description: 'Mblidhni 1000 monedha', icon: '💰', points_required: 1000 },
  { id: 'friend_10', title: 'Popullor', description: 'Shtoni 10 miq', icon: '👥', points_required: 10 },
];

export default async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  try {
    // GET: Fetch user achievements
    if (req.method === 'GET') {
      const { username, action } = req.query;
      
      if (!username) {
        return res.status(400).json({ error: 'Username required' });
      }
      
      // Get all achievements with unlock status
      const unlockedAchievements = await sql`
        SELECT achievement_id, unlocked_at
        FROM achievements
        WHERE username = ${username}
      `;
      
      const unlockedIds = new Set(unlockedAchievements.map(a => a.achievement_id));
      
      const achievements = ACHIEVEMENTS.map(achievement => ({
        ...achievement,
        is_unlocked: unlockedIds.has(achievement.id),
        unlocked_at: unlockedAchievements.find(a => a.achievement_id === achievement.id)?.unlocked_at || null,
      }));
      
      // If requesting progress
      if (action === 'progress') {
        const total = ACHIEVEMENTS.length;
        const unlocked = unlockedIds.size;
        const percentage = Math.round((unlocked / total) * 100);
        
        return res.status(200).json({
          total,
          unlocked,
          percentage,
          achievements,
        });
      }
      
      return res.status(200).json({ achievements });
    }
    
    // POST: Check and unlock achievements
    if (req.method === 'POST') {
      const { 
        action, 
        username, 
        total_wins, 
        current_win_streak, 
        total_games, 
        user_level, 
        coins, 
        friends_count, 
        is_pro,
        achievement_id 
      } = req.body;
      
      // Manually unlock a specific achievement
      if (action === 'unlock') {
        if (!username || !achievement_id) {
          return res.status(400).json({ error: 'Missing parameters' });
        }
        
        // Check if already unlocked
        const existing = await sql`
          SELECT * FROM achievements
          WHERE username = ${username} AND achievement_id = ${achievement_id}
        `;
        
        if (existing.length > 0) {
          return res.status(200).json({ message: 'Achievement already unlocked' });
        }
        
        // Unlock achievement
        await sql`
          INSERT INTO achievements (username, achievement_id)
          VALUES (${username}, ${achievement_id})
        `;
        
        return res.status(200).json({ message: 'Achievement unlocked' });
      }
      
      // Check and unlock achievements based on stats
      if (action === 'check_unlock') {
        if (!username) {
          return res.status(400).json({ error: 'Username required' });
        }
        
        // Get currently unlocked achievements
        const unlocked = await sql`
          SELECT achievement_id FROM achievements
          WHERE username = ${username}
        `;
        const unlockedIds = new Set(unlocked.map(a => a.achievement_id));
        
        const newlyUnlocked = [];
        
        // Check each achievement condition
        if (total_wins >= 1 && !unlockedIds.has('first_win')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'first_win')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'first_win'));
        }
        
        if (current_win_streak >= 5 && !unlockedIds.has('win_streak_5')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'win_streak_5')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'win_streak_5'));
        }
        
        if (current_win_streak >= 10 && !unlockedIds.has('win_streak_10')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'win_streak_10')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'win_streak_10'));
        }
        
        if (total_games >= 100 && !unlockedIds.has('games_100')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'games_100')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'games_100'));
        }
        
        if (total_games >= 500 && !unlockedIds.has('games_500')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'games_500')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'games_500'));
        }
        
        if (user_level >= 10 && !unlockedIds.has('level_10')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'level_10')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'level_10'));
        }
        
        if (user_level >= 50 && !unlockedIds.has('level_50')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'level_50')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'level_50'));
        }
        
        if (is_pro && !unlockedIds.has('pro_member')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'pro_member')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'pro_member'));
        }
        
        if (coins >= 1000 && !unlockedIds.has('coins_1000')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'coins_1000')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'coins_1000'));
        }
        
        if (friends_count >= 10 && !unlockedIds.has('friend_10')) {
          await sql`INSERT INTO achievements (username, achievement_id) VALUES (${username}, 'friend_10')`;
          newlyUnlocked.push(ACHIEVEMENTS.find(a => a.id === 'friend_10'));
        }
        
        return res.status(200).json({
          newly_unlocked: newlyUnlocked,
          message: `${newlyUnlocked.length} new achievements unlocked`
        });
      }
      
      return res.status(400).json({ error: 'Invalid action' });
    }
    
    return res.status(405).json({ error: 'Method not allowed' });
    
  } catch (error) {
    console.error('Achievements error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
