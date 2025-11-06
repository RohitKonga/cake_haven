import mongoose from 'mongoose';

const bannerSchema = new mongoose.Schema(
  {
    imageUrl: { type: String, required: true },
    publicId: { type: String },
    title: { type: String },
    subtitle: { type: String },
    offerText: { type: String },
    order: { type: Number, default: 0 }, // 1, 2, or 3
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export const Banner = mongoose.models.Banner || mongoose.model('Banner', bannerSchema);

