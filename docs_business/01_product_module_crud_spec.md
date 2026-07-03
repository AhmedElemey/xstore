# xStore — Product Module CRUD Specification

**Audience:** Backend developer (contract), Mobile developer (integration)
**Status:** Grounded in the current codebase as of 2 Jul 2026. Business decisions still open are flagged **⚠️ DECISION NEEDED**.
**Owner note:** This spec describes what the app *already expects* from mock data, plus the gaps I want closed before we call this a real e-commerce catalog. Read the "Reality check" boxes — some of what looks like a product model is actually a classifieds/listing model, and that has revenue consequences.

---

## 0. Reality check (read this first)

The thing we call a "product" in xStore is implemented as a **`ListingEntity`** (`lib/features/listing/domain/entities/listing_entity.dart`). The richer customer-facing view is a **`ProductDetailEntity`** that *wraps* a `ListingEntity` and bolts on price-compare, stock, seller, specs, and reviews (`lib/features/product/domain/entities/product_detail_entity.dart`).

Three things fall out of that which the backend dev must know up front:

1. **There is no `vendorId` / `ownerId` on the listing model itself.** Ownership is currently implied only by the auth token on `GET /listings/mine`. For a multi-vendor marketplace this is a real gap — every product must carry its owning vendor so we can filter, moderate, pay out, and cascade deactivation. **We are adding `vendorId` as a required field.**
2. **There is no real variant/SKU model.** The form has free-form key/value `attributes` (e.g. "RAM: 8GB") and a single `price` + single `quantity`. There is no size/color → SKU → per-variant stock/price structure. **⚠️ DECISION NEEDED** on whether v1 needs true variants (see §1.3).
3. **Stock is cosmetic today.** `stockQuantity` defaults to `99` in `ProductDetailEntity` and isn't tied to inventory. The create form collects a `quantity` (default 1). We need one real, authoritative stock number per product (or per variant) that decrements on order.

---

## 1. Data Model

### 1.1 Canonical Product schema (target for backend)

This merges today's `ListingEntity` + `ProductDetailEntity` + the create-form fields into one authoritative model. **New/changed vs. current code is marked.**

| Field | Type | Req? | Notes |
|---|---|---|---|
| `id` | string (UUID) | yes | Server-generated. |
| `vendorId` | string | yes | **NEW.** Owning vendor. Not in current entity — must be added. |
| `title` | string | yes | Form field is `name`; API field is `title`. Align on `title`. |
| `description` | string | yes | |
| `price` | decimal | yes | **EGP**, minor units recommended (store piastres/int, or decimal(10,2)). |
| `compareAtPrice` | decimal | no | "Was" price for discount display. In `ProductDetailEntity` + form. |
| `currency` | string | yes | **NEW, hardcode `"EGP"`.** Do not infer from a `Dzd` key (see cleanup notes). |
| `status` | enum | yes | See §1.2. Current enum: `draft, pending, active, paused, sold, rejected`. |
| `stockQuantity` | int | yes | **Promote to authoritative.** Remove the `99` default. 0 ⇒ out of stock. |
| `categoryId` | string | yes | Form uses `categoryId`; API/mock also carry a `categoryLabel` string. Keep both: `categoryId` (canonical) + denormalized label for display. |
| `subcategoryId` | string | no | |
| `condition` | string/enum | no | `conditionLabel` today (free string). Recommend enum: `new, like_new, good, fair`. |
| `brand` | string | no | In form, not yet in entity/API. |
| `images` | array<Image> | yes (≥1) | Currently `List<String>` of **local file paths** — see §2.3. Needs real hosted URLs + ordering. Max 5 enforced in form. |
| `attributes` | array<{key,value}> | no | Free-form specs (`AttributeEntry`). Surfaced to customer as `specifications` map. |
| `location` | string | no | `locationLine` on detail; `location` in form. Egypt city. |
| `shippingAvailable` | bool | no | Default true. |
| `shippingCost` | decimal | no | EGP; null when `shippingAvailable=false`. |
| `viewCount` | int | no | Server-owned analytics counter, default 0. |
| `saveCount` | int | no | Wishlist count, default 0. |
| `inquiryCount` | int | no | Chat/inquiry count, default 0. |
| `createdAt` / `postedAt` | datetime | yes | `postedAt`/`createdAt` aliased today — pick `createdAt`. |
| `updatedAt` | datetime | yes | **NEW.** Needed for audit + optimistic concurrency. |

