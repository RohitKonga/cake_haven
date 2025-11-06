# MongoDB Atlas Setup Complete!

## ✅ What I've done:
1. Your connection string is ready to use (with database name `cake_haven` added)

## 📝 YOU NEED TO CREATE THIS FILE MANUALLY:

Create a file named `.env` in the `server` folder with this content:

```
PORT=4000
MONGO_URI=mongodb+srv://kathiematthews02_db_user:82qWiWi5CFi9kxku@cluster0.lll5jhg.mongodb.net/cake_haven?retryWrites=true&w=majority
JWT_SECRET=change_this_to_a_long_random_secret_key_for_production_use
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
```

## 🔐 IMPORTANT: Change JWT_SECRET
Replace `change_this_to_a_long_random_secret_key_for_production_use` with a long random string (at least 32 characters). You can generate one online or use a password generator.

## 🗄️ MongoDB Atlas - What to Do Next:

### 1. Network Access (Already Done if you can connect)
- ✅ Go to: MongoDB Atlas → Security → Network Access
- ✅ Make sure your IP is allowed (or 0.0.0.0/0 for development)

### 2. Database Will Be Created Automatically
- ✅ The database `cake_haven` will be created automatically when the app first connects
- ✅ Collections (users, cakes, orders, customrequests) will be created automatically when the app uses them

### 3. Create Your First Admin User:
**Option A: Through the App**
1. Run the Flutter app
2. Sign up with a new account
3. Go to MongoDB Atlas → Browse Collections → `cake_haven` → `users`
4. Find your user document
5. Click Edit → Change `role` from `"user"` to `"admin"` → Save

**Option B: Create Directly in Atlas**
1. Go to MongoDB Atlas → Browse Collections
2. Create database: `cake_haven`
3. Create collection: `users`
4. Insert document:
```json
{
  "name": "Admin User",
  "email": "admin@example.com",
  "passwordHash": "you_will_need_to_hash_this",
  "role": "admin"
}
```
*(Option A is easier - just sign up normally and change role in Atlas)*

## 🚀 Test Your Setup:

```bash
cd server
npm install
npm run dev
```

Then visit: `http://localhost:4000/health`
You should see: `{"ok":true,"service":"cake-haven-api"}`

## 📦 For Render Deployment:
When deploying to Render, add these Environment Variables:
- `MONGO_URI` = same connection string
- `JWT_SECRET` = same secret you used in .env
- `CLOUDINARY_*` = (optional, only if using Cloudinary)

