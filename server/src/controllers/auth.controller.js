import { validationResult } from 'express-validator';
import { User } from '../models/User.js';
import { hashPassword, comparePassword } from '../utils/password.js';
import { signJwt } from '../utils/jwt.js';

export async function signup(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  const { name, email, password, phone } = req.body;
  const existing = await User.findOne({ email });
  if (existing) return res.status(409).json({ error: 'Email already in use' });

  const passwordHash = await hashPassword(password);
  const userData = { name, email, passwordHash };
  if (phone) userData.phone = phone;
  
  const user = await User.create(userData);
  const token = signJwt({ sub: user.id, email: user.email, role: user.role });
  res.status(201).json({
    token,
    user: { id: user.id, name: user.name, email: user.email, role: user.role, phone: user.phone },
  });
}

export async function login(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  const { email, password } = req.body;
  const user = await User.findOne({ email });
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });

  const ok = await comparePassword(password, user.passwordHash);
  if (!ok) return res.status(401).json({ error: 'Invalid credentials' });

  const token = signJwt({ sub: user.id, email: user.email, role: user.role });
  res.json({ token, user: { id: user.id, name: user.name, email: user.email, role: user.role } });
}

export async function me(req, res) {
  const user = await User.findById(req.user.sub).select('name email role phone');
  if (!user) return res.status(404).json({ error: 'Not found' });
  res.json({ id: user.id, name: user.name, email: user.email, role: user.role, phone: user.phone });
}

export async function updateProfile(req, res) {
  const updates = {};
  if (req.body.name) updates.name = req.body.name;
  if (req.body.phone !== undefined) updates.phone = req.body.phone || null;
  
  const user = await User.findByIdAndUpdate(req.user.sub, updates, { new: true }).select('name email role phone');
  if (!user) return res.status(404).json({ error: 'Not found' });
  res.json({ id: user.id, name: user.name, email: user.email, role: user.role, phone: user.phone });
}

export async function getAddresses(req, res) {
  const user = await User.findById(req.user.sub).select('addresses');
  if (!user) return res.status(404).json({ error: 'Not found' });
  res.json({ addresses: user.addresses || [] });
}

export async function addAddress(req, res) {
  const user = await User.findById(req.user.sub);
  if (!user) return res.status(404).json({ error: 'Not found' });
  
  user.addresses.push(req.body);
  await user.save();
  res.json({ addresses: user.addresses });
}

export async function updateAddress(req, res) {
  const user = await User.findById(req.user.sub);
  if (!user) return res.status(404).json({ error: 'Not found' });
  
  const addr = user.addresses.id(req.params.id);
  if (!addr) return res.status(404).json({ error: 'Address not found' });
  
  Object.assign(addr, req.body);
  await user.save();
  res.json({ addresses: user.addresses });
}

export async function deleteAddress(req, res) {
  const user = await User.findById(req.user.sub);
  if (!user) return res.status(404).json({ error: 'Not found' });
  
  user.addresses.pull(req.params.id);
  await user.save();
  res.json({ addresses: user.addresses });
}


