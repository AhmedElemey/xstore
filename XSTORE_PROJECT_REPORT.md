# xStore — Project Report for Business Stakeholders

**Report date:** July 2, 2026  
**App version:** 1.0.0+1  
**Repository:** Flutter mobile marketplace (consumer + vendor)  
**Prepared for:** Non-technical business owner

---

## 1. Product Overview

### What xStore Is

xStore is a **cross-platform mobile marketplace** built with Flutter. It supports two user types:

| Role | What they do |
|------|----------------|
| **Consumer (buyer)** | Browse products, search, save to wishlist, add to cart, checkout, and track orders |
| **Vendor (seller)** | Create and manage product listings, set store hours, and fulfill incoming orders |

The app is branded as **“Egypt’s modern marketplace”** in onboarding copy and targets shoppers and sellers in Egypt. However, some older mock content still references Algeria (e.g. city “Oran,” “DZD” in a few strings) — see Section 3.

### Core User Flows

**Consumer journey**

1. **Onboarding & sign-in** — Splash → onboarding slides → login/register (email/password, phone OTP, or Google/Apple/Facebook).
2. **Browse** — Home feed (banners, hot deals, categories, new arrivals) → product detail → optional wishlist.
3. **Discover** — Explore tab with search, filters (category, price range, condition, location), grid/list views.
4. **Cart** — Add items, select quantities, apply coupons, review totals grouped by vendor.
5. **Checkout** — 3-step flow: (1) delivery address, (2) payment method, (3) order review → place order.
6. **Order tracking** — Orders tab with status timeline (pending → confirmed → shipped → delivered), order detail, cancel/reorder actions.

**Vendor journey**

1. Register or sign in as vendor (role chosen at registration or after social login).
2. **Add listing** — Create products with photos, category, price, shipping options.
3. **My listings** — View, edit, delete own listings.
4. **Incoming orders** — Confirm, reject, mark shipped/delivered; view buyer contact and address.
5. **Store hours** — Set weekly schedule, open/closed status, temporary closure message.

**Navigation**

- Consumers use bottom tabs: Home, Explore, Wishlist, Orders, Profile.
- Vendors use: Home, Explore, Add Listing, Incoming Orders, Profile.
- Cart is accessed from the home header icon (not a bottom tab).

### Target Platforms & Current State

| Platform | Support |
|----------|---------|
| iOS | Yes (Xcode / App Store build scripts in README) |
| Android | Yes (APK / App Bundle build scripts) |
| Web / Desktop | Project folders exist (linux, macos, windows) but the product focus is mobile |

**Current app state: Advanced MVP / pre-launch development**

- The **UI and user flows are largely built** across 11 feature modules.
- **Default build runs on mock (fake) data**, not a live backend — `MOCK` defaults to `true` at compile time.
- A real HTTP API is expected at `API_BASE_URL` (e.g. `https://api.example.com`), with ~50 REST endpoints documented in `lib/docs/`.
- **Not live in app stores** based on repository state: legal pages are explicitly “not published yet,” several features show “coming soon,” and payment processing is UI-only.
- Code quality gate passes: `flutter analyze` reports no issues; 9 automated test files cover validators, cart math, auth redirects, and store hours — not full end-to-end flows.

---

## 2. Feature Inventory

