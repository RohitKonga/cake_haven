import { Router } from 'express';
import { body } from 'express-validator';
import { requireAuth, requireAdmin } from '../middleware/auth.js';
import { createOrder, getMyOrders, getAllOrders, updateOrderStatus } from '../controllers/order.controller.js';

const router = Router();

router.post(
  '/',
  requireAuth,
  [
    body('address').isString().isLength({ min: 5 }),
    body('items').isArray({ min: 1 }),
    body('items.*.cakeId').isString(),
    body('items.*.quantity').optional().isInt({ min: 1 }),
  ],
  createOrder
);

router.get('/me', requireAuth, getMyOrders);

router.get('/', requireAuth, requireAdmin, getAllOrders);
router.patch('/:id/status', requireAuth, requireAdmin, [body('status').isString()], updateOrderStatus);

export default router;


