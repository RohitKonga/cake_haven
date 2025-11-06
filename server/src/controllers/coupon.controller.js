import { Coupon } from '../models/Coupon.js';

export async function validateCoupon(req, res) {
  const { code } = req.params;
  const coupon = await Coupon.findOne({ code: code.toUpperCase(), isActive: true });
  
  if (!coupon) {
    return res.status(404).json({ error: 'Invalid coupon code' });
  }

  if (coupon.expiresAt && coupon.expiresAt < new Date()) {
    return res.status(400).json({ error: 'Coupon has expired' });
  }

  res.json({ code: coupon.code, discount: coupon.discount });
}

export async function listCoupons(req, res) {
  const coupons = await Coupon.find().sort('-createdAt');
  res.json(coupons);
}

export async function createCoupon(req, res) {
  const { code, discount } = req.body;
  
  try {
    const coupon = await Coupon.create({ code: code.toUpperCase(), discount });
    res.status(201).json(coupon);
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({ error: 'Coupon code already exists' });
    }
    res.status(400).json({ error: error.message });
  }
}

export async function updateCoupon(req, res) {
  const coupon = await Coupon.findByIdAndUpdate(req.params.id, req.body, { new: true });
  if (!coupon) return res.status(404).json({ error: 'Not found' });
  res.json(coupon);
}

export async function deleteCoupon(req, res) {
  await Coupon.findByIdAndDelete(req.params.id);
  res.json({ ok: true });
}

