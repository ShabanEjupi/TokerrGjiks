import { neon } from '@neondatabase/serverless';

const sql = neon(process.env.NEON_DATABASE_URL || process.env.NETLIFY_DATABASE_URL);

// Simplified email logging (no SendGrid needed!)
// Emails are logged to Netlify console for testing
// Students can see email content in Netlify function logs
async function sendEmail(to, subject, html) {
  console.log('\n========================================');
  console.log('📧 EMAIL NOTIFICATION');
  console.log('========================================');
  console.log(`To: ${to}`);
  console.log(`Subject: ${subject}`);
  console.log('----------------------------------------');
  console.log(html);
  console.log('========================================\n');
  
  // For production with Testmail.app or another service:
  // You can integrate their API here when ready
  // Example: await fetch('https://api.testmail.app/api/send', {...})
  
  return true;
}

export default async (req, res) => {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }
  
  try {
    const { type, username, data } = req.body;
    
    if (!username || !type) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Get user email
    const user = await sql`
      SELECT email, full_name FROM users
      WHERE username = ${username}
    `;
    
    if (user.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const userEmail = user[0].email;
    const fullName = user[0].full_name || username;
    
    let subject = '';
    let html = '';
    
    // FRIEND REQUEST
    if (type === 'friend_request') {
      const fromUsername = data.from_username;
      subject = `🎮 Kërkesë miqësie nga ${fromUsername} - TokerrGjiks`;
      html = `
        <h2>Përshëndetje ${fullName}!</h2>
        <p><strong>${fromUsername}</strong> dëshiron të bëhet miku juaj në TokerrGjiks!</p>
        <p>Hyni në aplikacion për të pranuar ose refuzuar kërkesën.</p>
        <br>
        <p>Faleminderit që luani TokerrGjiks! 🎮</p>
      `;
    }
    
    // GAME INVITE
    else if (type === 'game_invite') {
      const fromUsername = data.from_username;
      subject = `🎲 Ftesë loje nga ${fromUsername} - TokerrGjiks`;
      html = `
        <h2>Përshëndetje ${fullName}!</h2>
        <p><strong>${fromUsername}</strong> ju fton të luani një lojë TokerrGjiks!</p>
        <p>Hyni në aplikacion për të filluar lojën.</p>
        <br>
        <p>Suksese! 🏆</p>
      `;
    }
    
    // ACHIEVEMENT UNLOCKED
    else if (type === 'achievement_unlocked') {
      const achievementTitle = data.achievement_title;
      const achievementIcon = data.achievement_icon || '🏆';
      subject = `${achievementIcon} Arritje e re hapur - TokerrGjiks`;
      html = `
        <h2>Urime ${fullName}!</h2>
        <p>Keni hapur një arritje të re:</p>
        <h3>${achievementIcon} ${achievementTitle}</h3>
        <p>${data.achievement_description || ''}</p>
        <br>
        <p>Vazhdoni të luani për të hapur më shumë arritje! 🎮</p>
      `;
    }
    
    // PRO PURCHASE CONFIRMATION
    else if (type === 'pro_purchase') {
      const months = data.months || 1;
      const amount = data.amount || '€2.99';
      subject = `✅ Konfirmim blerje PRO - TokerrGjiks`;
      html = `
        <h2>Faleminderit ${fullName}!</h2>
        <p>Blerja juaj është konfirmuar:</p>
        <ul>
          <li><strong>Pajtime:</strong> TokerrGjiks PRO</li>
          <li><strong>Kohëzgjatja:</strong> ${months} muaj</li>
          <li><strong>Shuma:</strong> ${amount}</li>
        </ul>
        <p>Tani keni qasje në:</p>
        <ul>
          <li>✨ Pa reklama</li>
          <li>🎨 Tema të personalizuara</li>
          <li>📊 Statistika të avancuara</li>
          <li>👑 Statusi PRO në Leaderboard</li>
        </ul>
        <br>
        <p>Shijoni përvojën PRO! 🚀</p>
      `;
    }
    
    // COINS PURCHASE CONFIRMATION
    else if (type === 'coins_purchase') {
      const coins = data.coins || 100;
      const amount = data.amount || '€0.99';
      subject = `💰 Konfirmim blerje monedhash - TokerrGjiks`;
      html = `
        <h2>Faleminderit ${fullName}!</h2>
        <p>Blerja juaj është konfirmuar:</p>
        <ul>
          <li><strong>Monedha:</strong> ${coins} monedha</li>
          <li><strong>Shuma:</strong> ${amount}</li>
        </ul>
        <p>Monedhat janë shtuar në llogarinë tuaj!</p>
        <br>
        <p>Argëtim në lojë! 🎮</p>
      `;
    }
    
    // PASSWORD RESET
    else if (type === 'password_reset') {
      const resetToken = data.reset_token || 'DEMO_TOKEN';
      const resetLink = `https://tokerrgjik.netlify.app/reset-password?token=${resetToken}`;
      subject = `🔐 Rivendosni fjalëkalimin - TokerrGjiks`;
      html = `
        <h2>Përshëndetje ${fullName}!</h2>
        <p>Keni kërkuar të rivendosni fjalëkalimin tuaj.</p>
        <p>Klikoni linkun më poshtë për të vazhduar:</p>
        <p><a href="${resetLink}" style="padding: 10px 20px; background: #667eea; color: white; text-decoration: none; border-radius: 5px;">Rivendos Fjalëkalimin</a></p>
        <p>Nëse nuk keni kërkuar këtë, ju lutemi injoroni këtë email.</p>
        <p><em>Linku është i vlefshëm për 24 orë.</em></p>
      `;
    }
    
    else {
      return res.status(400).json({ error: 'Invalid email type' });
    }
    
    // Send email
    await sendEmail(userEmail, subject, html);
    
    return res.status(200).json({
      message: 'Email notification sent (demo mode - integrate SendGrid/Mailgun for production)',
      to: userEmail,
      type,
    });
    
  } catch (error) {
    console.error('Email notification error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
