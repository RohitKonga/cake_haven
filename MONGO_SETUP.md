# MongoDB Connection Test Script

## Step 1: Create the .env file

If you haven't created it yet, run this PowerShell command:

```powershell
@"
PORT=4000
MONGO_URI=mongodb+srv://kathiematthews02_db_user:82qWiWi5CFi9kxku@cluster0.lll5jhg.mongodb.net/cake_haven?retryWrites=true&w=majority
JWT_SECRET=change_this_to_a_long_random_secret_key_for_production_use
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
"@ | Out-File -FilePath "server\.env" -Encoding utf8
```

**IMPORTANT:** Change `JWT_SECRET` to a random string (at least 32 characters)!

## Step 2: Start the Server

```powershell
cd server
npm install
npm run dev
```

You should see: `API running on port 4000`

## Step 3: Test MongoDB Connection

Open a new terminal and run:

```powershell
curl http://localhost:4000/health
```

Or visit in browser: `http://localhost:4000/health`

You should see: `{"ok":true,"service":"cake-haven-api"}`

## Step 4: Check MongoDB Atlas

1. Go to MongoDB Atlas Dashboard
2. Click "Browse Collections"
3. You should see:
   - Database: `cake_haven` (created automatically!)
   - Collections: Will be created when you use the app (users, cakes, orders, customrequests)

## Step 5: Sign Up Through the App

1. Run your Flutter app
2. Go to Profile tab (bottom navigation)
3. Click "Sign Up"
4. Fill in: Name, Email, Password
5. Click "Sign up"

After signup, check MongoDB Atlas again - you should see a `users` collection with your user!

## Troubleshooting

**If server won't start:**
- Check if `.env` file exists in `server` folder
- Check if MONGO_URI is correct
- Check MongoDB Atlas Network Access (should allow 0.0.0.0/0 for development)

**If database doesn't appear:**
- The database `cake_haven` will be created automatically on first connection
- Collections appear when you use them (signup creates `users`, etc.)

**If signup fails:**
- Make sure server is running (`npm run dev` in server folder)
- Check server console for errors
- Try signup again

