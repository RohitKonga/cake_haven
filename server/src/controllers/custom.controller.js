import { validationResult } from 'express-validator';
import { CustomRequest } from '../models/CustomRequest.js';
import { cloudinary } from '../utils/cloudinary.js';

export async function createCustomRequest(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  const { shape, flavor, weight, theme, message } = req.body;
  const doc = await CustomRequest.create({ userId: req.user.sub, shape, flavor, weight, theme, message });
  res.status(201).json(doc);
}

export async function uploadCustomImage(req, res) {
  const doc = await CustomRequest.findById(req.params.id);
  if (!doc) return res.status(404).json({ error: 'Not found' });
  if (!req.file) return res.status(400).json({ error: 'Image file required' });
  if (!cloudinary.config().cloud_name) return res.status(500).json({ error: 'Cloudinary not configured' });

  const result = await cloudinary.uploader.upload_stream({ folder: 'cake_haven/custom' }, async (err, upload) => {
    if (err) return res.status(500).json({ error: 'Upload failed' });
    doc.imageUrl = upload.secure_url;
    doc.publicId = upload.public_id;
    await doc.save();
    return res.json({ imageUrl: doc.imageUrl });
  });
  const streamifier = await import('streamifier');
  streamifier.default.createReadStream(req.file.buffer).pipe(result);
}

export async function myCustomRequests(req, res) {
  const list = await CustomRequest.find({ userId: req.user.sub }).sort('-createdAt');
  res.json(list);
}

export async function allCustomRequests(_req, res) {
  const list = await CustomRequest.find().sort('-createdAt');
  res.json(list);
}

export async function reviewCustomRequest(req, res) {
  const { status, customPrice } = req.body;
  const doc = await CustomRequest.findByIdAndUpdate(
    req.params.id,
    { status, customPrice },
    { new: true }
  );
  if (!doc) return res.status(404).json({ error: 'Not found' });
  res.json(doc);
}


