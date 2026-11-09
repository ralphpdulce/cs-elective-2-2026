# Supabase-Flutter Activity: Price Filter + Pagination
**CS Elective 2 | Mobile App Development**  
*An extension of the Prelim Exam ("Paimon's Bargains") project*

---

## 📌 Project Overview
This project extends the Prelim Exam e-commerce store with **Supabase backend integration**, adding:
1. **Price Range Filtering**: Dynamic `RangeSlider` that filters products via Supabase queries (`.gte()` and `.lte()`).
2. **Backend Pagination**: Limits display to **6-8 products per page** using Supabase range queries (`.range(from, to)` with `CountOption.exact`), managed through frontend state (`ProductProvider`).
3. **Full CRUD Operations**: Building on update, delete, and filter features from the lecture session (Add new product, Update product info, Delete product with confirmation).
4. **Offline & Demo Fallback**: Works seamlessly out-of-the-box with in-memory caching even before entering Supabase credentials.

---

## 🚀 Getting Started

### 1. Database Setup (Supabase)
1. Log in to [Supabase](https://supabase.com) and open or create a project.
2. Go to the **SQL Editor** tab.
3. Copy and run the entire SQL script from [`supabase_schema.sql`](supabase_schema.sql):
   - Creates the `products` table with appropriate columns and RLS policies for anonymous access.
   - Seeds 16 initial items from the store catalog (Weapons, Gadgets, Gemstones, Talent Books) with prices ranging from \$39.99 to \$1,499.99.

### 2. Configure Credentials
Open [`lib/config/supabase_config.dart`](lib/config/supabase_config.dart) and enter your credentials:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

### 3. Run the App
```bash
cd backend-filter-pagination
flutter pub get
flutter run
```

### 4. Run Automated Tests
```bash
flutter test
```

---

## 🛠️ Feature Implementation Details

### 1. Price Filtering
- Located in [`lib/widgets/price_slider_filter.dart`](lib/widgets/price_slider_filter.dart).
- Customers can select a range of prices using the interactive `RangeSlider`.
- The values are debounced (350ms) to ensure smooth sliding without overwhelming backend queries.
- Supabase Query implementation in [`lib/services/supabase_service.dart`](lib/services/supabase_service.dart):
  ```dart
  if (minPrice != null) query = query.gte('price', minPrice);
  if (maxPrice != null) query = query.lte('price', maxPrice);
  ```

### 2. Pagination
- Located in [`lib/widgets/pagination_bar.dart`](lib/widgets/pagination_bar.dart).
- Shows **6 or 8 products per page** (toggleable directly on the UI to test both limits).
- Paginated using zero-indexed Supabase range query:
  ```dart
  final int from = (page - 1) * pageSize;
  final int to = from + pageSize - 1;

  final response = await query
      .order('price', ascending: true)
      .range(from, to)
      .count(CountOption.exact);
  ```
- Handled through [`lib/state/product_provider.dart`](lib/state/product_provider.dart) with reactive total count, total pages, and next/previous state.

### 3. Update & Delete (CRUD)
- **Update**: Edit button on every product card and detail page opens an edit dialog with input validation, calling `.from('products').update(...)`.
- **Delete**: Delete button prompts for confirmation and calls `.from('products').delete().eq('id', id)`.
- **Create**: Floating Action Button on the home screen allows adding new products.

---

## 📂 Project Architecture
```
backend-filter-pagination/
├── assets/images/              # Product image assets
├── lib/
│   ├── config/
│   │   └── supabase_config.dart    # Supabase credentials & check
│   ├── models/
│   │   └── product.dart            # Product model with serialization
│   ├── router/
│   │   └── app_router.dart         # GoRouter configuration
│   ├── screens/
│   │   ├── cart_screen.dart        # Shopping cart view
│   │   ├── checkout_screen.dart    # Route-guarded checkout confirmation
│   │   ├── home_screen.dart        # Catalog with search, filter & pagination
│   │   └── product_detail_screen.dart # Detailed product view
│   ├── services/
│   │   └── supabase_service.dart   # Supabase client queries & fallback logic
│   ├── state/
│   │   ├── cart_state.dart         # Cart & wishlist state management
│   │   └── product_provider.dart   # Filter, pagination & CRUD state
│   ├── widgets/
│   │   ├── admin_product_dialog.dart # Add / Edit product dialog
│   │   ├── pagination_bar.dart     # Responsive pagination controls
│   │   ├── price_slider_filter.dart# Interactive price range slider
│   │   └── product_card.dart       # Product item card with CRUD actions
│   ├── app_theme.dart              # Material 3 light/dark theme
│   └── main.dart                   # Application entry point
├── test/
│   ├── product_features_test.dart  # Unit tests for filter, pagination, CRUD
│   └── widget_test.dart            # Widget smoke test
└── supabase_schema.sql             # SQL script for table creation & seeding
```

---

## 📤 Submission Instructions (per Slide 4)
1. Branch created: `backend-filter-pagination`
2. Push branch to remote:
   ```bash
   git add .
   git commit -m "Implement Supabase backend price filtering and pagination"
   git push origin backend-filter-pagination
   ```
3. Submit the GitHub branch link in the submission bin on Daigler.
