# 🍱 CampusBite - Smart Canteen Ordering System

> **A complete, fully functional, production-ready Smart Canteen Ordering System built with Flutter, Firebase, and responsive Web Deployment for Render.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Core%20%7C%20Auth%20%7C%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![Render](https://img.shields.io/badge/Deploy-Render-46E3B7?logo=render)](https://render.com)
[![Platform](https://img.shields.io/badge/Platforms-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Desktop-blue)](#)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🌟 Overview

**CampusBite** is a modern, queue-free dining solution designed for university campuses, corporate cafeterias, and food courts. It eliminates long lunch queues through **scheduled pickup slots**, **real-time kitchen order tracking**, **digital token QR codes**, **campus wallet integration**, and a dedicated **Kitchen Display System (KDS)** for canteen staff.

The system is 100% responsive across mobile, tablet, and desktop viewports, with full **Flutter Web** support and pre-configured deployment files for **Render**.

---

## ✨ Features & Capabilities

### 🔐 1. Authentication & Role-Based Access
- **Email & Password Authentication**: Firebase Authentication integration with persistent sessions.
- **Roles**:
  - **Student / Diner**: Browse menu, customize meals, choose pickup slots, pay via wallet/UPI, track live order status.
  - **Canteen Staff / Kitchen Admin**: Live Kitchen Display System (KDS) order board, menu stock manager, add/edit dishes, slot occupancy monitor, and revenue analytics.
- **1-Click Evaluator Switcher**: Instant role toggle between Student and Admin directly in the UI for effortless testing.

### 🍔 2. Rich Food Menu with Real Images
- High-resolution, appetizing food photography (Masala Dosa, Biryani, Burgers, Alfredo Pasta, Nachos, Artisan Cold Brew, Lava Cake, etc.).
- Categorized navigation: *All, Breakfast, Lunch, Snacks, Beverages, Desserts, Daily Specials*.
- **Dietary Badges**: 🟢 100% Pure Vegetarian vs 🔴 Non-Veg tags.
- **Nutritional & Prep Info**: Calorie count (kcal), preparation time (mins), customer star ratings, and allergen warnings.
- **Search & Live Filtering**: Search by dish name, category, or ingredients; filter by "Veg Only"; sort by Popularity, Price (Low-High / High-Low), or Fastest Prep.

### 🛍️ 3. Interactive Cart & Promotions
- Add items with custom quantity steppers.
- Custom add-ons (e.g. Extra Ghee, Cheese Slice, Garlic Bread, Espresso Shot).
- Special cooking instructions field (e.g. *"Less spicy, pack chutney separately"*).
- **Promo Coupon Engine**:
  - `STUDENT20` — 20% discount on total meal.
  - `HUNGRY10` — 10% discount.
- Comprehensive bill breakdown: Subtotal, Coupon Savings, Packaging/Tray fee, 5% Canteen GST, and Grand Total.

### ⏰ 4. Smart Pickup Slots (Zero Waiting Time)
- Categorized time slots across *Morning, Lunch, and Evening Snacks* periods.
- Dynamic slot occupancy tracker (*"12 slots left"*, *"Filling Fast - 2 left"*, *"Full / Sold Out"*).
- Prevents canteen congestion by distributing kitchen load across 30-minute pickup windows.

### 💳 5. Checkout & Payments
- **Campus Student Wallet**: Fast, tap-to-pay dining balance with real-time balance check and 1-tap top-up (+₹100, +₹200, +₹500).
- **UPI QR / GooglePay / PhonePe / Paytm**: Simulated scan & pay.
- **Credit / Debit Cards**: Secure payment processing simulation.
- **Pay Cash at Pickup Counter**: For diners paying on meal collection.

### 📍 6. Real-Time Order Tracking & QR Pickup Token
- Dynamic visual progress stepper:
  1. **Order Placed**: Received and queued in the kitchen.
  2. **Kitchen Prep**: Chefs preparing meal fresh.
  3. **Ready at Counter**: Waiting hot at designated counter.
  4. **Collected / Done**: Fulfilled and enjoyed!
- High-visibility digital **Pickup Token Number** (e.g., `#CT-108`).
- Counter designation (e.g., *Counter 1 - Main Hall* or *Counter 2 - Express Lane*).
- Dynamic digital **QR Code** for instant staff counter scanning.
- Testing simulator buttons to advance kitchen states in real time.

### 📜 7. Order History & One-Click Reorder
- Separate tabs for **Active Orders** and **Past Orders**.
- View complete itemized digital receipts with timestamps and tax breakdowns.
- 1-click **"Reorder"** button to re-add favorite past meals directly into the cart.

### 👨‍🍳 8. Admin & Kitchen Display System (KDS)
- **Live KDS Order Board**: Incoming orders with items checklist, special notes, and 1-click progression buttons (*"Start Cooking"*, *"Mark Ready at Counter"*, *"Mark Collected"*).
- **Menu Stock Management**: Instant toggles for *"In Stock"* / *"Sold Out"* with real-time sync across all diner menus.
- **Add New Dish Modal**: Create new food items with name, price, category, photo URL, prep time, and dietary tags.
- **Analytics & Slot Load**: Monitor today's total revenue, active orders count, and live pickup slot occupancy bars.

---

## 🏗️ Architecture & Project Structure

The project follows clean architecture principles with reactive state management using **Provider** and dual-mode **Firebase / Offline-Resilient Services**:

```
smart_canteen_order/
├── lib/
│   ├── main.dart                      # Application entry point & Provider setup
│   ├── firebase_options.dart          # FlutterFire configuration template
│   ├── constants/
│   │   ├── app_colors.dart            # Emerald & Warm Amber brand palettes
│   │   ├── app_constants.dart         # Canteen slots, coupons, pricing rules
│   │   └── app_theme.dart             # Material 3 light & dark theme definitions
│   ├── models/
│   │   ├── food_item.dart             # Food item, add-ons, allergen models
│   │   ├── cart_item.dart             # Cart item and line-item totals
│   │   ├── pickup_slot.dart           # Time slot & occupancy model
│   │   ├── order_model.dart           # Order, tokens, statuses, and steps
│   │   └── user_model.dart            # Student & Staff profile model
│   ├── services/
│   │   ├── firebase_service.dart      # Safe Firebase initialization
│   │   ├── auth_service.dart          # Firebase Auth with fallback
│   │   └── database_service.dart      # Firestore & reactive stream store
│   ├── providers/
│   │   ├── auth_provider.dart         # User auth & role state
│   │   ├── menu_provider.dart         # Menu catalog, search & filters
│   │   ├── cart_provider.dart         # Cart state, coupons & discounts
│   │   ├── order_provider.dart        # Orders, KDS state & slot bookings
│   │   └── theme_provider.dart        # Light/Dark mode with SharedPreferences
│   ├── screens/
│   │   ├── splash_screen.dart         # Animated brand intro screen
│   │   ├── navigation_shell.dart      # Responsive desktop sidebar / mobile nav
│   │   ├── auth/                      # Login & Registration screens
│   │   ├── home/                      # Food Menu & Food Detail bottom sheet
│   │   ├── cart/                      # Cart, Checkout & Order Success
│   │   ├── orders/                    # Order Tracking & Order History
│   │   ├── profile/                   # User Profile, Wallet Top-Up & Settings
│   │   └── admin/                     # Kitchen KDS, Stock & Analytics
│   ├── widgets/
│   │   ├── food_card.dart             # Food card with veg badge & quantity
│   │   ├── category_chips.dart        # Horizontal category selector
│   │   ├── pickup_slot_picker.dart    # Time slot selector with load tags
│   │   ├── status_stepper.dart        # Animated kitchen order tracker
│   │   ├── qr_token_widget.dart       # High-contrast token & QR code
│   │   ├── responsive_layout.dart     # Responsive screen breakpoints
│   │   └── bill_summary_card.dart     # Subtotal, taxes & discount card
│   └── utils/
│       └── mock_data.dart             # Real food items with Unsplash photos
├── web/
│   ├── index.html                     # Flutter Web bootstrap & Firebase SDK
│   └── manifest.json                  # Web App Manifest (PWA)
├── public/
│   └── index.html                     # Live responsive single-page web app
├── build/web/
│   └── index.html                     # Pre-packaged web build for instant host
├── test/
│   ├── cart_test.dart                 # Cart & discount logic tests
│   └── menu_filter_test.dart          # Category & veg filter tests
├── Dockerfile                         # Multi-stage Flutter + Nginx container
├── nginx.conf                         # High-performance SPA & asset caching
├── render.yaml                        # 1-Click Render Blueprint specification
├── server.js                          # Lightweight zero-dependency web server
├── package.json                       # Node service descriptor
└── pubspec.yaml                       # Flutter package dependencies
```

---

## 🚀 How to Run Locally

### Option 1: Run the Live Web Version (Zero Dependencies)
You can run the live web version immediately using the bundled Node server:

```bash
# 1. Start the server
npm start
# or: node server.js

# 2. Open in your browser:
# http://localhost:3000
```

### Option 2: Run with Flutter SDK
If you have the Flutter SDK installed on your system:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run on Chrome (Flutter Web)
flutter run -d chrome

# 3. Or run on Android emulator / device
flutter run -d android
```

### Option 3: Run Unit & Widget Tests
```bash
flutter test
```

---

## ☁️ Deploying to Render (Public Live Web Version)

Render provides free hosting for both **Web Services** and **Docker Services**. This project includes ready-to-use configuration for both:

### Method A: Deploy as a Node Web Service (Recommended & Fastest)
1. Push this repository to your **GitHub** account.
2. Log in to your [Render Dashboard](https://dashboard.render.com/).
3. Click **"New +"** → **"Web Service"**.
4. Connect your GitHub repository.
5. Configure the settings:
   - **Name**: `smart-canteen-ordering`
   - **Environment / Runtime**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `node server.js`
   - **Plan**: `Free`
6. Click **"Deploy Web Service"**.
7. Render will build and deploy the app in under 30 seconds and provide your public URL (e.g. `https://smart-canteen-ordering.onrender.com`).

### Method B: Deploy using Dockerfile & Nginx
1. In the Render Dashboard, create a **Web Service**.
2. Select **"Docker"** as the runtime.
3. Render will automatically detect the `Dockerfile` and `nginx.conf` in the root directory.
4. Render will compile the Flutter Web application and serve it via Nginx with automated gzip and SPA rewrite routing!

### Method C: Deploy via Render Blueprint (`render.yaml`)
1. Click **"New +"** → **"Blueprint"** in your Render Dashboard.
2. Select your repository.
3. Render will read `render.yaml` and configure the entire environment automatically!

---

## 🔥 Firebase Configuration Guide

The application comes with **Dual-Mode Firebase Architecture**:
- **Offline / Resilient Demo Mode**: Works immediately out-of-the-box with reactive local state and persistence so anyone cloning the repo can demo the full app without needing a GCP billing account.
- **Real Firebase Cloud Mode**: Connects to your live Firebase Cloud Firestore and Firebase Auth when you provide your project credentials.

### Connecting your own Firebase Project:
1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a project (e.g., `smart-canteen-app`).
2. Enable **Authentication** (Email/Password provider).
3. Enable **Cloud Firestore Database** (Start in test mode or production rules).
4. Update `lib/firebase_options.dart` with your Web, Android, and iOS API keys.
5. Place your downloaded `google-services.json` inside `android/app/google-services.json`.
6. Run `flutter build web` or `flutter run` — the app will automatically detect real Firebase credentials and sync data with the cloud!

---

## 👤 Demo Credentials

For quick evaluation, click the demo shortcut buttons on the Login screen, or use these credentials:

| Role | Email | Password |
| :--- | :--- | :--- |
| **Student Diner** | `student@campus.edu` | `password123` |
| **Canteen Admin / Staff** | `admin@canteen.edu` | `adminpassword123` |

> 💡 **Tip:** You can also toggle between Student and Admin mode at any time using the **"Switch Role"** button in the sidebar or under Profile Settings!

---

## 📄 License
This project is open-source and released under the [MIT License](LICENSE).

