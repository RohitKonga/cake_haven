# 🖼️ Image Upload Setup Guide

## Problem
Images are not uploading or displaying because Cloudinary is not configured.

## Solution: Set Up Cloudinary

### Step 1: Create Cloudinary Account (Free)

1. Go to **https://cloudinary.com/users/register/free**
2. Sign up with your email (free tier includes 25GB storage)
3. Verify your email

### Step 2: Get Your Cloudinary Credentials

1. After login, go to **Dashboard**
2. You'll see your **Cloud Name**, **API Key**, and **API Secret**
3. Copy these values

### Step 3: Add to `.env` File

Open `server/.env` file and add:

```env
CLOUDINARY_CLOUD_NAME=your_cloud_name_here
CLOUDINARY_API_KEY=your_api_key_here
CLOUDINARY_API_SECRET=your_api_secret_here
```

**Example:**
```env
CLOUDINARY_CLOUD_NAME=demo123
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=abcdefghijklmnopqrstuvwxyz
```

### Step 4: restart Backend Server

1. Stop your server (Ctrl+C)
2. Restart it:
   ```bash
   cd server
   npm run dev
   ```

### Step 5: Test Image Upload

1. Open your app
2. Go to Admin Dashboard → Add New Cake
3. Fill in cake details
4. Click "Pick Image" and select an image
5. Click "Create Cake"
6. The image should upload and display!

---

## Troubleshooting

### Error: "Cloudinary not configured"

**Solution:** Make sure you've added all three Cloudinary variables to `server/.env` file and restarted the server.

### Error: "Image upload failed"

**Possible causes:**
1. **Invalid Cloudinary credentials** - Double-check your Cloud Name, API Key, and API Secret
2. **Image too large** - Cloudinary free tier supports up to 10MB per image
3. **Network issue** - Check your internet connection

### Images not displaying after upload

**Check:**
1. Open browser console (F12) and check for CORS errors
2. Verify the `imageUrl` field in MongoDB (should be a Cloudinary URL like `https://res.cloudinary.com/...`)
3. Check if Cloudinary URL is accessible in browser

### Images work locally but not on Render

**Solution:** Add Cloudinary environment variables in Render dashboard:
1. Go to Render Dashboard → Your Service → Environment
2. Add:
   - `CLOUDINARY_CLOUD_NAME`
   - `CLOUDINARY_API_KEY`
   - `CLOUDINARY_API_SECRET`
3. Redeploy your service

---

## Alternative: Use Local Storage (Not Recommended for Production)

If you don't want to use Cloudinary, you can modify the backend to save images locally. However, this won't work on Render (which has read-only filesystem). Cloudinary is the recommended solution for production.

---

## Image Storage Details

- **Storage:** Cloudinary (Free tier: 25GB)
- **Folder:** `cake_haven/cakes/`
- **Max Size:** 5MB per image (configured in multer)
- **Format:** Auto-optimized by Cloudinary
- **Dimensions:** Max 800x800px (auto-resized)

---

## Need Help?

If you're still having issues:
1. Check backend console logs for error messages
2. Verify `.env` file has correct values (no quotes, no spaces)
3. Make sure backend server is restarted after adding `.env` variables
4. Check Cloudinary dashboard to see if images are being uploaded

