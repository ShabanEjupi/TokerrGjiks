import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.NEON_DATABASE_URL);

/**
 * Games endpoint handler
 * Saves game results and retrieves game history
 */
export async function handler(event, context) {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Content-Type': 'application/json',
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  const path = event.path.replace('/.netlify/functions/games', '');

  try {
    // POST /games - Save game result
    if (event.httpMethod === 'POST') {
      const data = JSON.parse(event.body);
      const {
        username,
        game_mode,
        result,
        opponent_username,
        score,
        duration,
        moves_count,
        played_at,
      } = data;

      if (!username || !game_mode || !result) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({ error: 'Missing required fields' }),
        };
      }

      // Save game
      const gameResult = await sql`
        INSERT INTO game_history (
          username, game_mode, result, opponent_username, 
          score, duration, moves_count, played_at
        )
        VALUES (
          ${username}, ${game_mode}, ${result}, ${opponent_username || null},
          ${score || 0}, ${duration || 0}, ${moves_count || 0}, 
          ${played_at || new Date().toISOString()}
        )
        RETURNING *
      `;

      // Update user stats
      if (result === 'win') {
        await sql`
          UPDATE users 
          SET total_wins = total_wins + 1, xp = xp + 10, coins = coins + 5
          WHERE username = ${username}
        `;
      } else if (result === 'loss') {
        await sql`
          UPDATE users 
          SET total_losses = total_losses + 1, xp = xp + 2
          WHERE username = ${username}
        `;
      } else if (result === 'draw') {
        await sql`
          UPDATE users 
          SET total_draws = total_draws + 1, xp = xp + 5, coins = coins + 2
          WHERE username = ${username}
        `;
      }

      return {
        statusCode: 201,
        headers,
        body: JSON.stringify(gameResult[0]),
      };
    }

    // GET /games/:username - Get game history
    if (event.httpMethod === 'GET' && path.startsWith('/')) {
      const username = path.substring(1).split('?')[0];
      const params = new URL(event.rawUrl).searchParams;
      const limit = parseInt(params.get('limit') || '50');
      const offset = parseInt(params.get('offset') || '0');

      const results = await sql`
        SELECT * FROM game_history
        WHERE username = ${username}
        ORDER BY played_at DESC
        LIMIT ${limit}
        OFFSET ${offset}
      `;

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ games: results }),
      };
    }

    return {
      statusCode: 404,
      headers,
      body: JSON.stringify({ error: 'Endpoint not found' }),
    };

  } catch (error) {
    console.error('Games error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Internal server error', message: error.message }),
    };
  }
}
