# xStore — Backend Development Roadmap

**For:** the backend developer building the xStore API
**From:** the founder + solution architect
**Repo grounding:** the Flutter app already exists and defines ~50 REST endpoints across 11 modules (see `lib/docs/*_module_api_docs.json` and the companion file **02_BACKEND_API_DOCUMENTATION.md**). Your job is to build the server those contracts point at.
**How to read this:** Sections 1–4 are the "what and why" (context, architecture, rules everyone must follow). Section 5 is the phased plan. Section 6 is the literal step-by-step checklist. Sections 7–10 are the engineering guardrails (data model, environments, security, done-criteria).

---

## 1. Context — what exists and what you're building

The mobile app (iOS + Android, Flutter) is an advanced pre-launch MVP. It currently runs on **mock data** (`MOCK=true` compiled in) and expects a real REST API at a configurable base URL. **There is no backend code yet** — only the app and its documented API expectations.

**The contract already exists.** The app was built against a specific set of endpoints, request shapes, and JSON field names. That means the backend is not a blank canvas — it must match what the app already sends and parses. The API documentation file (File 02) is the source of truth for every route and payload. When in doubt, the app's expectation wins, unless a change is agreed with the mobile developer.

**Business decisions already locked (do not re-litigate):**

- **Market:** Egypt only. Currency **EGP**. Bilingual (Arabic/English) content where relevant.
- **Payments at launch:** **Cash on Delivery (COD) only.** No online payment gateway in the launch scope — that is a later phase the founder owns. Do **not** build card processing now.
- **Products go live only after admin approval** (a moderation gate).
- **One SKU per product at launch** (no size/color variant matrix yet).
- **Login-gated** app at launch (no guest checkout yet).

**Your definition of success:** the app runs with `MOCK=false` against your API, end to end — a buyer can register, browse a real catalog, add to cart, place a COD order, and track it; a vendor can list a product (pending approval), get approved, and fulfill orders; the admin can approve vendors/products and oversee orders.

---

## 2. Recommended architecture & stack

You may adapt the stack, but the **contracts, conventions, and sequencing in this document are not optional** — they're what the app requires.

### Recommended stack (rationale, not mandate)

| Concern | Recommendation | Why |
|---|---|---|
| Language/framework | **Node.js + NestJS** (TypeScript) | Large Egyptian hiring pool; NestJS's modular structure mirrors the app's clean architecture; strong typing reduces contract drift. (Laravel/Django are fine alternatives.) |
| Database | **PostgreSQL** | Marketplace data is relational (users, vendors, listings, orders, order items). Strong integrity, transactions for stock decrement. |
| ORM | Prisma or TypeORM | Migrations + type-safe queries. |
| Auth | **JWT Bearer tokens** | The app already sends `Authorization: Bearer <token>` on every call and logs out on 401 — you must match this. |
| File/image storage | **S3-compatible object storage** (AWS S3, Cloudflare R2, or DigitalOcean Spaces) | Product images need real hosted URLs; local disk won't scale. |
| Caching/queues (optional) | Redis | Sessions, rate limiting, background jobs (notifications). Add when needed. |
| Hosting | Any container host (Render, Railway, DigitalOcean, AWS) | Keep it simple for MVP; containerize early. |

### Non-negotiable contracts (the app already depends on these)

1. **Base URL** is injected at build time via `--dart-define=API_BASE_URL=...`. Your API is mounted at that origin. Provide separate **dev** and **prod** URLs.
2. **Auth header:** every authenticated request carries `Authorization: Bearer <token>`. A **401** response must mean "token invalid/expired" — the app reacts by deleting the token and logging the user out. Don't return 401 for ordinary business errors.
3. **JSON field names must match** what the app parses (see File 02 per module). The app currently tolerates some alternate key names (aliases) — you should pick the **canonical** key set documented in File 02 and stick to it so we can remove that ambiguity.
4. **Money** is EGP. Prefer integer minor units (piastres) or `decimal(12,2)` — never floats in the database. The app displays whole-EGP today; keep server math exact.
5. **Every product carries an owning `vendorId`** (see §7). This does not exist in the app's current model and must be added server-side — it's required for a multi-vendor marketplace.