| Module | Location | Description | Status |
|--------|----------|-------------|--------|
| **Authentication** | `lib/features/auth/` | Email/password login & register, forgot password, Egyptian phone OTP, Google/Apple/Facebook sign-in, role selection (buyer vs vendor), session persistence | **Partial** — Full UI + mock flows; real API hooks exist for login/register; social auth needs Firebase/Meta/Google console setup per README |
| **Onboarding & Splash** | `lib/features/auth/presentation/screens/` | First-run slides, splash branding | **Complete** (UI) |
| **Home** | `lib/features/home/` | Hero banners, flash sales, categories, hot deals, new arrivals, recommendations | **Partial** — Rich UI; data from API or mock depending on build flag |
| **Explore / Search** | `lib/features/explore/` | Search with suggestions, filters, sort, grid/list toggle, recent searches | **Partial** — Functional with mock/API; “more filters — coming soon” |
| **Product catalog & detail** | `lib/features/product/` | Image gallery, specs, seller card, reviews summary, similar products, add-to-cart, share | **Partial** — Detail screen complete; full reviews list screen is a **stub** |
| **Wishlist** | `lib/features/wishlist/` | Save items, price-drop badges, sort, bulk move to cart, swipe actions | **Partial** — Consumer-only; mock + API paths |
| **Cart** | `lib/features/cart/` | Multi-vendor grouping, select-all, coupons, quantity controls, recommended strip | **Partial** — Vendor accounts blocked from cart; mock in-memory cart when `MOCK=true` |
| **Checkout** | `lib/features/cart/presentation/screens/checkout_screen.dart` | 3-step address → payment → review | **Partial** — UI complete; **no real payment gateway**; addresses are hardcoded sample + checkout-only add |
| **Orders (consumer)** | `lib/features/orders/` | Order list, filters, detail, timeline, cancel, reorder | **Partial** — Full lifecycle UI; vendor/consumer actions wired to mock or API |
| **Orders (vendor)** | `lib/features/orders/` | Incoming orders, confirm/reject/ship/deliver, stats banner | **Partial** — Same as consumer orders |
| **Listings (vendor)** | `lib/features/listing/` | Create listing form (images, category, price, shipping), my listings grid/list | **Partial** — Form validation solid; image upload to real API not fully implemented |
| **Profile** | `lib/features/profile/` | View/edit profile, avatar, vendor store page, stats, menu links | **Partial** — Avatar upload returns placeholder URL on real API path |
| **Store hours** | `lib/features/store/` | Weekly schedule editor, open/closed banner, copy-hours templates | **Partial** — Validation tested; mock + API |
| **Notifications (inbox)** | `lib/features/notifications/` | Activity feed, filters, swipe mark-read/delete, grouped by date | **Stubbed** — **Mock data only**; no REST endpoints (0 in API docs) |
| **Notification settings** | `lib/features/notifications/presentation/screens/notification_settings_screen.dart` | Push/email/SMS toggles per event type | **Partial** — Toggles saved locally on device only; **no push SDK** (no Firebase Cloud Messaging) |
| **Reviews** | Product detail + `product_reviews_screen.dart` | Summary on product page; full list screen | **Partial / stub** — Summary from API/mock; dedicated reviews screen is placeholder text |
| **Chat / messaging** | Route `/chat/:threadId` | Buyer–seller messaging | **Stubbed** — “Chat with seller — coming soon” |
| **Analytics (vendor)** | Route `/analytics` | Sales insights | **Stubbed** — Coming soon screen |
| **Earnings (vendor)** | Route `/earnings` | Revenue dashboard | **Stubbed** — Coming soon screen |
| **Settings** | Route `/settings` | App settings hub | **Stubbed** — Coming soon screen |
| **Recently viewed** | Route `/recently-viewed` | Browsing history | **Stubbed** |
| **My reviews** | Route `/my-reviews` | User’s written reviews | **Stubbed** |
| **Change password** | Route `/change-password` | Password update | **Stubbed** |
| **Payment methods (profile)** | `PaymentMethodsInfoScreen` | Saved cards management | **Stubbed** — Redirects user to checkout instead |
| **Addresses (profile)** | `AddressesInfoScreen` | Saved address book | **Stubbed** — “Address book coming soon”; checkout allows one-off add |
| **Help center** | `HelpCenterInfoScreen` | Support entry point | **Partial** — Links to orders and notification settings only |
| **Terms & Privacy** | `TermsInfoScreen`, `PrivacyInfoScreen` | Legal compliance | **Stubbed** — Explicit message: legal text **not published yet** |
| **Localization** | `lib/l10n/` (English + Arabic) | Bilingual UI, RTL support, Cairo font for Arabic | **Complete** (UI strings) |
| **Offline awareness** | `lib/shared/widgets/offline_banner.dart` | Banner when device has no connectivity | **Partial** — Blocks cart/checkout/wishlist mutations offline; no offline catalog browsing cache |
| **Dark mode** | `lib/core/theme/app_theme.dart` | Light/dark themes | **Complete** (theme support) |

---

## 3. Business-Relevant Details

### Currency & Pricing

