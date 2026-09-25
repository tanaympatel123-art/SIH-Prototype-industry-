require('dotenv').config();
const app = require('./src/app');

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`\n🚀 SIH26044 Backend API running on http://localhost:${PORT}`);
  console.log(`📋 Environment : ${process.env.NODE_ENV || 'development'}`);
  console.log(`🗄️  Database    : ${process.env.DB_DATABASE}@${process.env.DB_HOST}:${process.env.DB_PORT}`);
  console.log(`🤖 AI Service  : ${process.env.AI_SERVICE_URL || 'not configured (fallback mode)'}\n`);
});