**Customer-facing sub-objects on the detail response** (already expected by the app):

- `seller` → `ProductSellerEntity`: `{ id, name, avatarUrl, rating(4.9 default), salesCount(230 default), verified(false default) }`. **Defaults are fake — backend must send real values.**
- `reviewSummary`, `reviews[]`, `similarProducts[]` — populated server-side.

### 1.2 Status lifecycle

Current enum (`ListingStatus`): `draft → pending → active → paused → sold → rejected`.

The prompt asked about `draft/active/out-of-stock/archived`; the code doesn't have `out-of-stock` or `archived`. I recommend we **reconcile to this set** and hand it to the backend as the contract:

| Status | Meaning | Set by | Customer sees it? |
|---|---|---|---|
| `draft` | Vendor started, not submitted | Vendor | No |
| `pending` | Submitted, awaiting admin approval | Vendor→system | No |
| `active` | Approved & purchasable | Admin | Yes |
| `paused` | Vendor temporarily hid it | Vendor | No |
| `out_of_stock` | `stockQuantity == 0` | System (derived) | Yes (greyed/"notify me") |
| `rejected` | Admin rejected | Admin | No |
| `archived` | Soft-deleted / retired | Vendor/Admin | No |
| `sold` | (marketplace one-off sold) | Vendor | Optional |

**⚠️ DECISION NEEDED:** Do we require **admin approval before a product goes live** (`pending` gate), or do vendors self-publish straight to `active`? Approval = more trust/less fraud but slower vendor onboarding and more work for you/your team. My recommendation: **approval ON for launch** (small vendor base, trust matters most early), relax later.

### 1.3 Variants / options

**⚠️ DECISION NEEDED.** Today: no variant model — one price, one stock, free-form attributes only.

- **Option A (recommended for launch):** ship *without* true variants. One SKU per product. Faster, matches current code. Vendors who sell "iPhone, 128GB, Black" just create separate products. Downside: clunky for fashion (sizes/colors).
- **Option B:** build a proper `variants[]` model (`{ sku, options:{size,color}, price, stock, image }`) now. Correct long-term, but it touches create form, cart, stock decrement, and orders — weeks of extra work on both tracks.

My call as owner: **A for launch, B as a fast-follow** once we see which categories actually sell. Don't let variant modeling delay go-live.

---

## 2. CREATE — vendor lists a product

**Current flow:** `add_listing_screen.dart` → `ListingFormNotifier` → `create_listing_usecase` → `POST /listings`.

### 2.1 Required fields (validation grounded in `listing_form_notifier.dart` + `validators.dart`)

| Field | Rule |
|---|---|
| `title`/`name` | required, non-empty (trimmed) |
| `description` | required, non-empty |
| `price` | required, parses to > 0; input is comma-formatted, strip separators before send |
| `images` | required, ≥1, **max 5** (`_maxPhotos = 5`) |
| `categoryId` | required (subcategory optional) |
| `condition` | recommended required (enum) |
| `stockQuantity` | **make required, ≥1** to publish (currently defaults to 1 via form `quantity`) |
| `compareAtPrice` | optional; if set, must be > `price` |
| `shippingCost` | required only if `shippingAvailable=true` |

Errors are returned as a `Map<String,String>` keyed by field — backend validation errors should map to the same keys so the mobile form can highlight inline.

### 2.2 Create contract

Current `POST /listings` sends only `{title, description, price, images}` — **too thin.** Extend to the full create payload (see §5, EP-2).

### 2.3 Image upload — must fix (⚠️ known gap)

Today images are **local device file paths sent as JSON strings** — they never actually upload. Backend must expose a real upload:

1. `POST /uploads` (multipart) → returns hosted `{ url, id }`, **or** presigned-URL flow (`POST /uploads/sign` → client PUTs to storage → sends back URLs).
2. Mobile then sends `images: [{url, position}]` in the create/update payload.
3. Enforce type (jpg/png/webp), size cap, and count (≤5) server-side too.

This is a **P0** — a catalog with no working image upload can't launch.

---

## 3. READ

### 3.1 List view (customer + vendor)

Two audiences, one paginated endpoint family:

