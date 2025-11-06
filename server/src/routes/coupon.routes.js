import { Router } from 'express';
import { requireAuth, requireAdmin } from '../middleware/auth.js';
import { validateCoupon, listCoupons, createCoupon, updateCoupon, deleteCoupon } from '../controllers/coupon.controller.js';

const router = Router();

router.get('/validate/:code', validateCoupon);
router.get('/admin', requireAuth, requireAdmin, listCoupons);
router.post('/admin', requireAuth, requireAdmin, createCoupon);
router.patch('/admin/:id', requireAuth, requireAdmin, updateCoupon);
router.delete('/admin/:id', requireAuth, requireAdmin, deleteCoupon);

export default router;

