# 🔧 Cloudinary Setup for Render - Step-by-Step Guide

## ⚠️ Current Issue
Your Render logs show:
```
⚠️ Cloudinary not configured. Missing: { cloud_name: true, api_key: true, api_secret: true }
```

This means the Cloudinary environment variables are not set in your Render dashboard, which is why images are not uploading.

---

## 📋 Step-by-Step Solution

### **Step 1: Create a Cloudinary Account (If you don't have one)**

1. Go to **https://cloudinary.com/users/register/free**
2. Sign up with your email (Free tier includes 25GB storage and 25GB bandwidth per month)
3. Verify your email address
4. Complete the signup process

### **Step 2: Get Your Cloudinary Credentials**

1. After logging in, you'll be on the **Dashboard** page
2. Look for the **Account Details** section (usually at the top)
3. You'll see three important values:
   - **Cloud Name** (e.g., `demo123`)
   - **API Key** (e.g., `123456789012345`)
   - **API Secret** (e.g., `abcdefghijklmnopqrstuvwxyz123456`)
4. **Copy these values** - you'll need them in the next step

> 💡 **Tip:** The API Secret is hidden by default. Click the "Reveal" button to see it.

### **Step 3: Add Environment Variables to Render**

1. **Go to Render Dashboard**
   - Visit: https://dashboard.render.com
   - Login to your account

2. **Navigate to Your Service**
   - Click on your service (likely named `cake-haven-api` or similar)
   - Or go to: https://dashboard.render.com/web/[your-service-name]

3. **Open Environment Tab**
   - In the left sidebar, click on **"Environment"**
   - Or scroll down to the **"Environment Variables"** section

4. **Add the Three Cloudinary Variables**
   Click **"Add Environment Variable"** for each one:

   **Variable 1:**
   - **Key:** `CLOUDINARY_CLOUD_NAME`
   - **Value:** `your_cloud_name` (paste your Cloud Name from Step 2)
   - Click **"Save Changes"**

   **Variable 2:**
   - **Key:** `CLOUDINARY_API_KEY`
   - **Value:** `your_api_key` (paste your API Key from Step 2)
   - Click **"Save Changes"**

   **Variable 3:**
   - **Key:** `CLOUDINARY_API_SECRET`
   - **Value:** `your_api_secret` (paste your API Secret from Step 2)
   - Click **"Save Changes"**

   > ⚠️ **Important:** 
   - Do NOT add quotes around the values
   - Do NOT add spaces before or after the values
   - Make sure the variable names are exactly as shown (case-sensitive)

5. **Example of what it should look like:**
   ```
   CLOUDINARY_CLOUD_NAME = demo123
   CLOUDINARY_API_KEY = 123456789012345
   CLOUDINARY_API_SECRET = abcdefghijklmnopqrstuvwxyz123456
   ```

### **Step 4: Redeploy Your Service**

After adding the environment variables, Render will automatically redeploy your service. You can also manually trigger a redeploy:

1. Go to your service dashboard
2. Click on **"Manual Deploy"** → **"Deploy latest commit"**
3. Wait for the deployment to complete (usually 1-2 minutes)

### **Step 5: Verify Configuration**

1. **Check Render Logs**
   - Go to your service → **"Logs"** tab
   - Look for: `✅ Cloudinary configured: [your-cloud-name]`
   - If you see this message, Cloudinary is properly configured!

2. **Test Image Upload**
   - Open your Flutter app
   - Login as admin
   - Go to Admin Dashboard → Add New Cake
   - Fill in cake details
   - Click "Pick Image" and select an image
   - Click "Create Cake"
   - The image should upload successfully!

---

## 🔍 Troubleshooting

### **Issue 1: Still seeing "Cloudinary not configured" in logs**

**Possible causes:**
- Environment variables not saved correctly
- Service not redeployed after adding variables
- Typo in variable names

**Solution:**
1. Double-check that all three variables are added in Render
2. Verify variable names are exactly: `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
3. Make sure there are no extra spaces or quotes
4. Redeploy your service manually

### **Issue 2: Image upload fails with error**

**Check Render logs for specific error messages:**

- **"Invalid API credentials"** → Double-check your Cloudinary credentials
- **"Image too large"** → Cloudinary free tier supports up to 10MB per image
- **"Network timeout"** → Check your internet connection

**Solution:**
1. Verify credentials in Cloudinary dashboard
2. Try uploading a smaller image (< 5MB)
3. Check Cloudinary dashboard → Media Library to see if uploads are happening

### **Issue 3: Images upload but don't display**

**Possible causes:**
- CORS issue
- Invalid image URL format
- Cloudinary URL not accessible

**Solution:**
1. Check the `imageUrl` in your database (should be like `https://res.cloudinary.com/[cloud-name]/image/upload/...`)
2. Try opening the URL directly in a browser
3. Check Cloudinary dashboard → Media Library to verify images are uploaded

### **Issue 4: "Unauthorized" error**

**Solution:**
- Regenerate your API Secret in Cloudinary dashboard
- Update `CLOUDINARY_API_SECRET` in Render
- Redeploy service

---

## 📸 Quick Reference: Where to Find Cloudinary Credentials

1. **Login to Cloudinary:** https://cloudinary.com/console
2. **Dashboard URL:** https://console.cloudinary.com/console
3. **Account Details Location:** Top of the dashboard, under "Account Details" section

---

## ✅ Verification Checklist

After setup, verify:

- [ ] All three environment variables added in Render
- [ ] Service redeployed after adding variables
- [ ] Render logs show: `✅ Cloudinary configured: [cloud-name]`
- [ ] Can upload images from admin dashboard
- [ ] Images display correctly in the app
- [ ] Images visible in Cloudinary Media Library

---

## 🎯 Expected Result

After completing these steps:

1. **Render Logs** should show:
   ```
   ✅ Cloudinary configured: [your-cloud-name]
   ```

2. **Image Upload** should work:
   - Admin can upload cake images
   - Images are stored in Cloudinary
   - Images display in the app

3. **Cloudinary Dashboard** should show:
   - Uploaded images in `cake_haven/cakes/` folder
   - Image URLs accessible

---

## 🆘 Still Having Issues?

If you're still experiencing problems:

1. **Check Render Logs:**
   - Go to your service → Logs tab
   - Look for any error messages related to Cloudinary

2. **Verify Environment Variables:**
   - Go to Render → Your Service → Environment
   - Confirm all three variables are present and correct

3. **Test Cloudinary Connection:**
   - Try uploading an image directly from Cloudinary dashboard
   - Verify your account is active

4. **Check Backend Code:**
   - Verify `server/src/utils/cloudinary.js` is loading environment variables correctly
   - Check that `server/src/controllers/cake.controller.js` is using Cloudinary properly

---

## 📝 Additional Notes

- **Free Tier Limits:** Cloudinary free tier includes 25GB storage and 25GB bandwidth per month
- **Image Optimization:** Cloudinary automatically optimizes images (max 800x800px for cakes)
- **Folder Structure:** Images are stored in `cake_haven/cakes/` folder in Cloudinary
- **Security:** Never commit your API Secret to Git. Always use environment variables.

---

## 🎉 Success!

Once you see `✅ Cloudinary configured` in your Render logs, your image upload feature should work perfectly!

If you need help, check the Render logs for specific error messages and refer to the troubleshooting section above.

