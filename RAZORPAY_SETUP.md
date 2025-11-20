# Razorpay Payment Gateway Setup Guide

This guide will help you set up Razorpay payment gateway for testing in your Cake Haven Flutter application.

## Step 1: Create a Razorpay Account

1. Go to [https://razorpay.com](https://razorpay.com)
2. Click on **"Sign Up"** or **"Get Started"**
3. Fill in your business details:
   - Business name
   - Email address
   - Password
   - Mobile number
4. Verify your email and mobile number
5. Complete the account setup process

## Step 2: Access Test Mode

1. After logging in, you'll be in **Test Mode** by default (indicated by a banner at the top)
2. Test Mode allows you to test payments without real money transactions
3. You can switch between Test Mode and Live Mode using the toggle in the dashboard

## Step 3: Get Your API Keys

1. Navigate to **Settings** → **API Keys** in your Razorpay dashboard
2. You'll see two keys:
   - **Key ID** (also called Razorpay Key)
   - **Key Secret** (also called Razorpay Secret)
3. Click on **"Generate Test Keys"** if you don't see any keys
4. **Important**: Keep your Key Secret confidential and never expose it in client-side code

## Step 4: Configure Keys in Flutter App

1. Open `lib/core/services/razorpay_service.dart`
2. Replace the placeholder values:

```dart
// Replace these with your actual Razorpay test keys
static const String _keyId = 'YOUR_RAZORPAY_KEY_ID'; // Replace with your test key ID
static const String _keySecret = 'YOUR_RAZORPAY_KEY_SECRET'; // Replace with your test key secret
```

3. Example:
```dart
static const String _keyId = 'rzp_test_xxxxxxxxxxxxx';
static const String _keySecret = 'xxxxxxxxxxxxxxxxxxxxx';
```

**Note**: The `_keySecret` is included in the service but is not used in the Flutter app directly. It's kept for reference and would be needed if you implement server-side order creation.

## Step 5: Test Payment Flow

### Test Cards for Testing

Razorpay provides test cards that you can use to simulate different payment scenarios:

#### Successful Payment
- **Card Number**: `4111 1111 1111 1111`
- **Expiry**: Any future date (e.g., `12/25`)
- **CVV**: Any 3 digits (e.g., `123`)
- **Name**: Any name

#### Failed Payment
- **Card Number**: `4000 0000 0000 0002`
- **Expiry**: Any future date
- **CVV**: Any 3 digits
- **Name**: Any name

#### Other Test Scenarios
- **Card Number**: `4000 0000 0000 9995` - Insufficient funds
- **Card Number**: `4000 0000 0000 0069` - Card declined

### Testing Steps

1. Run your Flutter app
2. Add items to cart
3. Go to checkout screen
4. Select **"Online Payment"** option
5. Fill in address details
6. Click **"Place Order"**
7. Razorpay payment gateway will open
8. Use test card details mentioned above
9. Complete the payment
10. You should see order confirmation on successful payment

## Step 6: Verify Payment in Dashboard

1. Go to Razorpay Dashboard → **Payments**
2. You'll see all test payments listed here
3. Check payment status, amount, and other details

## Important Notes

### Security Best Practices

1. **Never commit API keys to version control**
   - Add `razorpay_service.dart` to `.gitignore` if it contains real keys
   - Or use environment variables/flutter_dotenv package

2. **Key Secret Usage**
   - The Key Secret should only be used on your backend server
   - Never expose it in client-side code (Flutter app)
   - For production, implement server-side order creation

3. **Test vs Live Keys**
   - Test keys start with `rzp_test_`
   - Live keys start with `rzp_live_`
   - Always use test keys during development

### Production Setup

For production deployment:

1. **Switch to Live Mode** in Razorpay dashboard
2. **Get Live API Keys** from Settings → API Keys
3. **Update the keys** in your app
4. **Implement server-side order creation** for better security:
   - Create orders on your backend server
   - Use Razorpay server SDK to create orders
   - Pass order_id to Flutter app
   - Verify payment signatures on server

### Phone Number Requirement

The app requires users to have a phone number in their profile for online payments. Users will be prompted to update their profile if the phone number is missing.

## Troubleshooting

### Payment Gateway Not Opening
- Check if Razorpay keys are correctly configured
- Verify internet connection
- Check console for error messages

### Payment Fails Immediately
- Verify you're using test cards correctly
- Check if amount is valid (minimum ₹1)
- Ensure phone number is in correct format (10 digits for India)

### "Phone number required" Error
- User needs to add phone number in profile
- Phone number should be 10 digits for Indian numbers

## Additional Resources

- [Razorpay Flutter Documentation](https://razorpay.com/docs/payments/payment-gateway/flutter-integration/)
- [Razorpay Test Cards](https://razorpay.com/docs/payments/test-cards/)
- [Razorpay Dashboard](https://dashboard.razorpay.com/)

## Support

For Razorpay-related issues:
- Check Razorpay documentation
- Contact Razorpay support through dashboard
- Visit Razorpay community forums

