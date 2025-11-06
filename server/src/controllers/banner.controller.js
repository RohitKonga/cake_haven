import { Banner } from '../models/Banner.js';
import { cloudinary } from '../utils/cloudinary.js';

export async function getBanners(req, res) {
  const banners = await Banner.find({ isActive: true }).sort('order').limit(3);
  res.json(banners);
}

export async function getAllBanners(req, res) {
  const banners = await Banner.find().sort('order');
  res.json(banners);
}

export async function uploadBanner(req, res) {
  try {
    const { order } = req.body; // 1, 2, or 3
    if (!req.file) return res.status(400).json({ error: 'Image file required' });

    if (!cloudinary.config().cloud_name) {
      return res.status(500).json({ 
        error: 'Cloudinary not configured' 
      });
    }

    const base64Image = `data:${req.file.mimetype};base64,${req.file.buffer.toString('base64')}`;
    
    const uploadResult = await cloudinary.uploader.upload(base64Image, {
      folder: 'cake_haven/banners',
      resource_type: 'image',
      transformation: [{ width: 1200, height: 400, crop: 'limit' }],
    });

    // Delete existing banner at this order position
    await Banner.findOneAndDelete({ order: parseInt(order) });

    // Create new banner
    const banner = await Banner.create({
      imageUrl: uploadResult.secure_url,
      publicId: uploadResult.public_id,
      order: parseInt(order),
      title: req.body.title || '',
      subtitle: req.body.subtitle || '',
      offerText: req.body.offerText || '',
    });

    res.json(banner);
  } catch (error) {
    console.error('Banner upload error:', error);
    res.status(500).json({ error: 'Banner upload failed: ' + error.message });
  }
}

export async function deleteBanner(req, res) {
  const banner = await Banner.findById(req.params.id);
  if (!banner) return res.status(404).json({ error: 'Not found' });

  // Delete from Cloudinary
  if (banner.publicId && cloudinary.config().cloud_name) {
    try {
      await cloudinary.uploader.destroy(banner.publicId);
    } catch (e) {
      console.error('Cloudinary delete error:', e);
    }
  }

  await Banner.findByIdAndDelete(req.params.id);
  res.json({ ok: true });
}

