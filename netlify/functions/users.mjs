import { neon } from '@neondatabase/serverless';

// Initialize Neon client
const sql = neon(process.env.NEON_DATABASE_URL);

/**
 * User endpoints handler
 * Handles user registration, retrieval, and search
 */
export async function handler(event, context) {
  // Enable CORS
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Content-Type': 'application/json',
  };

  // Handle preflight requests
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  const path = event.path.replace('/.netlify/functions/users', '');
  const method = event.httpMethod;

  try {
    // GET /users/:username - Get user by username
    if (method === 'GET' && path.startsWith('/') && !path.includes('search')) {
      const username = path.substring(1);
      
      const result = await sql`
        SELECT * FROM users 
        WHERE username = ${username}
        LIMIT 1
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
        body: JSON.stringify(result[0]),
      };
    }

    // GET /users/search?q=query - Search users by username
    if (method === 'GET' && path.includes('search')) {
      const query = new URL(event.rawUrl).searchParams.get('q') || '';
      
      const results = await sql`
        SELECT username, coins, total_wins, level 
        FROM users 
        WHERE username ILIKE ${'%' + query + '%'}
        ORDER BY total_wins DESC
        LIMIT 20
      `;

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ users: results }),
      };
    }

    // POST /users - Create new user
    if (method === 'POST') {
      const data = JSON.parse(event.body);
      const { username, email, password } = data;

      if (!username) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({ error: 'Username is required' }),
        };
      }

      // Check if user exists
      const existing = await sql`
        SELECT username FROM users WHERE username = ${username} LIMIT 1
      `;

      if (existing.length > 0) {
        return {
          statusCode: 409,
          headers,
          body: JSON.stringify({ error: 'Username already exists' }),
        };
      }

      // Create user
      const result = await sql`
        INSERT INTO users (username, email, password, coins, level, xp, total_wins, total_losses, total_draws, created_at)
        VALUES (${username}, ${email || null}, ${password || null}, 100, 1, 0, 0, 0, 0, NOW())
        RETURNING *
      `;

      return {
        statusCode: 201,
        headers,
        body: JSON.stringify(result[0]),
      };
    }

    // PUT /users/:username/stats - Update user stats
    if (method === 'PUT' && path.includes('/stats')) {
      const username = path.split('/')[1];
      const data = JSON.parse(event.body);

      const updateFields = [];
      const values = [];

      if (data.wins !== undefined) {
        updateFields.push('total_wins = total_wins + $' + (updateFields.length + 1));
        values.push(data.wins);
      }
      if (data.losses !== undefined) {
        updateFields.push('total_losses = total_losses + $' + (updateFields.length + 1));
        values.push(data.losses);
      }
      if (data.draws !== undefined) {
        updateFields.push('total_draws = total_draws + $' + (updateFields.length + 1));
        values.push(data.draws);
      }
      if (data.coins !== undefined) {
        updateFields.push('coins = coins + $' + (updateFields.length + 1));
        values.push(data.coins);
      }
      if (data.level !== undefined) {
        updateFields.push('level = $' + (updateFields.length + 1));
        values.push(data.level);
      }
      if (data.xp !== undefined) {
        updateFields.push('xp = xp + $' + (updateFields.length + 1));
        values.push(data.xp);
      }

      updateFields.push('updated_at = NOW()');

      const result = await sql`
        UPDATE users 
        SET ${sql(updateFields.join(', '))}
        WHERE username = ${username}
        RETURNING *
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
        body: JSON.stringify(result[0]),
      };
    }

    return {
      statusCode: 404,
      headers,
      body: JSON.stringify({ error: 'Endpoint not found' }),
    };

  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Internal server error', message: error.message }),
    };
  }
}
