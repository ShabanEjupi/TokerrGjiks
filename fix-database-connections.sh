#!/bin/bash

# Fix database connection in all Netlify functions
# This script updates all .mjs files to handle missing environment variables gracefully

echo "🔧 Fixing database connections in all Netlify functions..."

FILES=(
  "netlify/functions/users.mjs"
  "netlify/functions/leaderboard.mjs"
  "netlify/functions/games.mjs"
  "netlify/functions/statistics.mjs"
  "netlify/functions/achievements.mjs"
  "netlify/functions/auth.mjs"
  "netlify/functions/email.mjs"
  "netlify/functions/avatars.mjs"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Fixing $file..."
    
    # Replace the database connection line
    sed -i "s|const sql = neon(process.env.NEON_DATABASE_URL);|const connectionString = process.env.NEON_DATABASE_URL || process.env.NETLIFY_DATABASE_URL || process.env.DATABASE_URL;\nif (!connectionString) {\n  console.error('❌ DATABASE ERROR: No connection string found in environment variables!');\n}\nconst sql = connectionString ? neon(connectionString) : null;|g" "$file"
    
    echo "✅ Fixed $file"
  else
    echo "⚠️  File not found: $file"
  fi
done

echo ""
echo "✅ All files updated!"
echo ""
echo "📋 IMPORTANT: You must set the database URL in Netlify:"
echo "   1. Go to: https://app.netlify.com/sites/YOUR_SITE/settings/env"
echo "   2. Add variable: NEON_DATABASE_URL"
echo "   3. Value: Your Neon connection string"
echo "   4. Redeploy the site"
echo ""