| Aspect | How it works | Business impact |
|--------|--------------|-----------------|
| **Display currency** | Prices shown as **EGP** (Egyptian Pounds), whole numbers, via `formatCurrency()` in `lib/core/utils/extensions/context_extensions.dart` | Single currency display — no multi-currency shopper experience |
| **Listing currency code** | Hardcoded `EGP` in listing form (`listing_form_notifier.dart`) | All new listings assumed EGP |
| **Legacy / inconsistent strings** | Some mock banners and coupon copy still say **“DZD”** (Algerian dinar); `Formatters.dzdWhole()` exists in `formatters.dart` but primary UI uses EGP | **Risk:** confusing pricing if not cleaned before launch |
| **Price storage** | `double` values from API JSON — no minor-unit (cents) abstraction in entities | Fine for EGP whole-pound display; fragile if you add fils/cents later |
| **Coupons** | Percentage or fixed discount; minimum order (e.g. 5,000 in copy); max discount cap | Business rules exist in cart logic (`cart_totals_test.dart` validates math) |
| **Shipping** | Per-item shipping cost; grouped in cart by vendor | Multi-vendor cart supported at UI level |

**No currency conversion** — single-market assumption (Egypt).

### Payment Methods

Checkout offers four methods (`PaymentMethod` enum in `order_entity.dart`):

| Method | User-facing name | Integration status |
|--------|------------------|-------------------|
| Cash on delivery | COD | **UI only** — selection stored on order; no courier/COD reconciliation |
| CIB Card | Algerian bank card brand in naming | **UI only** — card number/expiry/CVV collected in form; **not sent to a payment processor**; shows “secure payment” lock icon |
| Edahabia (Dahabi) | Egypt Post golden card | **UI only** — radio selection only |
| BaridiMob | Egypt Post mobile payment | **UI only** — radio selection only |

**There is no Stripe, PayPal, Paymob, Fawry, or other payment SDK in the project.** Placing an order POSTs `paymentMethod` as a string to `/orders` (or mock). Card fields are included in params for CIB but are not processed.

### Checkout Flow & Trust Elements

**Steps**

1. **Address** — Pick from a pre-seeded sample address (Oran, Algeria in mock data) or add new (Egypt governorates dropdown from `egypt_wilayas.dart`).
2. **Payment** — Choose method; card form for CIB only.
3. **Review** — Order summary, delivery note, place order.

**Trust / credibility elements present**

- Lock icon + “secure payment” copy on card entry
- Order confirmation bottom sheet after success
- Vendor verified badges and ratings on product/cart cards
- Honest placeholders for Terms, Privacy, Help (no fake legal text)

**Missing trust elements**

- No published Terms of Service or Privacy Policy in-app
- No guest checkout — **login required** for all shopping (`router_notifier.dart` redirects unauthenticated users to login)
- No SSL/security badges beyond card-section copy
- No return/refund policy screen
- Saved payment methods and address book not available outside checkout

### Hardcoded Limitations Affecting Business Decisions

| Limitation | Detail |
|------------|--------|
| **Single market** | Egypt phone validation, Egyptian governorates, EGP pricing — not multi-country |
| **Mock-first development** | `MOCK=true` by default — release builds need explicit `API_BASE_URL` and `MOCK=false` |
| **No real payments** | Cannot collect money in production without new integration |
| **Notifications are local mock** | No server-push order updates; inbox is fake data |
| **No messaging** | Buyers cannot contact sellers in-app |
| **No courier integration** | “Courier tracking — coming soon” on order detail |
| **Avatar upload** | Real API path returns placeholder image URL, not actual upload |
| **Auth required** | No browse-as-guest or guest checkout — may reduce conversion |
| **Vendor/buyer role split** | Vendors cannot use cart or wishlist (by design) |
| **API coupling** | Many modules use inline path strings, not a single API catalog — speeds initial dev, slows backend contract changes |

---

## 4. Known Issues & Technical Debt

### Code Comments & Explicit Gaps

No `TODO` / `FIXME` / `HACK` comments were found in Dart source. Gaps are documented through **user-facing “coming soon” strings** and architectural stubs instead:

| Area | Finding |
|------|---------|
| Product reviews screen | “Placeholder until wired to backend” |
| Cart/order models | “API DTO placeholder” comments |
| Profile avatar upload | “Real upload would use multipart; placeholder URL for scaffold” |
| Listing datasource | “Local scaffold cache when API is unavailable” |
| Terms / Privacy screens | Explicitly state content is not published |

