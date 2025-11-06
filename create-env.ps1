@"
PORT=4000
MONGO_URI=mongodb+srv://kathiematthews02_db_user:82qWiWi5CFi9kxku@cluster0.lll5jhg.mongodb.net/cake_haven?retryWrites=true&w=majority
JWT_SECRET=change_this_to_a_long_random_secret_key_for_production_use
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
"@ | Out-File -FilePath "server\.env" -Encoding utf8

Write-Host "✅ .env file created in server folder!" -ForegroundColor Green
Write-Host "⚠️  IMPORTANT: Change JWT_SECRET to a random string before running!" -ForegroundColor Yellow

