const fs = require('fs');

const files = [
  'netlify/functions/leaderboard.mjs',
  'netlify/functions/games.mjs',
  'netlify/functions/statistics.mjs',
  'netlify/functions/auth.mjs',
  'netlify/functions/avatars.mjs',
  'netlify/functions/achievements.mjs',
];

console.log('🔧 Adding database check to all functions...\n');

files.forEach(filePath => {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Find the try block after headers definition
    const tryPattern = /(\s+try \{)/;
    
    if (content.match(tryPattern) && !content.includes('if (!sql)')) {
      content = content.replace(
        tryPattern,
        `$1
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
`
      );
      
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`✅ Added database check to: ${filePath}`);
    } else {
      console.log(`⏭️  Skipped (already has check): ${filePath}`);
    }
  } catch (error) {
    console.error(`❌ Error: ${filePath}:`, error.message);
  }
});

console.log('\n✅ All functions updated!\n');