### Regional & Branding Inconsistency (High Priority)

The app mixes **Egypt** and **Algeria** artifacts:

- UI currency: **EGP**; onboarding: “Made with ❤️ in Egypt”
- Payment brands: mix of **CIB (Algeria)** and **Edahabia/BaridiMob (Algeria/Egypt Post)**
- Mock addresses: **Oran, Algeria**; mock vendors: “Oran Fashion Hub”
- Governorate picker: **27 Egypt governorates** (`egypt_wilayas.dart`) but field labeled “Wilaya” (Algerian term)

**Impact:** Confusing for users and regulators; must be resolved before public launch.

### Mock vs Live Data

- **12 datasource files** branch on `MockConfig.useMock` (auth, cart, orders, home, explore, listing, product, profile, store, wishlist).
- README states mock is disabled in release mode, but `mock_config.dart` currently uses the compile flag directly **without** a release-mode guard — documentation and code may disagree.
- Recent commit `a28f4f5` (“make mock on”) reinforces mock as the active default.

### Duplicated / Temporary Logic

- Checkout ships with **hardcoded sample address** in `checkout_provider.dart` rather than loading from profile/API.
- In-memory static cart (`_items` list in `cart_remote_datasource.dart`) when mocking — not persisted across app restarts.
- Notifications entirely in-memory with mock seed data — no sync with server.

### Error Handling & Offline Gaps

| Behavior | Coverage |
|----------|----------|
| 401 unauthorized | Clears token, redirects to login (`dio_provider.dart`) |
| Offline banner | App-wide visual indicator |
| Offline mutations | Cart add/update, checkout place order, wishlist changes blocked |
| Offline browsing | **Not supported** — no cached catalog |
| Connectivity check | Device network type only — **does not ping API** (may show “online” when API is down) |

### Incomplete Flows

- Express checkout — “coming soon”
- Message seller from order — “coming soon”
- Courier website link — “coming soon”
- Vendor “view on map” button — present but `onPressed: () {}` empty handler
- Product reviews full page — stub only

---

## 5. Architecture Summary (Brief)

### Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter (Dart SDK ^3.9.2) |
| State management | Riverpod 2.x with code generation |
| Navigation | go_router with role-based shells (consumer vs vendor) |
| HTTP | Dio with Bearer token interceptor |
| Local storage | flutter_secure_storage (auth), shared_preferences (settings, recent searches) |
| Auth providers | Firebase Auth + google_sign_in, sign_in_with_apple, flutter_facebook_auth |
| UI | Material 3, custom theme, shimmer skeletons, flutter_animate |
| i18n | flutter gen-l10n — English + Arabic |
| Functional errors | fpdart `Either<Failure, T>` in repository layer |

### Structure

**Feature-first clean architecture:** each module under `lib/features/<name>/` has `data/`, `domain/`, `presentation/` layers. Shared widgets live in `lib/shared/`.

### Backend Dependency

The app is a **client to a REST API** configured at build time:

```
--dart-define=API_BASE_URL=https://your-api-host
--dart-define=MOCK=false
```

Documented endpoints span auth, home, listings, cart (9), orders (11), profile (6), wishlist (6), store hours (3), explore (2). **Notifications have zero REST endpoints** in the docs.

There is **no backend code in this repository** — only the mobile app and API documentation JSON files (recently added under `lib/docs/`, staged but not yet committed).

### What Affects Speed of Adding Features

**Strengths**

- Consistent module pattern — new features can follow existing data/domain/presentation split
- Riverpod dependency injection per feature
- Localization infrastructure ready for new strings
- API docs index gives a map of intended contracts

**Friction**

- Mock and real code paths duplicated in every datasource — every new API needs two implementations
- Not all paths use centralized `ApiEndpoints` — some inline strings
- No code generation from OpenAPI — manual model maintenance
- Payment, push, and chat need net-new integrations, not extension of existing patterns
- Tight coupling of checkout addresses to checkout provider, not a shared address service

---

## 6. Recent Activity

Last 27 commits (newest first), summarized by theme:

