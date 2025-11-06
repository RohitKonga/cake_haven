import { validationResult } from 'express-validator';
import { Order } from '../models/Order.js';
import { Cake } from '../models/Cake.js';
import { CustomRequest } from '../models/CustomRequest.js';

export async function createOrder(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  const { items, address, paymentMethod } = req.body;
  if (!Array.isArray(items) || items.length === 0) return res.status(400).json({ error: 'No items' });

  // Calculate totals from DB to avoid client tampering
  const cakeIds = items.map((i) => i.cakeId);
  const cakes = await Cake.find({ _id: { $in: cakeIds } });
  const idToCake = new Map(cakes.map((c) => [String(c.id), c]));

  const normalized = items.map((it) => {
    const cake = idToCake.get(String(it.cakeId));
    if (!cake) throw new Error('Invalid cake');
    const priceAfterDiscount = Math.round((cake.price * (1 - (cake.discount || 0) / 100)) * 100) / 100;
    return {
      cakeId: cake.id,
      name: cake.name,
      price: priceAfterDiscount,
      quantity: Math.max(1, Number(it.quantity || 1)),
    };
  });

  const total = normalized.reduce((sum, it) => sum + it.price * it.quantity, 0);

  const order = await Order.create({
    userId: req.user.sub,
    items: normalized,
    address,
    paymentMethod: paymentMethod || 'COD',
    total: Math.round(total * 100) / 100,
  });

  res.status(201).json(order);
}

export async function createOrderFromCustomRequest(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  const { customRequestId, address, paymentMethod } = req.body;
  
  // Find the custom request
  const customRequest = await CustomRequest.findById(customRequestId);
  if (!customRequest) return res.status(404).json({ error: 'Custom request not found' });
  
  if (customRequest.userId.toString() !== req.user.sub) {
    return res.status(403).json({ error: 'Not authorized' });
  }
  
  if (customRequest.status !== 'Approved') {
    return res.status(400).json({ error: 'Custom request must be approved before placing order' });
  }
  
  if (!customRequest.customPrice) {
    return res.status(400).json({ error: 'Custom request price not set' });
  }

  // Create order item from custom request
  const customCakeName = `Custom Cake - ${customRequest.shape} ${customRequest.flavor} (${customRequest.weight})`;
  
  const order = await Order.create({
    userId: req.user.sub,
    items: [{
      cakeId: null, // No cake ID for custom orders
      name: customCakeName,
      price: customRequest.customPrice,
      quantity: 1,
    }],
    address,
    paymentMethod: paymentMethod || 'COD',
    total: customRequest.customPrice,
  });

  // Update custom request status to indicate order placed
  customRequest.status = 'Ordered';
  await customRequest.save();

  res.status(201).json(order);
}

export async function getMyOrders(req, res) {
  const list = await Order.find({ userId: req.user.sub }).sort('-createdAt');
  res.json(list);
}

export async function getAllOrders(req, res) {
  const list = await Order.find().sort('-createdAt');
  res.json(list);
}

export async function updateOrderStatus(req, res) {
  const { status } = req.body;
  const order = await Order.findByIdAndUpdate(req.params.id, { status }, { new: true });
  if (!order) return res.status(404).json({ error: 'Not found' });
  res.json(order);
}
