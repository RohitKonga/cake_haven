import { validationResult } from 'express-validator';
import { Cake } from '../models/Cake.js';
import { cloudinary } from '../utils/cloudinary.js';

export async function listCakes(req, res) {
  const { q, category, flavor, type, minPrice, maxPrice, sort } = req.query;
  const filter = { isActive: true };
  if (q) filter.name = { $regex: q, $options: 'i' };
  if (category) filter.categories = category;
  if (flavor) filter.flavor = flavor;
  if (type) filter.type = type;
  if (minPrice || maxPrice) {
    filter.price = {};
    if (minPrice) filter.price.$gte = Number(minPrice);
    if (maxPrice) filter.price.$lte = Number(maxPrice);
  }
  const sortMap = { newest: '-createdAt', popularity: '-popularity', discount: '-discount' };
  const sortBy = sortMap[sort] || 'name';
  const items = await Cake.find(filter).sort(sortBy).limit(100);
  res.json(items);
}

export async function getCake(req, res) {
  const cake = await Cake.findById(req.params.id);
  if (!cake) return res.status(404).json({ error: 'Not found' });
  res.json(cake);
}

export async function createCake(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });
  const cake = await Cake.create(req.body);
  res.status(201).json(cake);
}

export async function updateCake(req, res) {
  const cake = await Cake.findByIdAndUpdate(req.params.id, req.body, { new: true });
  if (!cake) return res.status(404).json({ error: 'Not found' });
  res.json(cake);
}

export async function deleteCake(req, res) {
  const cake = await Cake.findByIdAndDelete(req.params.id);
  if (!cake) return res.status(404).json({ error: 'Not found' });
  // Optionally delete Cloudinary asset
  if (cake.publicId && cloudinary.config().cloud_name) {
    try { await cloudinary.uploader.destroy(cake.publicId); } catch {}
  }
  res.json({ ok: true });
}

export async function uploadCakeImage(req, res) {
  try {
    const cake = await Cake.findById(req.params.id);
    if (!cake) return res.status(404).json({ error: 'Not found' });
    if (!req.file) return res.status(400).json({ error: 'Image file required' });

    // Check if Cloudinary is configured
    if (!cloudinary.config().cloud_name) {
      return res.status(500).json({ error: 'Cloudinary not configured. Please add CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET to your .env file' });
    }

    // Convert buffer to base64 for Cloudinary upload
    const base64Image = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
    
    // Upload to Cloudinary
    const uploadResult = await cloudinary.uploader.upload(base64Image, {
      folder: 'cake_haven/cakes',
      resource_type: 'image',
      transformation: [{ width: 800, height: 800, crop: 'limit' }],
    });

    // Update cake with image URL
    cake.imageUrl = uploadResult.secure_url;
    cake.publicId = uploadResult.public_id;
    await cake.save();

    res.json({ imageUrl: cake.imageUrl, publicId: cake.publicId });
  } catch (error) {
    console.error('Image upload error:', error);
    res.status(500).json({ error: 'Image upload failed: ' + error.message });
  }
}