| Period | Focus |
|--------|-------|
| **Jun 2026** | Auth login fixes, post-auth routing fixes, UI fine-tuning |
| **May 2026** | Mock mode enabled by default, app icon work, animation fixes |
| **Apr 2026** | **Localization** (EN/AR), phone auth flow polish, OTP auth, profile enhancements |
| **Mar 2026** | Major feature push: notifications, wishlist, profile, auth flow, mock data layer, product detail, vendor my listings, create listing screen; initial commit |

**Actively in progress (uncommitted)**

- Staged addition of **module API documentation** (`lib/docs/*_module_api_docs.json`) — 11 JSON files documenting ~50 REST endpoints for backend alignment. This suggests preparation for **live API integration** or handoff to a backend team.

**Branches**

- `main` (current, synced with `origin/main`)
- `feat/localization-en-ar` (likely merged or superseded by main’s localization work)

---

## 7. Gaps & Recommendations

### Launch Readiness — What’s Missing

From a **product and business risk** perspective, the app is **not launch-ready** today. The shopping experience is demonstrable, but revenue, legal, and operational foundations are incomplete.

| Gap | Risk if ignored |
|-----|-----------------|
| No payment processor | Cannot legally/process payments; card data collected without PCI-compliant handling is a **liability** |
| No published Terms / Privacy | App store rejection; GDPR/local law exposure |
| Mock-default builds | Production accidentally shipping fake data |
| Market branding inconsistency (EGP vs DZD, Oran vs Egypt) | User confusion, wrong market positioning |
| No push notifications | Poor order update experience; higher support load |
| No buyer–seller messaging | Disputes handled outside app; trust issues |
| Login required to browse | Lower acquisition vs competitors with guest browse |
| Notifications module mock-only | Activity feed misleading in demo vs production |
| Minimal automated testing (9 files) | Regression risk as API integration proceeds |
| No backend in repo | Separate API project must exist, stay in sync with `lib/docs/` |

### Prioritized Recommendations

**P0 — Before any public beta**

1. **Decide target market** (Egypt recommended based on current branding) and **remove all Algeria/DZD/Oran leftovers** from UI, mock data, and payment method list.
2. **Integrate a real payment solution** (e.g. Paymob, Fawry, or COD-only for MVP) — remove in-app raw card capture unless PCI-certified.
3. **Publish Terms of Service and Privacy Policy** — replace stub screens with real legal content and URLs.
4. **Stand up and connect production API** — ship with `MOCK=false` and validated `API_BASE_URL`; run end-to-end checkout on staging.
5. **Remove or secure card CVV collection** until a certified gateway handles it.

**P1 — Beta / soft launch**

6. **Firebase Cloud Messaging** (or equivalent) for order status push notifications; wire notification inbox to API.
7. **Saved address book** synced to profile — reduce checkout friction.
8. **Guest browse** (optional) and clearer auth prompts at cart/checkout only.
9. **Buyer–seller messaging** or deep-link to WhatsApp (vendor profiles already have `whatsappNumber` field).
10. **Complete product reviews** — wire `product_reviews_screen.dart` to API.

**P2 — Scale & vendor growth**

11. Vendor **analytics** and **earnings** dashboards (currently stubbed).
12. **Courier tracking** integration or external link.
13. Expand **automated tests** to checkout, orders, and API integration paths.
14. Centralize API paths and consider OpenAPI client generation to reduce mock/real drift.
15. **Offline catalog cache** if mobile connectivity is unreliable in target regions.

---

## Appendix: Module Map (Quick Reference)

```
lib/features/
├── auth/           Login, register, OTP, social, roles
├── home/           Feed, deals, categories
├── explore/        Search & filters
├── product/        Product detail, reviews summary
├── wishlist/       Saved items (consumers)
├── cart/           Cart + checkout
├── orders/         Consumer & vendor order management
├── listing/        Vendor create/manage listings
├── profile/        User & vendor store profiles
├── store/          Store hours
└── notifications/  Inbox + settings (mock/local)
```

**Documented API index:** `lib/docs/modules_api_docs_index.json`  
**Run configuration:** See `README.md` for `API_BASE_URL` and `MOCK` flags.

---

*This report reflects the codebase as of July 2, 2026. It is intended for planning and stakeholder alignment, not as a legal or financial audit.*
