import { Router } from 'express';
import multer from 'multer';
import { requireAuth, requireAdmin } from '../middleware/auth.js';
import { getBanners, getAllBanners, uploadBanner, deleteBanner } from '../controllers/banner.controller.js';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

// Public route - get active banners
router.get('/', getBanners);

// Admin routes
router.get('/admin', requireAuth, requireAdmin, getAllBanners);
router.post('/admin', requireAuth, requireAdmin, upload.single('image'), uploadBanner);
router.delete('/admin/:id', requireAuth, requireAdmin, deleteBanner);

export default router;

