import mongoose from 'mongoose';

const customRequestSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    shape: { type: String, required: true },
    flavor: { type: String, required: true },
    weight: { type: String, required: true },
    theme: { type: String },
    message: { type: String },
    imageUrl: { type: String },
    publicId: { type: String },
    status: { type: String, enum: ['Requested', 'Approved', 'Rejected'], default: 'Requested', index: true },
    customPrice: { type: Number },
  },
  { timestamps: true }
);

export const CustomRequest = mongoose.models.CustomRequest || mongoose.model('CustomRequest', customRequestSchema);