- **Customer list** (`GET /listings`): only `status=active` (+ derived `out_of_stock` shown but not purchasable). Needs: `category`, `subcategory`, price range, `condition`, `vendorId`, search `q`, `sort` (price, newest, popularity via `viewCount`/`saveCount`), and **pagination** (cursor or page/limit). The app already has explore/search + a `search_listings_usecase`.
- **Vendor list** (`GET /listings/mine`): the logged-in vendor's own products across **all** statuses, with the `viewCount/saveCount/inquiryCount` stats the `listing_stats_banner` shows. Already exists; add status filter + pagination.

**⚠️ Pagination decision:** mock returns full lists. Recommend **cursor pagination** for the customer feed (stable under inserts). Backend to confirm page size (suggest 20).

### 3.2 Detail view

`GET /listings/{id}` → `ProductDetailEntity`: listing core + `compareAtPrice`, real `stockQuantity`, `seller`, `specifications`, `reviewSummary`, `reviews[]`, `similarProducts[]`. Parser accepts flat or nested JSON and several key aliases (`compare_at_price`, `stock`, `vendor`/`seller`, `specs`) — **backend should pick ONE canonical key set** and we delete the alias tolerance to remove contract ambiguity (a documented known gap).

**Customer-facing vs vendor-facing fields:** hide `status` (unless active), internal moderation notes, raw cost, and payout data from customers. Show `viewCount/saveCount/inquiryCount` only to the owning vendor and admin.

---

## 4. UPDATE & DELETE/ARCHIVE

### 4.1 Update

