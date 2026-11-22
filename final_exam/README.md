# CS Elective 2 - Final Exam Project: E-Commerce Mobile App

A fully-fledged, role-based Flutter E-Commerce application with Riverpod state management and a secure, production-grade Supabase backend schema.

---

## 📋 Architecture & Highlights

- **State Management**: Pure **Riverpod (`flutter_riverpod: ^2.6.1`)** with clean separation:
  - **Screens / UI**: Presentation only, zero direct database access.
  - **Providers**: Manage reactive application state (`authProvider`, `productProvider`, `categoriesProvider`, `cartProvider`, `customerOrdersProvider`, `adminOrdersProvider`, `checkoutProvider`).
  - **Services**: `SupabaseService` is the **only** layer that communicates with Supabase.
  - **Models**: Immutable, typed data models (`Role`, `Profile`, `Category`, `Product`, `Order`, `OrderItem`).
- **Backend Schema**: Complete PostgreSQL relational database on Supabase:
  - 6 Relational Tables: `roles`, `profiles`, `categories`, `products`, `orders`, `order_items`.
  - Stored Procedures & Triggers: `handle_new_user()`, `is_admin()`, and transactional RPC `place_order(items)`.
  - Comprehensive Row-Level Security (RLS) on all 6 tables matching the permission matrix.
- **Authentication & Auth Gating**:
  - Email & Password registration with first/last name profile sync.
  - Google OAuth Sign-in integration.
  - Auth Gate: Unauthenticated users are redirected to `/login`.
  - Seamless role detection (`customer` vs `admin`).
- **Role-Based Experience**:
  - **Admin**:
    - Floating Action Button (FAB) on product list redirecting to Add Product Form.
    - Edit & Delete buttons on each product card (with confirmation dialog naming the product).
    - Add & Edit Product Form with validation (name required, price $\ge 0$, stock $\ge 0$).
    - Admin Order List with live status updater (`done`, `processing`, `completed`, `cancelled`).
    - Excluded from adding items to cart or checkout.
  - **Customer**:
    - Browse products with search, category filtering chips, price range slider, and pagination bar.
    - "Add to Cart" button (preventing quantities above stock, disabled if sold out).
    - Shopping Cart with running total, item counts, and quantity management.
    - Atomic Checkout (`place_order` transaction) that deducts stock and records order items snapshot.
    - Order Confirmation Screen displaying order number, total, and status.
    - Order History Screen listing customer's own orders (newest first).
    - Never sees admin controls.

---

## 🗄️ Supabase Backend Setup Guide

The complete, ready-to-run backend script is located at:
`final_exam/supabase_final_exam.sql`

### Step 1: Execute SQL in Supabase Dashboard
1. Open your Supabase Dashboard: [https://supabase.com/dashboard](https://supabase.com/dashboard).
2. Navigate to your project, then click on the **SQL Editor** tab on the left sidebar.
3. Click **New Query**, copy the entire contents of `supabase_final_exam.sql`, paste it into the editor, and click **Run**.
4. This script will automatically:
   - Create all 6 tables (`roles`, `profiles`, `categories`, `products`, `orders`, `order_items`).
   - Create functions: `handle_new_user()`, `is_admin()`, `place_order()`, and `make_user_admin()`.
   - Attach the trigger `on_auth_user_created` to `auth.users`.
   - Enable Row-Level Security (RLS) and install all required policies.
   - Create the `product-images` storage bucket.
   - Seed initial roles, categories, and products with authentic lore and images.

### Step 2: Elevating a User to Administrator
When a user signs up via email/password or Google, they start as a **customer**.
To promote a user account to **admin**, run this single command in your Supabase SQL Editor:
```sql
SELECT public.make_user_admin('your-registered-email@example.com');
```

---

## 📸 Screenshots Required for Final Exam Submission

According to the submission instructions, you must take screenshots of your backend setup and store them in a shared Google Drive folder:

1. **Database Schema**:
   - Go to **Database** -> **Schema Visualizer** (or **Table Editor**).
   - Screenshot showing the 6 tables: `roles`, `profiles`, `categories`, `products`, `orders`, `order_items` and their relationships.
2. **Database Functions and Triggers**:
   - Go to **Database** -> **Functions** (shows `handle_new_user`, `is_admin`, `place_order`).
   - Go to **Database** -> **Triggers** (shows `on_auth_user_created` on `auth.users`).
3. **Users Table**:
   - Go to **Authentication** -> **Users** (shows registered user rows).
   - Go to **Table Editor** -> `public.profiles` (shows linked user profiles and `role_id`).
4. **Row-level Security (RLS) Policies**:
   - Go to **Authentication** -> **Policies** (or **Database** -> **Policies**).
   - Screenshot displaying enabled RLS and active policies for all tables (`products`, `categories`, `orders`, `order_items`, `profiles`, `roles`).

---

## 🚀 Running the App & Tests

### Run Automated Test Suite
From the repository root:
```bash
cd final_exam
flutter test
```
All 17 tests verify auth gating, Riverpod state management, cart stock enforcement, atomic checkout, and admin vs customer permissions.

### Run App on Chrome / Windows / Mobile
```bash
cd final_exam
flutter run -d chrome
# or
flutter run -d windows
```

---

## 📤 Submission Checklist

1. **Git Branch**:
   ```bash
   git add final_exam
   git commit -m "feat(final-exam): complete e-commerce app with Riverpod and Supabase backend"
   git push origin final-exam
   ```
2. **Submit Links**:
   - GitHub Repository Link pointing to `final-exam` branch.
   - Google Drive folder containing the 4 Supabase setup screenshots.