---

## 3. Cross-cutting foundations (build these first, once)

These apply to every module. Getting them right up front prevents rework.

- **Auth & identity:** JWT issue/verify, password hashing (bcrypt/argon2), role claim (`buyer` | `vendor` | `admin`) and `vendorId` in the token. Refresh-token strategy (the app currently embeds the token in the user payload — align on a refresh approach with the mobile dev).
- **Standard error envelope:** consistent shape for all errors, e.g.
  ```json
  { "error": { "code": "VALIDATION_ERROR", "message": "Human readable", "fields": { "price": "Must be > 0" } } }
  ```
  Use **422** for validation (field-keyed to match the app's inline form errors), **401** only for auth, **403** for permission, **404** not found, **409** for conflicts (e.g. out-of-stock at checkout).
- **Pagination:** cursor-based for the customer catalog feed (stable under inserts); page/limit acceptable elsewhere. Document the shape and keep it consistent.
- **Soft-delete everywhere it matters:** products, vendors, and anything an order can reference are archived (`status`/`deleted_at`), never hard-deleted. Order history must survive product deletion (the app already stores a denormalized product snapshot on each order item — lean on that).
- **Image upload:** a real upload endpoint (multipart or presigned URL) returning hosted URLs. The app currently sends local file paths as strings — this must become real uploads.
- **Audit timestamps:** `created_at` / `updated_at` on all tables; append-only price/stock history on listings for dispute defense.
- **Localization:** where content is bilingual, decide the storage strategy (separate `_ar`/`_en` fields or a translations table) with the mobile dev.

---

## 4. The MOCK → live switch (how the app connects to you)

The app flips from mock to real per build via dart-defines:

```
flutter build apk --release --flavor prod -t lib/main_prod.dart \
  --dart-define=API_BASE_URL=https://api.xstore.eg \
  --dart-define=MOCK=false
```

- While you build, the mobile team flips modules to `MOCK=false` **one at a time** as your endpoints land — so your delivery order (Section 5) directly controls what the app can turn on.
- Release builds **require** a non-empty `API_BASE_URL` (the app asserts this). Provide dev/prod URLs early, even if they point to a staging server.

---

## 5. Phased delivery plan

Each phase lists its goal, the endpoints to ship, what it unblocks in the app, complexity (S/M/L), and the exit criteria that let the mobile team flip `MOCK=false` for that area.

### Phase 0 — Foundations (before any feature)
**Goal:** the skeleton everything else builds on.
**Build:** project scaffold, PostgreSQL + migrations, JWT auth middleware, error envelope, config for dev/prod, object storage wired, health-check endpoint, CI + deploy to a staging URL.
**Unblocks:** gives the mobile team a real `API_BASE_URL` to point at.
**Complexity:** M. **Exit:** staging responds; auth middleware verifies a token; images can be uploaded and served.

### Phase 1 — Auth + Catalog (read)
**Goal:** a real user logs in and browses a real catalog.
**Build:** `POST /auth/register`, `POST /auth/login`, `POST /auth/logout`; `GET /listings` (catalog with filters/search/sort/pagination), `GET /listings/{id}` (detail), `GET /listings/similar`, `GET /listings/{id}/reviews`; `GET /home/banners|hot-deals|categories`; `GET /categories` (server-driven taxonomy replacing the app's hardcoded list); image upload endpoint.
**Unblocks:** auth, home, explore/search, product detail — the entire top of the funnel.
**Complexity:** L. **Exit:** app with `MOCK=false` can register, log in, and browse real products.

### Phase 2 — Vendor listings + Cart + COD checkout
**Goal:** vendors can list; buyers can order (COD).
**Build:** `POST /listings` (full create with `vendorId`, images, stock), `PATCH /listings/{id}`, `DELETE /listings/{id}` (soft), `GET /listings/mine`; the 9 cart endpoints; coupon validation server-side; `POST /orders` (place COD order) with **stock re-validation** at checkout; address book endpoints.
**Unblocks:** vendor listing management, cart, checkout, order creation.
**Complexity:** L. **Exit:** a buyer places a COD order that decrements stock atomically; a vendor sees it.

### Phase 3 — Orders lifecycle + Admin moderation + Notifications
**Goal:** fulfillment works and you can run the marketplace.
**Build:** the 11 order endpoints (consumer/vendor lists, detail, stats, confirm/reject/processing/shipped/delivered/cancel); **admin endpoints** — vendor approval/suspension, product approval/reject (the moderation gate), category management; wishlist endpoints; reviews write; **notifications** (real records + push via FCM to replace the app's mock-only inbox).
**Unblocks:** order tracking (both roles), the admin dashboard, real notifications, wishlist sync.
**Complexity:** L. **Exit:** full order lifecycle end to end; admin can approve a vendor and a product; a status change pushes a notification.

### Phase 4 — Payment gateway (post-launch, founder-owned)
**Goal:** add online payment once live on COD.
**Build:** Paymob/Fawry integration, checkout **re-pricing** at authorization, webhooks, refunds; commission capture on prepaid orders; wallets (Vodafone Cash/InstaPay).
**Complexity:** L. **Note:** not on the launch critical path — do not build now.

> **Dependency rule:** the mobile team can only turn on an app area after the backend endpoints behind it pass their exit criteria. Ship in this order; don't jump ahead to Phase 3 while Phase 1 catalog is still mock.

---

## 6. Step-by-step road to finish the backend (checklist)

Concrete, in order. Tick these off.

1. Stand up the repo: framework, linting, formatting, CI, containerization.
2. Provision PostgreSQL + object storage; wire config for **dev** and **prod**.
3. Implement the **auth foundation**: user table, register/login/logout, password hashing, JWT with `role` + `vendorId`, auth middleware.
4. Implement the **error envelope**, validation (422 field-keyed), and pagination helper.
5. Ship the **image upload** endpoint (multipart or presigned) returning hosted URLs.
6. Deploy to **staging**; hand the mobile team the staging `API_BASE_URL`.
7. Build the **catalog read** side (`/listings`, detail, similar, reviews, home, categories) + seed real data.
8. Mobile flips auth + browse to `MOCK=false`; fix contract mismatches together.
9. Build **listing write** (`POST/PATCH/DELETE /listings`, `/listings/mine`) with `vendorId`, stock, and the **pending→approved** status flow.
10. Build **cart** (9 endpoints) + server-side **coupon** validation.
11. Build **COD checkout** (`POST /orders`) with atomic stock decrement + checkout re-validation (stock/price change → 409/confirm).
12. Build **address book** endpoints.
13. Build the **order lifecycle** (11 endpoints) for consumer + vendor.
14. Build **admin/moderation**: vendor approval/suspension, product approval/reject, category CRUD.
15. Build **wishlist** + **reviews write**.
16. Build **notifications**: real records + FCM push; replace the app's mock inbox.
17. Harden: rate limiting, input validation, authz checks (vendor can only touch own data), logging/monitoring.
18. Full **end-to-end test** with the app on `MOCK=false` across every flow.
19. Cut over dev→prod URLs; go-live checklist (Section 10).
20. (Post-launch) Phase 4 payment gateway.

---

## 7. Core data model (minimum tables)

Grounded in the app's entities (full field lists in File 02). Minimum viable schema:

- **users** — id, name, email, phone, password_hash, role (buyer/vendor/admin), is_verified, avatar_url, created_at, updated_at. Vendor fields (store_name, store_slug, store_category, store_logo_url, city, governorate, whatsapp_number, lat/long, bio, socials).
- **listings (products)** — id, **vendor_id (required, NEW)**, title, description, price (EGP), compare_at_price, currency, status (`draft/pending/active/paused/out_of_stock/rejected/archived`), stock_quantity, category_id, subcategory_id, condition, brand, location, shipping_available, shipping_cost, view_count, save_count, inquiry_count, created_at, updated_at.
- **listing_images** — id, listing_id, url, position.
- **listing_attributes** — id, listing_id, key, value (the free-form specs).
- **categories** — id, name, parent_id (server-driven; replaces the app's hardcoded taxonomy).
- **carts / cart_items** — cart per consumer; items denormalize listing + vendor snapshot, price, quantity, max_quantity, is_available.
- **orders** — id, consumer_id, status (`pending/confirmed/processing/shipped/delivered/cancelled/refunded`), payment_method (`cash_on_delivery` at launch), address snapshot, shipping_info, totals, created_at.
- **order_items** — id, order_id, vendor_id, **denormalized product snapshot** (listing_id, name, image, category, condition, price, quantity, total). This snapshot is what protects order history from product deletion.
- **wishlists / wishlist_items** — per consumer; item snapshot + price-drop tracking.
- **reviews** — id, listing_id, user_id, rating, comment, helpful_count, created_at.
- **notifications** — id, user_id, type (21 types — see File 02), priority, title, body, action_route, is_read, order_id, listing_id, created_at.
- **store_hours** — vendor_id, is_open, temporary_message, weekly schedule, updated_at.
- **price_history / stock_history** (recommended) — append-only, for disputes.

---

## 8. Environments & configuration

- **Two environments:** `dev` (staging) and `prod`. Each has its own DB, storage bucket, and base URL.
- The app already ships **dev/prod flavors** (Android) and expects an `API_BASE_URL` per flavor. Provide both URLs.
- Keep secrets out of code (env vars / secret manager). Never commit DB or storage credentials.
- Provide a seed script so the mobile team and QA always have realistic data on dev.

---

## 9. Security, quality & testing

- **Authorization, not just authentication:** every vendor endpoint must be scoped to the token's `vendorId` — a vendor must never read or modify another vendor's listings or orders by guessing an ID. Admin-only routes must check the admin role.
- **Validate all input** server-side; never trust the client. Enforce image type/size/count.
- **Atomic stock decrement** at order placement to prevent overselling (transaction + row lock or conditional update).
- **Rate limiting** on auth and write endpoints.
- **Tests:** unit tests for business rules (pricing, stock, coupon math, order transitions) and integration tests for each endpoint against the documented contract. Add a Postman/OpenAPI collection the mobile dev can test against.
- **Idempotency** for order placement (avoid duplicate orders on retry).

---

## 10. Definition of done & go-live checklist

**An endpoint is "done" when:** it matches the documented request/response (File 02), enforces authz, validates input, returns the standard error envelope, has tests, and the mobile team has verified it with `MOCK=false`.

**Go-live checklist:**

- [ ] All Phase 1–3 endpoints live and contract-verified with the app.
- [ ] `vendorId` on every product; admin approval gate working.
- [ ] COD order places, decrements stock atomically, appears for the vendor.
- [ ] Soft-delete verified: deleting a product doesn't break existing orders.
- [ ] Real image upload working end to end.
- [ ] Prod DB, storage, and `API_BASE_URL` configured; secrets secured.
- [ ] Seed/admin account created; categories seeded.
- [ ] Rate limiting, logging, monitoring, and backups in place.
- [ ] Notifications (FCM) delivering on order status changes.
- [ ] Load-sanity + security pass done.

> **Open items to confirm with the founder/mobile dev before/while building:** refresh-token strategy; canonical JSON keys (drop the app's alias tolerance); bilingual content storage; how COD commission will be captured later (Phase 4); courier integration for delivery/tracking.

---

*Companion document: **02_BACKEND_API_DOCUMENTATION.md** — every module's endpoints, request/response shapes, and known gaps to fix.*
