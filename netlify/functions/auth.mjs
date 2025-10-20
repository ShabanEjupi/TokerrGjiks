import { neon } from '@neondatabase/serverless';
import crypto from 'crypto';

const connectionString = process.env.NEON_DATABASE_URL 
  || process.env.NETLIFY_DATABASE_URL 
  || process.env.DATABASE_URL;

if (!connectionString) {
  console.error('❌ DATABASE ERROR: No connection string found! Set NEON_DATABASE_URL in Netlify.');
}

const sql = connectionString ? neon(connectionString) : null;

// Simple JWT generation (for demo - use proper JWT library in production)
function generateToken(username) {
  const payload = { username, timestamp: Date.now() };
  return Buffer.from(JSON.stringify(payload)).toString('base64');
}

function verifyToken(token) {
  try {
    const payload = JSON.parse(Buffer.from(token, 'base64').toString());
    return payload.username;
  } catch {
    return null;
  }
}

export async function handler(event, context) {
  // Enable CORS
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Content-Type': 'application/json',
  };
  
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }
  
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers,
      body: JSON.stringify({ error: 'Method not allowed' }),
    };
  }
  
  try {
    // Check if database is configured
    if (!sql) {
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({ 
          error: 'Database not configured. Set NEON_DATABASE_URL in Netlify environment variables.' 
        }),
      };
    }

    const { action, username, email, password, full_name, old_password, new_password } = JSON.parse(event.body || '{}');
    
    // REGISTER
    if (action === 'register') {
      // Check if username or email already exists
      const existingUser = await sql`
        SELECT username FROM users 
        WHERE username = ${username} OR email = ${email}
      `;
      
      if (existingUser.length > 0) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({ error: 'Username or email already exists' }),
        };
      }
      
      // Insert new user
      const result = await sql`
        INSERT INTO users (username, email, password, coins, level, xp, total_wins, total_losses, total_draws, created_at, updated_at)
        VALUES (${username}, ${email || null}, ${password || null}, 100, 1, 0, 0, 0, 0, NOW(), NOW())
        RETURNING *
      `;
      
      return {
        statusCode: 201,
        headers,
        body: JSON.stringify({ message: 'User registered successfully', user: result[0] }),
      };
    }
    
    // LOGIN
    if (action === 'login') {
      const user = await sql`
        SELECT * FROM users 
        WHERE username = ${username} AND password = ${password}
        LIMIT 1
      `;
      
      if (user.length === 0) {
        return {
          statusCode: 401,
          headers,
          body: JSON.stringify({ error: 'Invalid username or password' }),
        };
      }
      
      // Update last login
      await sql`
        UPDATE users 
        SET last_login_at = NOW()
        WHERE username = ${username}
      `;
      
      const token = generateToken(username);
      
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({
          message: 'Login successful',
          token,
          user: {
            username: user[0].username,
            email: user[0].email,
            coins: user[0].coins,
            level: user[0].level,
            xp: user[0].xp,
            total_wins: user[0].total_wins,
            total_losses: user[0].total_losses,
            total_draws: user[0].total_draws,
            is_pro: user[0].is_pro,
            avatar_url: user[0].avatar_url,
          }
        }),
      };
    }
    
    // VERIFY TOKEN
    if (action === 'verify') {
      const authHeader = event.headers.authorization || event.headers.Authorization;
      if (!authHeader) {
        return {
          statusCode: 401,
          headers,
          body: JSON.stringify({ error: 'No token provided' }),
        };
      }
      
      const token = authHeader.replace('Bearer ', '');
      const verifiedUsername = verifyToken(token);
      
      if (!verifiedUsername || verifiedUsername !== username) {
        return {
          statusCode: 401,
          headers,
          body: JSON.stringify({ error: 'Invalid token' }),
        };
      }
      
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ message: 'Token valid', username: verifiedUsername }),
      };
    }
    
    // CHANGE PASSWORD
    if (action === 'change_password') {
      const authHeader = event.headers.authorization || event.headers.Authorization;
      if (!authHeader) {
        return {
          statusCode: 401,
          headers,
          body: JSON.stringify({ error: 'Not authenticated' }),
        };
      }
      
      const token = authHeader.replace('Bearer ', '');
      const verifiedUsername = verifyToken(token);
      
      if (!verifiedUsername) {
        return {
          statusCode: 401,
          headers,
          body: JSON.stringify({ error: 'Invalid token' }),
        };
      }
      
      // Verify old password
      const user = await sql`
        SELECT * FROM users 
        WHERE username = ${username} AND password = ${old_password}
        LIMIT 1
      `;
      
      if (user.length === 0) {
        return {
          statusCode: 401,
          headers,
          body: JSON.stringify({ error: 'Incorrect old password' }),
        };
      }
      
      // Update password
      await sql`
        UPDATE users 
        SET password = ${new_password}, updated_at = NOW()
        WHERE username = ${username}
      `;
      
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ message: 'Password changed successfully' }),
      };
    }
    
    // REQUEST PASSWORD RESET
    if (action === 'request_reset') {
      const user = await sql`
        SELECT username, email FROM users 
        WHERE email = ${email}
        LIMIT 1
      `;
      
      if (user.length === 0) {
        return {
          statusCode: 404,
          headers,
          body: JSON.stringify({ error: 'Email not found' }),
        };
      }
      
      // In production, send email with reset link here
      // For now, just return success
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ 
          message: 'Password reset email sent (demo mode - implement email service)'
        }),
      };
    }
    
    return {
      statusCode: 400,
      headers,
      body: JSON.stringify({ error: 'Invalid action' }),
    };
    
  } catch (error) {
    console.error('Auth error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Internal server error', message: error.message }),
    };
  }
}
