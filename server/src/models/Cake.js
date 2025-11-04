import mongoose from 'mongoose';

const cakeSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, default: '' },
    ingredients: [{ type: String }],
    price: { type: Number, required: true },
    discount: { type: Number, default: 0 },
    categories: [{ type: String, index: true }],
    imageUrl: { type: String },
    publicId: { type: String },
    flavor: { type: String, index: true },
    type: { type: String, index: true },
    popularity: { type: Number, default: 0, index: true },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export const Cake = mongoose.models.Cake || mongoose.model('Cake', cakeSchema);


