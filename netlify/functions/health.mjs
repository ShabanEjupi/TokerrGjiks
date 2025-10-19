import { neon } from '@neondatabase/serverless';

// Try multiple environment variable names (Neon extension uses different names)
const connectionString = process.env.NEON_DATABASE_URL 
  || process.env.NETLIFY_DATABASE_URL 
  || process.env.DATABASE_URL;

if (!connectionString) {
  console.error('❌ No database connection string found! Set NEON_DATABASE_URL in Netlify environment variables.');
}

const sql = connectionString ? neon(connectionString) : null;

/**
 * Health check endpoint
 * Verifies API and database connectivity
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

  try {
    // Check if database is configured
    if (!sql) {
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({
          status: 'error',
          message: 'Database not configured',
          instructions: 'Set NEON_DATABASE_URL in Netlify environment variables',
          timestamp: new Date().toISOString(),
        }),
      };
    }

    // Test database connection
    const result = await sql`SELECT 1 as test`;
    
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        status: 'ok',
        message: 'TokerrGjiks API is running',
        database: result.length > 0 ? 'connected' : 'disconnected',
        timestamp: new Date().toISOString(),
      }),
    };
  } catch (error) {
    console.error('Health check error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        status: 'error',
        message: 'Database connection failed',
        error: error.message,
        timestamp: new Date().toISOString(),
      }),
    };
  }
}
