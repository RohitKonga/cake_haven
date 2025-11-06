import { Router } from 'express';
import { requireAuth, requireAdmin } from '../middleware/auth.js';
import { User } from '../models/User.js';
import { cloudinary } from '../utils/cloudinary.js';

const router = Router();

router.get('/users', requireAuth, requireAdmin, async (req, res) => {
  const users = await User.find().select('name email role createdAt').sort('-createdAt');
  res.json(users);
});

router.get('/test-cloudinary', requireAuth, requireAdmin, (req, res) => {
  const config = cloudinary.config();
  res.json({
    configured: !!config.cloud_name,
    cloudName: config.cloud_name || 'Not set',
    apiKey: config.api_key ? 'Set' : 'Not set',
    apiSecret: config.api_secret ? 'Set' : 'Not set',
    env: {
      CLOUDINARY_CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME ? 'Set' : 'Not set',
      CLOUDINARY_API_KEY: process.env.CLOUDINARY_API_KEY ? 'Set' : 'Not set',
      CLOUDINARY_API_SECRET: process.env.CLOUDINARY_API_SECRET ? 'Set' : 'Not set',
    },
  });
});

export default router;

