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

    const payload = JSON.parse(Buffer.from(token, 'base64').toString());
    return payload.username;
  } catch {
    return null;
  }
}

export default async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }
  
  try {
    const { action, username, email, password, full_name, old_password, new_password } = req.body;
    
    // REGISTER
    if (action === 'register') {
      // Check if username or email already exists
      const existingUser = await sql`
        SELECT username FROM users 
        WHERE username = ${username} OR email = ${email}
      `;
      
      if (existingUser.length > 0) {
        return res.status(400).json({ error: 'Username or email already exists' });
      }
      
      // Insert new user
      await sql`
        INSERT INTO users (username, email, password, full_name, coins, wins, losses, level, avatar_url)
        VALUES (${username}, ${email}, ${password}, ${full_name}, 100, 0, 0, 1, '')
      `;
      
      return res.status(201).json({ message: 'User registered successfully' });
    }
    
    // LOGIN
    if (action === 'login') {
      const user = await sql`
        SELECT * FROM users 
        WHERE username = ${username} AND password = ${password}
      `;
      
      if (user.length === 0) {
        return res.status(401).json({ error: 'Invalid username or password' });
      }
      
      const token = generateToken(username);
      
      return res.status(200).json({
        message: 'Login successful',
        token,
        user: {
          username: user[0].username,
          email: user[0].email,
          full_name: user[0].full_name,
          coins: user[0].coins,
          level: user[0].level,
          avatar_url: user[0].avatar_url,
        }
      });
    }
    
    // VERIFY TOKEN
    if (action === 'verify') {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        return res.status(401).json({ error: 'No token provided' });
      }
      
      const token = authHeader.replace('Bearer ', '');
      const verifiedUsername = verifyToken(token);
      
      if (!verifiedUsername || verifiedUsername !== username) {
        return res.status(401).json({ error: 'Invalid token' });
      }
      
      return res.status(200).json({ message: 'Token valid', username: verifiedUsername });
    }
    
    // CHANGE PASSWORD
    if (action === 'change_password') {
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        return res.status(401).json({ error: 'Not authenticated' });
      }
      
      const token = authHeader.replace('Bearer ', '');
      const verifiedUsername = verifyToken(token);
      
      if (!verifiedUsername) {
        return res.status(401).json({ error: 'Invalid token' });
      }
      
      // Verify old password
      const user = await sql`
        SELECT * FROM users 
        WHERE username = ${username} AND password = ${old_password}
      `;
      
      if (user.length === 0) {
        return res.status(401).json({ error: 'Incorrect old password' });
      }
      
      // Update password
      await sql`
        UPDATE users 
        SET password = ${new_password}
        WHERE username = ${username}
      `;
      
      return res.status(200).json({ message: 'Password changed successfully' });
    }
    
    // REQUEST PASSWORD RESET
    if (action === 'request_reset') {
      const user = await sql`
        SELECT username, email FROM users 
        WHERE email = ${email}
      `;
      
      if (user.length === 0) {
        return res.status(404).json({ error: 'Email not found' });
      }
      
      // In production, send email with reset link here
      // For now, just return success
      return res.status(200).json({ 
        message: 'Password reset email sent (demo mode - implement email service)'
      });
    }
    
    return res.status(400).json({ error: 'Invalid action' });
    
  } catch (error) {
    console.error('Auth error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
