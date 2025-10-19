import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.NEON_DATABASE_URL);

/**
 * Statistics endpoint handler
 * Returns comprehensive user statistics
 */
export async function handler(event, context) {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  const path = event.path.replace('/.netlify/functions/statistics', '');

  try {
    // GET /statistics/:username - Get user statistics
    if (event.httpMethod === 'GET' && path.startsWith('/')) {
      const username = path.substring(1);

      // Get user data
      const userResult = await sql`
        SELECT * FROM users WHERE username = ${username} LIMIT 1
      `;

      if (userResult.length === 0) {
        return {
          statusCode: 404,
          headers,
          body: JSON.stringify({ error: 'User not found' }),
        };
      }

      const user = userResult[0];

      // Get game statistics
      const gameStats = await sql`
        SELECT 
          game_mode,
          COUNT(*) as total_games,
          SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) as wins,
          SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) as losses,
          SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) as draws,
          AVG(duration) as avg_duration,
          AVG(moves_count) as avg_moves
        FROM game_history
        WHERE username = ${username}
        GROUP BY game_mode
      `;

      // Get recent games
      const recentGames = await sql`
        SELECT * FROM game_history
        WHERE username = ${username}
        ORDER BY played_at DESC
        LIMIT 10
      `;

      // Calculate win rate
      const totalGames = user.total_wins + user.total_losses + user.total_draws;
      const winRate = totalGames > 0 ? (user.total_wins / totalGames * 100).toFixed(1) : 0;

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          user: {
            username: user.username,
            coins: user.coins,
            level: user.level,
            xp: user.xp,
            total_wins: user.total_wins,
            total_losses: user.total_losses,
            total_draws: user.total_draws,
            win_rate: parseFloat(winRate),
            created_at: user.created_at,
          },
          game_stats: gameStats,
          recent_games: recentGames,
        }),
      };
    }

    return {
      statusCode: 404,
      headers,
      body: JSON.stringify({ error: 'Endpoint not found' }),
    };

  } catch (error) {
    console.error('Statistics error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Internal server error', message: error.message }),
    };
  }
}
