import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import authRoutes from './routes/auth.routes.js';
import cakeRoutes from './routes/cake.routes.js';
import orderRoutes from './routes/order.routes.js';
import customRoutes from './routes/custom.routes.js';
import adminRoutes from './routes/admin.routes.js';
import bannerRoutes from './routes/banner.routes.js';
import couponRoutes from './routes/coupon.routes.js';

dotenv.config();

const app = express();

// CORS configuration - allow all origins for now
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PATCH', 'DELETE', 'PUT', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false
}));

app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(morgan('dev'));

app.get('/health', (_, res) => {
  const mongoStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
  res.json({ 
    ok: true, 
    service: 'cake-haven-api',
    mongodb: mongoStatus,
    timestamp: new Date().toISOString()
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/cakes', cakeRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/custom', customRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/banners', bannerRoutes);
app.use('/api/coupons', couponRoutes);

const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGO_URI || '';

// MongoDB connection options
const mongooseOptions = {
  serverSelectionTimeoutMS: 30000, // 30 seconds
  socketTimeoutMS: 45000, // 45 seconds
  connectTimeoutMS: 30000, // 30 seconds
  maxPoolSize: 10,
  retryWrites: true,
  w: 'majority'
};

async function start() {
  // Start server first - don't wait for MongoDB
  app.listen(PORT, () => {
    console.log(`🚀 API running on port ${PORT}`);
    console.log(`📍 Health check: http://localhost:${PORT}/health`);
  });

  // Connect to MongoDB in background (non-blocking)
  if (MONGO_URI) {
    console.log('🔄 Attempting to connect to MongoDB...');
    
    // Handle MongoDB connection events BEFORE connecting
    mongoose.connection.on('error', (err) => {
      console.error('❌ MongoDB connection error:', err.message);
      if (err.message.includes('authentication failed') || err.message.includes('bad auth')) {
        console.error('🔐 Authentication failed - check your username and password in MONGO_URI');
        console.error('💡 Go to MongoDB Atlas → Database Access → Edit user → Reset password');
        console.error('💡 Then update MONGO_URI in Render with the new password');
      }
    });
    
    mongoose.connection.on('disconnected', () => {
      console.warn('⚠️  MongoDB disconnected');
    });
    
    mongoose.connection.on('reconnected', () => {
      console.log('✅ MongoDB reconnected');
    });
    
    mongoose.connection.on('connected', () => {
      console.log('✅ MongoDB connected successfully');
    });

    // Try to connect (non-blocking, won't crash server)
    mongoose.connect(MONGO_URI, mongooseOptions).then(() => {
      console.log('✅ Connected to MongoDB');
    }).catch((mongoError) => {
      console.error('❌ Failed to connect to MongoDB');
      console.error('Error:', mongoError.message);
      
      if (mongoError.message.includes('authentication failed') || mongoError.message.includes('bad auth')) {
        console.error('');
        console.error('🔐 AUTHENTICATION ERROR DETECTED:');
        console.error('   The username or password in MONGO_URI is incorrect.');
        console.error('');
        console.error('📝 To fix this:');
        console.error('   1. Go to MongoDB Atlas → Security → Database Access');
        console.error('   2. Find your user: kathiematthews02_db_user');
        console.error('   3. Click "Edit" → "Edit Password"');
        console.error('   4. Set a new password and save');
        console.error('   5. Update MONGO_URI in Render with the new password');
        console.error('   6. Format: mongodb+srv://USERNAME:NEW_PASSWORD@cluster0.lll5jhg.mongodb.net/cake_haven?retryWrites=true&w=majority');
        console.error('');
      } else {
        console.error('⚠️  Server will continue running but database features will not work');
        console.error('💡 Check your MONGO_URI environment variable and MongoDB Atlas network access');
      }
    });
  } else {
    console.warn('⚠️  MONGO_URI not set, database features will not work');
    console.warn('💡 Set MONGO_URI environment variable in Render dashboard');
  }
}

start();


