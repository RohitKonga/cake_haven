import { Router } from 'express';
import multer from 'multer';
import { body } from 'express-validator';
import { requireAuth, requireAdmin } from '../middleware/auth.js';
import { createCustomRequest, uploadCustomImage, myCustomRequests, allCustomRequests, reviewCustomRequest } from '../controllers/custom.controller.js';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

router.post(
  '/',
  requireAuth,
  [body('shape').isString(), body('flavor').isString(), body('weight').isString()],
  createCustomRequest
);

router.post('/:id/image', requireAuth, upload.single('image'), uploadCustomImage);
router.get('/me', requireAuth, myCustomRequests);

router.get('/', requireAuth, requireAdmin, allCustomRequests);
router.patch('/:id/review', requireAuth, requireAdmin, reviewCustomRequest);

export default router;


