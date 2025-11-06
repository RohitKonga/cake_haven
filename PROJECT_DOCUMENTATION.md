# 🍰 CakeHaven - Complete Project Documentation

## 📋 Project Overview

**CakeHaven** is a full-stack online cake ordering application that allows users to browse, order, and customize cakes. The application features separate interfaces for regular users and administrators, with comprehensive order management, custom cake requests, and promotional features.

---

## 🏗️ Architecture

### **Tech Stack**

#### **Frontend (Flutter)**
- **Framework**: Flutter (Dart)
- **State Management**: Provider Pattern
- **HTTP Client**: `http` package
- **Local Storage**: `shared_preferences`
- **Image Handling**: `cached_network_image`, `image_picker`
- **UI Components**: Material Design 3
- **Other**: `intl` (date formatting), `carousel_slider` (banners)

#### **Backend (Node.js)**
- **Runtime**: Node.js (ES Modules)
- **Framework**: Express.js
- **Database**: MongoDB Atlas (Cloud)
- **ODM**: Mongoose
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: bcryptjs
- **Image Storage**: Cloudinary
- **File Upload**: Multer
- **Security**: Helmet, CORS
- **Validation**: express-validator

#### **Deployment**
- **Backend**: Render (https://cake-haven.onrender.com)
- **Database**: MongoDB Atlas (Cloud)
- **Image Storage**: Cloudinary

---

## 📱 Application Screens

### **1. User-Facing Screens**

#### **Splash Screen** (`splash_screen.dart`)
- **Purpose**: Initial loading screen
- **Features**:
  - Displays CakeHaven logo with subtitle
  - Checks user authentication status
  - Redirects admins to admin dashboard
  - Redirects regular users to home screen
  - Auto-redirects after 1.2 seconds

#### **Home Screen** (`home_screen.dart`)
- **Purpose**: Main user interface
- **Features**:
  - **Banner Carousel**: Displays up to 3 promotional banners (auto-scrolling)
  - **Category Filters**: Birthday, Anniversary, Wedding, Chocolate, etc.
  - **Recommended Cakes Section**: Grid display of available cakes
  - **Cart Badge**: Shows number of items in cart
  - **Search Icon**: Navigate to search screen
  - **Bottom Navigation**: Home, Orders, Profile tabs
  - **Guest Mode**: Shows login prompt when adding to cart
  - **Admin Redirect**: Automatically redirects admins to admin dashboard

#### **Search Screen** (`search_screen.dart`)
- **Purpose**: Search and filter cakes
- **Features**:
  - Real-time search with debouncing (500ms delay)
  - Searches across: name, flavor, description, categories
  - Grid layout (2 columns) with cake cards
  - Shows search results count
  - Empty states for no results
  - Loading states
  - Error handling with retry option

#### **Cake Detail Screen** (`cake_detail_screen.dart`)
- **Purpose**: View detailed information about a cake
- **Features**:
  - Large image display (SliverAppBar with expandable header)
  - Cake name, price, discount information
  - Product description
  - Rating section (UI ready)
  - "Add to Cart" button
  - "You May Also Like" recommendations section
  - Guest mode login prompt
  - Navigation to cart

#### **Cart Screen** (`cart_screen.dart`)
- **Purpose**: Manage shopping cart
- **Features**:
  - Display all cart items with images
  - Plus/minus buttons for quantity adjustment
  - Individual item totals
  - Coupon application section
  - Discount calculation
  - Subtotal, discount, and total display
  - Remove coupon option
  - Proceed to checkout button
  - Empty cart state

#### **Checkout Screen** (`checkout_screen.dart`)
- **Purpose**: Complete order placement
- **Features**:
  - Display saved addresses
  - Select existing address
  - Edit address option
  - Add new address form
  - Address fields: Label, Line 1, Line 2, City, State, Postal Code, Country
  - Payment method: Cash on Delivery (COD)
  - Order summary with items
  - Place Order button
  - Navigates to order confirmation screen

#### **Order Confirmation Screen** (`order_confirmation_screen.dart`)
- **Purpose**: Confirm successful order placement
- **Features**:
  - Full-screen confirmation message
  - Order details display
  - Auto-redirect to home page after 3 seconds
  - Success animation/icon

#### **Orders Screen** (`orders_screen.dart`)
- **Purpose**: View order history
- **Features**:
  - List of all user orders
  - Order status badges (Pending, Preparing, Out for Delivery, Delivered)
  - Order date and time
  - Order total
  - Order items list
  - Pull-to-refresh
  - Empty state for no orders

#### **Profile Screen** (`profile_screen.dart`)
- **Purpose**: User account management
- **Features**:
  - **Guest Mode**:
    - Welcome message
    - Login and Sign Up buttons
    - Benefits list (Save favorites, Track orders, Save addresses, Get offers)
  - **Logged In Mode**:
    - User avatar with name and email
    - Edit Profile option
    - My Addresses option
    - Logout button with confirmation dialog
  - Gradient header design
  - Card-based options layout
  - Admin redirect protection

#### **Edit Profile Screen** (`edit_profile_screen.dart`)
- **Purpose**: Update user information
- **Features**:
  - Edit name
  - Edit phone number
  - Save changes button
  - Form validation

#### **Addresses Screen** (`addresses_screen.dart`)
- **Purpose**: Manage delivery addresses
- **Features**:
  - List of saved addresses
  - Add new address
  - Edit existing address
  - Delete address
  - Address fields: Label, Line 1, Line 2, City, State, Postal Code, Country
  - Empty state for no addresses

#### **Login Screen** (`login_screen.dart`)
- **Purpose**: User authentication
- **Features**:
  - Email and password fields
  - Password visibility toggle
  - Form validation
  - Loading state
  - Error messages
  - Link to signup screen
  - Auto-redirect admins to admin dashboard
  - Clears navigation stack on login

#### **Signup Screen** (`signup_screen.dart`)
- **Purpose**: Create new user account
- **Features**:
  - Full name (required)
  - Email (required)
  - Phone number (optional)
  - Password (required, min 6 characters)
  - Confirm password (required, must match)
  - Password visibility toggles
  - Form validation
  - Loading state
  - Error messages
  - Link to login screen
  - Auto-redirect admins to admin dashboard
  - Clears navigation stack on signup

#### **Custom Cake Screen** (`custom_cake_screen.dart`)
- **Purpose**: Request custom cake designs
- **Features**:
  - **Tab 1 - New Request**:
    - Shape field (required)
    - Flavor field (required)
    - Weight/Size field (required)
    - Theme field (optional)
    - Special message/instructions (optional)
    - Image upload (reference image)
    - Submit request button
  - **Tab 2 - My Requests**:
    - List of user's custom requests
    - Status badges (Requested, Approved, Rejected, Ordered)
    - Custom price display (when approved)
    - Place Order button (for approved requests)
    - Image preview
    - Pull-to-refresh
  - Login required check
  - Address selection for ordering approved requests

---

### **2. Admin Screens**

#### **Admin Dashboard Screen** (`admin_dashboard_screen.dart`)
- **Purpose**: Main admin control center
- **Features**:
  - **Analytics Cards**:
    - Total Cakes count
    - Total Orders count
    - Total Users count
    - Total Revenue (₹)
  - **Quick Action Cards**:
    - Add New Cake
    - View All Cakes
    - Manage Users
    - View Orders
    - Custom Requests
    - Manage Banners
    - Manage Coupons
  - Welcome message
  - Pull-to-refresh
  - Profile icon in AppBar

#### **Admin Profile Screen** (`admin_profile_screen.dart`)
- **Purpose**: Admin account management
- **Features**:
  - Admin-specific header
  - Admin information display
  - Logout option

#### **Add/Edit Cake Screen** (`admin/admin_edit_cake_screen.dart`)
- **Purpose**: Create or edit cake products
- **Features**:
  - **Image Section**:
    - Image preview (existing or new)
    - Select/Change image button
  - **Basic Information**:
    - Cake Name (required)
    - Description
  - **Pricing**:
    - Price (₹) (required)
    - Discount (%)
    - Real-time discounted price calculation
    - Discount badge display
  - **Details**:
    - Flavor
    - Categories (comma-separated)
  - Form validation
  - Save/Create button
  - Success/error messages
  - Image upload to Cloudinary

#### **All Cakes Screen** (`admin/admin_cakes_list_screen.dart`)
- **Purpose**: View and manage all cakes
- **Features**:
  - **Search Bar**: Filter cakes by name or flavor
  - **Sort Filters**: Name, Price (High/Low), Discount
  - **Grid Layout**: 2-column grid with cake cards
  - **Cake Cards Display**:
    - Cake image
    - Cake name
    - Price with discount badge
    - Strikethrough original price
  - **Actions**:
    - Tap card to edit
    - Edit button
    - Delete button (with confirmation)
  - **Floating Action Button**: Add new cake
  - Empty states
  - Pull-to-refresh

#### **Manage Users Screen** (`admin/admin_users_screen.dart`)
- **Purpose**: View all registered users
- **Features**:
  - **Search Bar**: Filter by name or email
  - **Role Filters**: All Users, Admins, Users (with counts)
  - **User Cards**:
    - Gradient circular avatar (purple for admin, blue for user)
    - User name
    - Email with icon
    - Role badge
    - Join date
  - Pull-to-refresh
  - Empty states

#### **Admin Orders Screen** (`admin/admin_orders_screen.dart`)
- **Purpose**: Manage all orders
- **Features**:
  - **Status Filters**: All, Pending, Preparing, Out for Delivery, Delivered
  - **Order Cards**:
    - Order ID
    - Customer name
    - Order date
    - Status badge (color-coded)
    - Total amount
    - Expandable details:
      - Order items list
      - Delivery address
      - Payment method
  - **Status Update**: Dropdown to change order status
  - Pull-to-refresh
  - Card-based layout

#### **Custom Requests Screen** (`admin/admin_custom_requests_screen.dart`)
- **Purpose**: Review custom cake requests
- **Features**:
  - **Status Filters**: All, Requested, Approved, Rejected, Ordered
  - **Request Cards**:
    - Customer name
    - Request details (shape, flavor, weight, theme)
    - Image preview (if available)
    - Status badge
    - Request date
    - Expandable details:
      - Full request information
      - Custom message
      - Custom price (if set)
  - **Actions**:
    - Approve (with price input)
    - Reject
  - Pull-to-refresh
  - Card-based layout

#### **Banner Management Screen** (`admin/admin_banner_screen.dart`)
- **Purpose**: Manage home page banners
- **Features**:
  - 3 image picker buttons (Banner 1, Banner 2, Banner 3)
  - Upload banner images
  - Optional fields:
    - Title
    - Subtitle
    - Offer Text
  - Preview of uploaded banners
  - Delete banner option
  - Images stored in Cloudinary
  - Banners displayed on user home page carousel

#### **Coupon Management Screen** (`admin/admin_coupon_screen.dart`)
- **Purpose**: Manage discount coupons
- **Features**:
  - **Add Coupon**:
    - Coupon code (required, uppercase)
    - Discount percentage (0-100)
    - Toggle to activate/deactivate
  - **Coupon List**:
    - Coupon code
    - Discount percentage
    - Active/Inactive status badge
    - Toggle button to activate/deactivate
    - Delete button
  - Validation for coupon codes
  - Active/inactive status management

---

## 🔑 Core Features

### **User Features**

1. **Authentication**
   - User registration with email, password, name, and optional phone
   - User login with email and password
   - JWT-based session management
   - Guest mode (browse without login)
   - Login required for cart and orders

2. **Cake Browsing**
   - View all available cakes
   - Category filtering (Birthday, Anniversary, Wedding, etc.)
   - Search functionality (name, flavor, description, categories)
   - View cake details (image, description, price, discount)
   - Recommended cakes section
   - Banner carousel with promotions

3. **Shopping Cart**
   - Add cakes to cart
   - Increase/decrease quantity
   - Remove items
   - View cart total
   - Apply coupon codes
   - Discount calculation
   - Cart badge showing item count

4. **Order Management**
   - Place orders with COD payment
   - Save multiple delivery addresses
   - Edit/delete addresses
   - View order history
   - Track order status
   - Order confirmation screen

5. **Custom Cake Requests**
   - Submit custom cake design requests
   - Upload reference images
   - Specify shape, flavor, weight, theme
   - Track request status
   - Place orders for approved custom requests

6. **Profile Management**
   - Edit profile (name, phone)
   - Manage delivery addresses
   - View account information
   - Logout functionality

### **Admin Features**

1. **Cake Management**
   - Add new cakes with images
   - Edit existing cakes
   - Delete cakes
   - Upload images to Cloudinary
   - Set prices and discounts
   - Add categories and flavors

2. **Order Management**
   - View all orders
   - Filter by status
   - Update order status (Pending → Preparing → Out for Delivery → Delivered)
   - View order details

3. **User Management**
   - View all registered users
   - See user roles (admin/user)
   - Search users
   - Filter by role

4. **Custom Request Management**
   - Review custom cake requests
   - Approve/reject requests
   - Set custom prices for approved requests
   - View request details and images

5. **Banner Management**
   - Upload up to 3 banner images
   - Set banner titles, subtitles, and offer text
   - Manage home page promotional banners
   - Delete banners

6. **Coupon Management**
   - Create discount coupons
   - Set discount percentages
   - Activate/deactivate coupons
   - Delete coupons
   - Validate coupon codes

7. **Analytics Dashboard**
   - Total cakes count
   - Total orders count
   - Total users count
   - Total revenue calculation

---

## 🗄️ Database Models

### **User Model**
- `name`: String (required)
- `email`: String (required, unique)
- `passwordHash`: String (required, hashed)
- `role`: String (enum: 'user', 'admin', default: 'user')
- `phone`: String (optional)
- `addresses`: Array of address objects
  - `label`: String
  - `line1`: String
  - `line2`: String
  - `city`: String
  - `state`: String
  - `country`: String
  - `postalCode`: String
- `createdAt`: Date (auto)
- `updatedAt`: Date (auto)

### **Cake Model**
- `name`: String (required)
- `description`: String
- `ingredients`: Array of Strings
- `price`: Number (required)
- `discount`: Number (default: 0)
- `categories`: Array of Strings (indexed)
- `imageUrl`: String (Cloudinary URL)
- `publicId`: String (Cloudinary public ID)
- `flavor`: String (indexed)
- `type`: String (indexed)
- `popularity`: Number (default: 0, indexed)
- `isActive`: Boolean (default: true)
- `createdAt`: Date (auto)
- `updatedAt`: Date (auto)

### **Order Model**
- `userId`: ObjectId (ref: User, required, indexed)
- `items`: Array of cart items
  - `cakeId`: ObjectId (ref: Cake)
  - `name`: String
  - `price`: Number
  - `quantity`: Number
- `address`: String (required)
- `paymentMethod`: String (enum: 'COD', 'MOCK', default: 'COD')
- `total`: Number (required)
- `status`: String (enum: 'Pending', 'Preparing', 'Out for Delivery', 'Delivered', default: 'Pending', indexed)
- `createdAt`: Date (auto)
- `updatedAt`: Date (auto)

### **CustomRequest Model**
- `userId`: ObjectId (ref: User, required, indexed)
- `shape`: String (required)
- `flavor`: String (required)
- `weight`: String (required)
- `theme`: String (optional)
- `message`: String (optional)
- `imageUrl`: String (Cloudinary URL, optional)
- `publicId`: String (Cloudinary public ID, optional)
- `status`: String (enum: 'Requested', 'Approved', 'Rejected', 'Ordered', default: 'Requested', indexed)
- `customPrice`: Number (optional, set by admin)
- `createdAt`: Date (auto)
- `updatedAt`: Date (auto)

### **Coupon Model**
- `code`: String (required, unique, uppercase)
- `discount`: Number (required, min: 0, max: 100)
- `isActive`: Boolean (default: true)
- `expiresAt`: Date (optional)
- `createdAt`: Date (auto)
- `updatedAt`: Date (auto)

### **Banner Model**
- `imageUrl`: String (required, Cloudinary URL)
- `publicId`: String (Cloudinary public ID)
- `title`: String (optional)
- `subtitle`: String (optional)
- `offerText`: String (optional)
- `order`: Number (default: 0, for sorting: 1, 2, or 3)
- `isActive`: Boolean (default: true)
- `createdAt`: Date (auto)
- `updatedAt`: Date (auto)

---

## 🔌 API Endpoints

### **Authentication** (`/api/auth`)
- `POST /signup` - Register new user
- `POST /login` - User login
- `GET /me` - Get current user (protected)
- `PATCH /profile` - Update user profile (protected)
- `GET /addresses` - Get user addresses (protected)
- `POST /addresses` - Add new address (protected)
- `PATCH /addresses/:id` - Update address (protected)
- `DELETE /addresses/:id` - Delete address (protected)

### **Cakes** (`/api/cakes`)
- `GET /` - List all active cakes (public)
- `GET /:id` - Get cake by ID (public)
- `POST /` - Create new cake (admin)
- `PATCH /:id` - Update cake (admin)
- `DELETE /:id` - Delete cake (admin)
- `POST /:id/image` - Upload cake image (admin)

### **Orders** (`/api/orders`)
- `GET /me` - Get user's orders (protected)
- `POST /` - Create new order (protected)
- `POST /custom` - Create order from custom request (protected)
- `GET /admin` - Get all orders (admin)
- `PATCH /admin/:id` - Update order status (admin)

### **Custom Requests** (`/api/custom`)
- `POST /` - Submit custom request (protected)
- `GET /me` - Get user's requests (protected)
- `POST /:id/image` - Upload custom request image (protected)
- `GET /admin` - Get all requests (admin)
- `PATCH /admin/:id/review` - Approve/reject request (admin)

### **Admin** (`/api/admin`)
- `GET /users` - List all users (admin)
- `GET /cakes` - List all cakes (admin)
- `GET /orders` - List all orders (admin)
- `GET /custom` - List all custom requests (admin)

### **Banners** (`/api/banners`)
- `GET /` - Get active banners (public)
- `GET /admin` - Get all banners (admin)
- `POST /admin` - Create/update banner (admin)
- `DELETE /admin/:id` - Delete banner (admin)

### **Coupons** (`/api/coupons`)
- `GET /validate/:code` - Validate coupon code (protected)
- `GET /admin` - Get all coupons (admin)
- `POST /admin` - Create coupon (admin)
- `PATCH /admin/:id` - Update coupon (admin)
- `DELETE /admin/:id` - Delete coupon (admin)

### **Health Check**
- `GET /health` - Server health check

---

## 🎨 UI/UX Features

### **Design Elements**
- **Color Scheme**: Pink primary color (#E91E63)
- **Currency**: Indian Rupee (₹)
- **Logo**: Gradient text "CakeHaven" with optional subtitle "Sweet Delights"
- **Material Design 3**: Modern UI components
- **Card-based Layouts**: Consistent card design throughout
- **Gradient Backgrounds**: Used in headers and special sections
- **Icons**: Material Icons throughout

### **User Experience**
- **Guest Mode**: Browse without login, prompt to login when needed
- **Loading States**: CircularProgressIndicator for async operations
- **Error Handling**: User-friendly error messages
- **Empty States**: Helpful messages when no data
- **Pull-to-Refresh**: Available on list screens
- **Form Validation**: Real-time validation with error messages
- **Navigation**: Bottom navigation bar for main screens
- **Badges**: Cart item count, discount percentages, status indicators

---

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcryptjs for password security
- **Role-based Access**: Admin and user roles
- **Protected Routes**: Middleware for authentication
- **Input Validation**: express-validator for backend validation
- **CORS Configuration**: Configured for cross-origin requests
- **Helmet**: Security headers
- **Environment Variables**: Sensitive data in .env files

---

## 📦 State Management

### **Providers**
1. **AuthProvider**: User authentication, profile, addresses
2. **CatalogProvider**: Cake catalog management
3. **CartProvider**: Shopping cart state
4. **CustomRequestProvider**: Custom cake requests

### **Services**
1. **ApiClient**: HTTP client with JWT token injection
2. **AuthService**: Authentication operations
3. **CakeService**: Cake-related API calls
4. **OrderService**: Order management
5. **AdminService**: Admin operations
6. **BannerService**: Banner management
7. **CustomRequestService**: Custom request operations

---

## 🚀 Deployment

- **Backend**: Deployed on Render (https://cake-haven.onrender.com)
- **Database**: MongoDB Atlas (Cloud)
- **Image Storage**: Cloudinary
- **Frontend**: Can be deployed to Web, Android, iOS

---

## 📝 Key Files Structure

```
cake_haven/
├── lib/
│   ├── main.dart                    # App entry point, routes, providers
│   ├── core/
│   │   ├── models/                  # Data models (User, Cake, CartItem)
│   │   ├── providers/               # State management (Auth, Catalog, Cart, CustomRequest)
│   │   ├── services/                # API services
│   │   └── widgets/                 # Reusable widgets (Logo)
│   └── screens/
│       ├── splash_screen.dart
│       ├── home_screen.dart
│       ├── login_screen.dart
│       ├── signup_screen.dart
│       ├── profile_screen.dart
│       ├── search_screen.dart
│       ├── cake_detail_screen.dart
│       ├── cart_screen.dart
│       ├── checkout_screen.dart
│       ├── orders_screen.dart
│       ├── custom_cake_screen.dart
│       ├── edit_profile_screen.dart
│       ├── addresses_screen.dart
│       ├── order_confirmation_screen.dart
│       ├── admin_dashboard_screen.dart
│       ├── admin_profile_screen.dart
│       └── admin/
│           ├── admin_edit_cake_screen.dart
│           ├── admin_cakes_list_screen.dart
│           ├── admin_users_screen.dart
│           ├── admin_orders_screen.dart
│           ├── admin_custom_requests_screen.dart
│           ├── admin_banner_screen.dart
│           └── admin_coupon_screen.dart
└── server/
    └── src/
        ├── index.js                 # Express app setup
        ├── controllers/            # Request handlers
        ├── models/                  # Mongoose schemas
        ├── routes/                  # API routes
        ├── middleware/              # Auth middleware
        └── utils/                   # Utilities (JWT, password, cloudinary)
```

---

## ✨ Special Features

1. **Guest Mode**: Users can browse without logging in
2. **Admin Protection**: Admins automatically redirected to admin dashboard
3. **Navigation Stack Management**: Proper stack clearing on login/logout
4. **Image Upload**: Cloudinary integration for cake and banner images
5. **Coupon System**: Discount codes with activation/deactivation
6. **Custom Cake Requests**: Users can request custom designs
7. **Banner Management**: Admin-controlled promotional banners
8. **Real-time Search**: Debounced search with instant results
9. **Cart Badge**: Visual indicator of cart items count
10. **Order Tracking**: Status updates for orders

---

## 🎯 Project Summary

**CakeHaven** is a complete e-commerce solution for cake ordering with:
- **20+ Screens** (User + Admin)
- **Full Authentication System** (Login, Signup, Profile)
- **Shopping Cart** with coupon support
- **Order Management** with status tracking
- **Custom Cake Requests** workflow
- **Admin Dashboard** with analytics
- **Banner Management** for promotions
- **Coupon System** for discounts
- **Modern UI/UX** with Material Design 3
- **Cloud Storage** for images (Cloudinary)
- **Cloud Database** (MongoDB Atlas)
- **Deployed Backend** (Render)

The application is production-ready and provides a seamless experience for both customers and administrators.

