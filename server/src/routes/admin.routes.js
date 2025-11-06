import { Router } from 'express';
import { requireAuth, requireAdmin } from '../middleware/auth.js';
import { User } from '../models/User.js';

const router = Router();

router.get('/users', requireAuth, requireAdmin, async (req, res) => {
  const users = await User.find().select('name email role createdAt').sort('-createdAt');
  res.json(users);
});

export default router;

