# Supabase-Flutter Activity: Third-Party Backend Authentication (OAuth) & Character Catalog Overhaul
**CS Elective 2 | Mobile App Development**  
*Extension of the Prelim Exam & Filter/Pagination Project ("Paimon's Bargains")*

---

## 📌 Project Overview
This project adds **Third-Party Backend Authentication via Supabase** and a **Dynamic Character Catalog Overhaul** to our Flutter store application on the branch `backend-auth`:
- **Supported Auth Providers**: **GitHub** and **Google** OAuth.
- **Authentication State Management**: Reactive `AppAuthProvider` tracking user session, profile details, and auth status.
- **User Profile & Drawer**: Interactive user avatar, display name, email, and provider badge in AppBar, Drawer, and Profile dialog.
- **Route Guard**: Protected checkout requiring authentication with automatic redirect to `/login` and return to `/checkout`.
- **Demo / Fallback Mode**: Built-in simulated GitHub and Google demo logins for grading and offline testing without live OAuth redirect dependencies.
- **Character Catalog Overhaul (Genshin Impact API)**: Dynamic character data fetched from Devesh Anand's Genshin Impact API, mapped to store products with rarity-based pricing, and synchronized with the Supabase PostgreSQL backend.
- **API Courtesy & Credits**: Prominent in-app attribution to the API creator, endpoints, and asset hosts in the Navigation Drawer, App Bar dialog, and status banner.

---

## 🌟 Genshin Impact API Integration & Pricing Model

### 1. Data Source & Courtesy Attribution
- **API Creator**: Devesh Anand
- **Repository**: [`https://github.com/devesh-anand/genshin-api`](https://github.com/devesh-anand/genshin-api)
- **Live REST Endpoint**: `https://genshin-impact.up.railway.app/characters?details=true`
- **Asset Hosting**: High-resolution character card illustrations served via Cloudflare R2 bucket (`https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/`)
- **Intellectual Property**: Genshin Impact and all character names, assets, and lore are copyright © HoYoverse / COGNOSPHERE PTE. LTD. This project is built strictly for educational purposes.

### 2. Calculated Store Pricing Strategy
Since characters do not have native monetary prices in the game/API, realistic store prices and badges are derived deterministically from character rarity and key:
- **5★ Characters (e.g., Zhongli, Raiden, Furina, Nahida)**:
  - Price Range: **\$899.99 – \$1,499.99**
  - Rating: **4.8 – 5.0**
  - Badges: `5★ ARCHON` (for Archons) or `5★ LEGENDARY`
- **4★ Characters (e.g., Bennett, Xingqiu, Xiangling, Fischl)**:
  - Price Range: **\$249.99 – \$564.99**
  - Rating: **4.3 – 4.7**
  - Badges: `4★ FEATURED`
- **Elemental Vision Categories**:
  - Filter chips map directly to Teyvat's 7 elements: `All`, `Pyro`, `Hydro`, `Anemo`, `Electro`, `Dendro`, `Cryo`, `Geo`.

### 3. Supabase Synchronization Pipeline
1. On app initialization or when tapping **"Sync API Characters"** in the Drawer:
2. `GenshinApiService` fetches all 138 characters from `https://genshin-impact.up.railway.app/characters?details=true`.
3. Characters are converted into `Product` models with calculated prices, badges, and card URLs.
4. If Supabase is connected, characters are batch-upserted (`.upsert()`) directly into the Supabase `products` table.
5. All course requirements (Supabase price range queries `.gte()` / `.lte()`, pagination `.range()`, and CRUD) run against real Supabase tables containing these characters!
6. If offline, the app seamlessly runs using an authentic in-memory fallback roster of 20 iconic characters across all 7 elements.

---

## 🚀 Supabase Third-Party OAuth Setup

### 1. Configure GitHub OAuth (Recommended & Easiest)
1. Go to your **GitHub Settings** $\rightarrow$ **Developer settings** $\rightarrow$ **OAuth Apps** $\rightarrow$ **New OAuth App**:
   - **Application name**: `Paimon's Bargains` (or your preferred name)
   - **Homepage URL**: `https://<your-project-ref>.supabase.co`
   - **Authorization callback URL**: `https://<your-project-ref>.supabase.co/auth/v1/callback`
2. Click **Register application**.
3. Generate a new **Client secret**.
4. In your **Supabase Dashboard**:
   - Navigate to **Authentication** $\rightarrow$ **Providers** $\rightarrow$ **GitHub**.
   - Toggle **Enable GitHub provider**.
   - Paste your **Client ID** and **Client Secret**.
   - Click **Save**.

---

### 2. Configure Google OAuth (Optional)
1. Go to the **[Google Cloud Console](https://console.cloud.google.com)**.
2. Navigate to **APIs & Services** $\rightarrow$ **Credentials** $\rightarrow$ **Create Credentials** $\rightarrow$ **OAuth client ID**.
3. Choose **Web application**.
4. Under **Authorized redirect URIs**, add:
   - `https://<your-project-ref>.supabase.co/auth/v1/callback`
5. In your **Supabase Dashboard**:
   - Navigate to **Authentication** $\rightarrow$ **Providers** $\rightarrow$ **Google**.
   - Toggle **Enable Google provider**, paste your **Client ID** and **Client Secret**, and click **Save**.

---

### 3. Configure Supabase Redirect URLs
In your **Supabase Dashboard** $\rightarrow$ **Authentication** $\rightarrow$ **URL Configuration**:
- Under **Redirect URLs**, add:
  - `io.supabase.flutterquickstart://login-callback/`
  - `com.example.backendauth://login-callback/`
  - `http://localhost:3000/**` *(if running on Flutter Web)*

---

## 🛠️ How Authentication Works in Code

### 1. Initiating Third-Party OAuth ([`lib/state/auth_provider.dart`](lib/state/auth_provider.dart))
```dart
// Sign in with GitHub via Supabase
await authProvider.signInWithGitHub();

// Sign in with Google via Supabase
await authProvider.signInWithGoogle();
```
Supabase launches the browser authentication flow and returns to the app via deep link callback.

### 2. Reactive Auth Listener
```dart
_client.auth.onAuthStateChange.listen((data) {
  // Automatically detects sign in, sign out, or token refresh
  notifyListeners();
});
```

### 3. Route Guard & Checkout Flow ([`lib/router/app_router.dart`](lib/router/app_router.dart))
```dart
GoRoute(
  path: '/checkout',
  builder: (context, state) => const CheckoutConfirmationScreen(),
  redirect: (context, state) {
    if (cartState.items.isEmpty) return '/cart';
    if (!authProvider.isAuthenticated) {
      return '/login?redirect=/checkout';
    }
    return null;
  },
),
```

---

## 🧪 Testing

Run all unit and widget tests:
```bash
cd backend-auth
flutter test
```
*All 13 tests validate authentication state changes, demo sign-ins, price range filters, pagination, API character mapping, and UI rendering.*

---

## 🏃 Running the Application
```bash
cd backend-auth
flutter pub get
flutter run
```

---

## 📤 Submission Instructions
1. We are on the required branch:
   ```bash
   git branch  # displays * backend-auth
   ```
2. Push branch to GitHub:
   ```bash
   git push -u origin backend-auth
   ```
3. Submit your GitHub branch link in the Daigler submission bin:
   `https://github.com/ralphpdulce/cs-elective-2-2026/tree/backend-auth`
