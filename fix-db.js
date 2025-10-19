const fs = require('fs');
const path = require('path');

const files = [
  'netlify/functions/leaderboard.mjs',
  'netlify/functions/games.mjs',
  'netlify/functions/statistics.mjs',
  'netlify/functions/auth.mjs',
  'netlify/functions/avatars.mjs',
  'netlify/functions/achievements.mjs',
];

const oldPattern = /const sql = neon\(process\.env\.NEON_DATABASE_URL\);/g;

const newCode = `const connectionString = process.env.NEON_DATABASE_URL 
  || process.env.NETLIFY_DATABASE_URL 
  || process.env.DATABASE_URL;

if (!connectionString) {
  console.error('❌ DATABASE ERROR: No connection string found! Set NEON_DATABASE_URL in Netlify.');
}

const sql = connectionString ? neon(connectionString) : null;`;

console.log('🔧 Fixing database connections in all functions...\n');

files.forEach(filePath => {
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    
    if (content.includes('const sql = neon(process.env.NEON_DATABASE_URL)')) {
      content = content.replace(oldPattern, newCode);
      fs.writeFileSync(filePath, content, 'utf8');
      console.log(`✅ Fixed: ${filePath}`);
    } else {
      console.log(`⏭️  Skipped (already fixed): ${filePath}`);
    }
  } catch (error) {
    console.error(`❌ Error fixing ${filePath}:`, error.message);
  }
});

console.log('\n✅ All files processed!');
console.log('\n📋 Next steps:');
console.log('1. Go to Netlify dashboard: Settings → Environment variables');
console.log('2. Add: NEON_DATABASE_URL = your_neon_connection_string');
console.log('3. Redeploy the site\n');
