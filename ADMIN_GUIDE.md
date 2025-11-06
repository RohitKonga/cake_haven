# 🎂 How to Access Admin Panel & Add Cakes

## Step 1: Make Your User an Admin

### Option A: Through MongoDB Atlas (Recommended)

1. **Sign up/sign in** to your app normally
2. Go to **MongoDB Atlas Dashboard**
3. Click **"Browse Collections"**
4. Select database: **`cake_haven`**
5. Select collection: **`users`**
6. Find your user document (by email)
7. Click **"Edit Document"** (pencil icon)
8. Find the `role` field
9. Change it from `"user"` to `"admin"`:
   ```json
   {
     "role": "admin"
   }
   ```
10. Click **"Update"** to save
11. **Logout and login again** in your app

### Option B: Create Admin User Directly in MongoDB

In MongoDB Atlas, insert a new document manually:
```json
{
  "name": "Admin User",
  "email": "admin@cakehaven.com",
  "passwordHash": "will_be_hashed_when_you_signup",
  "role": "admin"
}
```
*(Better to use Option A - signup normally and change role)*

---

## Step 2: Access Admin Panel

1. **Open your Flutter app**
2. **Make sure you're logged in** (Profile tab should show your name)
3. Go to **Profile tab** (bottom navigation - person icon)
4. You should now see **"Admin Dashboard"** card
5. **Tap "Admin Dashboard"**

---

## Step 3: Add New Cakes

### From Admin Dashboard:

1. **Tap "Cakes"** card
2. **Tap the "+" button** (floating action button at bottom right)
3. Fill in the form:

   **Basic Information:**
   - **Cake Name*** (required): e.g., "Chocolate Delight"
   - **Description**: Full description of the cake

   **Pricing:**
   - **MRP (Original Price)***: e.g., `999`
   - **Discount (%)**: e.g., `20` (for 20% off)
   - **Discounted Price** will be calculated automatically and shown

   **Details:**
   - **Flavor**: e.g., "Chocolate"
   - **Type**: e.g., "Cake", "Cupcake", "Pastry"
   - **Categories**: Comma separated, e.g., "Birthday, Wedding, Anniversary"
   - **Ingredients**: Comma separated, e.g., "Flour, Sugar, Eggs, Chocolate"

   **Image:**
   - **Tap "Pick Image"** button
   - Select image from gallery
   - Image preview will show
   - Tap "Change Image" if you want to replace it

4. **Tap "Create Cake"** button
5. Wait for "Cake created successfully" message
6. Image will upload automatically after cake is created

---

## 🎨 Admin Panel Features

### Cakes Management
- ✅ **View all cakes** - List of all cakes
- ✅ **Add new cake** - Tap "+" button
- ✅ **Edit cake** - Tap any cake in the list
- ✅ **Upload image** - Pick image from gallery
- ✅ **Real-time price calculation** - See discounted price as you type

### Orders Management
- ✅ **View all orders** - See customer orders
- ✅ **Update order status** - Tap menu (3 dots) on any order
  - Pending → Preparing → Out for Delivery → Delivered

### Custom Requests
- ✅ **View custom cake requests** - See customer requests
- ✅ **Approve/Reject** - Tap menu on any request
- ✅ **Set custom price** - When approving, set price

---

## 📝 Notes

- **Image Upload**: Requires Cloudinary setup (optional). If not set, cakes will work but without images.
- **Price Calculation**: Discounted Price = MRP × (1 - Discount%)
- **Required Fields**: Name and Price are required
- **Categories**: Use commas to separate multiple categories
- **Ingredients**: Use commas to separate ingredients

---

## 🔧 Troubleshooting

**No Admin Dashboard visible?**
- Make sure `role` is set to `"admin"` in MongoDB
- Logout and login again

**Can't create cakes?**
- Make sure backend server is running (`npm run dev` in server folder)
- Check you're logged in (token exists)
- Check backend console for errors

**Image not uploading?**
- Cloudinary might not be configured
- Check `.env` file in server folder for Cloudinary credentials
- Images are optional - cakes work without them

---

## 🎯 Quick Checklist

- [ ] User role changed to "admin" in MongoDB
- [ ] Logged out and logged back in
- [ ] Admin Dashboard visible in Profile tab
- [ ] Backend server running (`npm run dev`)
- [ ] Successfully added a cake with image!

