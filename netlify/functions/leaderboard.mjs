import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.NEON_DATABASE_URL);

/**
 * Leaderboard endpoint handler
 * Returns top players sorted by wins
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

  const path = event.path.replace('/.netlify/functions/leaderboard', '');
  const params = new URL(event.rawUrl).searchParams;

  try {
    // GET /leaderboard - Get global leaderboard
    if (event.httpMethod === 'GET' && !path.includes('rank')) {
      const limit = parseInt(params.get('limit') || '100');
      const offset = parseInt(params.get('offset') || '0');

      const results = await sql`
        SELECT 
          username,
          coins,
          total_wins,
          total_losses,
          total_draws,
          level,
          xp,
          (total_wins * 1.0 / NULLIF(total_wins + total_losses, 0) * 100) as win_rate
        FROM users
        ORDER BY total_wins DESC, level DESC, xp DESC
        LIMIT ${limit}
        OFFSET ${offset}
      `;

      // Add rank numbers
      const leaderboard = results.map((user, index) => ({
        ...user,
        rank: offset + index + 1,
      }));

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ leaderboard }),
      };
    }

    // GET /leaderboard/rank/:username - Get user's rank
    if (event.httpMethod === 'GET' && path.includes('rank')) {
      const username = path.split('/')[2];

      const result = await sql`
        WITH ranked_users AS (
          SELECT 
            username,
            ROW_NUMBER() OVER (ORDER BY total_wins DESC, level DESC, xp DESC) as rank
          FROM users
        )
        SELECT rank FROM ranked_users WHERE username = ${username}
      `;

      if (result.length === 0) {
        return {
          statusCode: 404,
          headers,
          body: JSON.stringify({ error: 'User not found' }),
        };
      }

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ rank: result[0].rank }),
      };
    }

    return {
      statusCode: 404,
      headers,
      body: JSON.stringify({ error: 'Endpoint not found' }),
    };

  } catch (error) {
    console.error('Leaderboard error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Internal server error', message: error.message }),
    };
  }
}
