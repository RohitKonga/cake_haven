import { Router } from 'express';
import multer from 'multer';
import { body } from 'express-validator';
import { requireAuth, requireAdmin } from '../middleware/auth.js';
import { listCakes, getCake, createCake, updateCake, deleteCake, uploadCakeImage } from '../controllers/cake.controller.js';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 5 * 1024 * 1024 } });

router.get('/', listCakes);
router.get('/:id', getCake);

router.post(
  '/',
  requireAuth,
  requireAdmin,
  [
    body('name').isString().isLength({ min: 2 }),
    body('price').isFloat({ gt: 0 }),
    body('discount').optional().isFloat({ min: 0 }),
  ],
  createCake
);

router.patch('/:id', requireAuth, requireAdmin, updateCake);
router.delete('/:id', requireAuth, requireAdmin, deleteCake);

router.post('/:id/image', requireAuth, requireAdmin, upload.single('image'), uploadCakeImage);

export default router;