`PATCH /listings/{id}` exists but only accepts `{title, description, price, status}`. Extend to allow the vendor to edit: title, description, price, compareAtPrice, images, category, condition, attributes, shipping, and **stock**. Ownership enforced server-side (token's vendor must equal `vendorId`).

- **Price/stock fast path:** these change often. Recommend a lightweight `PATCH /listings/{id}` accepting partial bodies (just `price` or just `stockQuantity`) so vendors can restock/reprice without resubmitting the whole product. If approval is on, **price/stock edits should NOT force re-approval**; content edits (title/images/description) *may* re-enter `pending`. **⚠️ DECISION NEEDED** on that policy.
- **Audit trail:** add `updatedAt` + an append-only `price_history` / `stock_history` (who, when, old→new). Needed for disputes ("the price changed after I ordered") and vendor accountability. Low cost, high trust payoff.

### 4.2 Delete / Archive

`DELETE /listings/{id}` exists (void response, also clears local cache).

**Strong recommendation: soft-delete only.** Set `status=archived` (or `deleted_at` timestamp); never hard-delete a product that has ever been ordered.

**Good news from the code — orders are safe:** `OrderItemModel` and `CartItemEntity` **denormalize** a snapshot of the product (`listingId`, `listingName`, `listingImage`, `category`, `condition`, `price`, `quantity`, `total`). So deleting/archiving a product does **not** break order history or receipts — past orders keep their captured data. What we must handle:

- **Cart references:** `CartItemEntity` carries `isAvailable` + `maxQuantity`. When a product is archived/out-of-stock, backend should flip those so the cart shows "no longer available" and blocks checkout of that line.
- **Wishlist references:** mark saved item unavailable rather than 404.
- Keep `listingId` resolvable (returns the archived record, `status=archived`) so historical links don't hard-error.

---

## 5. Endpoints the backend needs to build

Base URL from `--dart-define=API_BASE_URL` (fallback `http://localhost:8080`). All authed routes use `Authorization: Bearer <token>` (set globally in `dio_provider.dart`; a 401 wipes the token and logs out).

| # | Method | Path | Purpose | Status today |
|---|---|---|---|---|
| EP-1 | GET | `/listings` | Customer catalog: filters, search, sort, pagination | **New** (mock only) |
| EP-2 | POST | `/listings` | Create product (full payload, not just 4 fields) | Exists, **extend** |
| EP-3 | GET | `/listings/{id}` | Product detail (`ProductDetailEntity`) | Exists |
| EP-4 | PATCH | `/listings/{id}` | Update (full + partial price/stock) | Exists, **extend** |
| EP-5 | DELETE | `/listings/{id}` | Soft-delete → `archived` | Exists, **change to soft** |
| EP-6 | GET | `/listings/mine` | Vendor's own products, all statuses + stats | Exists |
| EP-7 | GET | `/listings/similar?category=` | Similar products | Exists |
| EP-8 | GET | `/listings/{id}/reviews` | Reviews list | Exists |
| EP-9 | POST | `/uploads` (multipart) or `/uploads/sign` | Real image upload | **New — P0** |
| EP-10 | GET | `/categories` | Server-driven taxonomy (replaces hardcoded client list) | **New** |
| EP-11 | POST | `/listings/{id}/status` | Admin approve/reject/archive (moderation) | **New** |

### Representative shapes

**EP-2 Create — request**
```json
{
  "title": "iPhone 15 Pro 256GB",
  "description": "Sealed, local warranty.",
  "price": 89999.00,
  "compareAtPrice": 94999.00,
  "currency": "EGP",
  "categoryId": "electronics",
  "subcategoryId": "phones",
  "condition": "new",
  "brand": "Apple",
  "stockQuantity": 5,
  "images": [{ "url": "https://cdn.xstore.eg/....jpg", "position": 0 }],
  "attributes": [{ "key": "Storage", "value": "256GB" }],
  "location": "Cairo",
  "shippingAvailable": true,
  "shippingCost": 60.00
}
```
**EP-2 — response:** the full Product object (§1.1) with server `id`, `vendorId`, `status: "pending"` (or `active` if approval off), `createdAt`, `updatedAt`.

**EP-3 Detail — response (canonical keys, drop aliases):**
```json
{
  "listing": { "...full Product from §1.1..." },
  "compareAtPrice": 94999.00,
  "stockQuantity": 5,
  "locationLine": "Cairo",
  "seller": { "id": "v_12", "name": "TechHub", "avatarUrl": "...", "rating": 4.7, "salesCount": 812, "verified": true },
  "specifications": { "Storage": "256GB", "RAM": "8GB" },
  "reviewSummary": { "average": 4.6, "count": 214 },
  "reviews": [ ... ],
  "similarProducts": [ ... ]
}
```

**Validation errors (all write endpoints):** return `422` with `{ "errors": { "price": "Must be greater than 0", "images": "At least one image required" } }` — same keys the mobile form uses.

---

## 6. Edge cases (must be specified before build)

1. **Out of stock.** `stockQuantity` hits 0 → status derives to `out_of_stock`; still visible, not purchasable; cart lines flip `isAvailable=false`. **⚠️ DECISION:** do we support backorder / "notify me when back"? (Recommend "notify me" later, not launch.)
2. **Price change mid-cart.** `CartItemEntity` captures `price` + `compareAtPrice` at add-time. Backend must **re-price at checkout** and, if the current price differs, return the delta so the app can prompt "price changed from X to Y — confirm?" before placing the order. Never silently charge the new price. This is a trust + chargeback issue.
3. **Stock change mid-cart.** If quantity in cart > available at checkout, return `409` with available count; app clamps to `maxQuantity`.
4. **Vendor deactivation cascade.** When a vendor is suspended/deactivated (admin action): all their `active` products → `paused`/hidden from catalog; open carts flip those lines `isAvailable=false`; **in-flight orders are NOT cancelled** (they're a contract already made) — they continue through fulfillment/dispute flow. New checkouts on that vendor blocked. This needs an explicit `vendorId` on products (see §0.1) to execute — another reason it's required.
5. **Concurrent edits / oversell.** Two customers buy the last unit at once → decrement stock atomically at order placement; second gets `409 out_of_stock`. Don't rely on read-then-write.
6. **Currency integrity.** Everything is **EGP**. Do not carry a `Dzd`-named key into the API (see cleanup note). One currency, server-authoritative, minor-unit safe math.
7. **Image failures.** Upload succeeds but create fails → orphaned images; run a cleanup job or tie uploads to the product transactionally.

---

## 7. Open business decisions (need Ahmed's call)

1. **Admin approval gate** before products go live? (Rec: **yes** for launch.)
2. **Variants** in v1 or fast-follow? (Rec: **fast-follow**, ship single-SKU.)
3. **Re-approval** on content edits vs. free price/stock edits? (Rec: re-approve content, free price/stock.)
4. **Backorder / notify-me** for out-of-stock? (Rec: **later**.)
5. **COD vs. card at launch** (affects "re-price at checkout" flow and payment section) — carried into Deliverable 2.
