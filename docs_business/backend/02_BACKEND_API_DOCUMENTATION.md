# xStore — Backend API Documentation (All Modules)

**Purpose:** the API contract the backend must implement, module by module. Grounded in the Flutter app's actual expectations (`lib/docs/*_module_api_docs.json` and the app's domain entities).
**Companion:** build order and architecture are in **01_BACKEND_ROADMAP.md**.
**Legend:** ✅ = the app already calls this and expects it · 🆕 = new endpoint the backend must add (not yet in the app) · ⚠️ = gap or fix needed.

---

## Global conventions (apply to every module)

- **Base URL:** injected via `--dart-define=API_BASE_URL`. All paths below are relative to it.
- **Auth:** `Authorization: Bearer <token>` on authenticated requests. Return **401** only for invalid/expired tokens (the app logs the user out on 401).
- **Content type:** `application/json` (except image upload = `multipart/form-data`).
- **Errors:** standard envelope; **422** with field keys for validation (matches the app's inline form errors):
  ```json
  { "error": { "code": "VALIDATION_ERROR", "message": "...", "fields": { "price": "Must be > 0" } } }
  ```
- **Money:** EGP; exact server math (integer minor units or decimal). No floats in DB.
- **IDs:** server-generated (UUID recommended).
- **Pagination:** cursor-based for the catalog; `{ items: [...], nextCursor: "..." }`.
- **Canonical keys:** the app tolerates some alternate JSON key names today; pick the canonical set below and we'll remove the app's alias tolerance.

**Module map & endpoint counts:**

| Module | REST endpoints | Notes |
|---|---|---|
| 1. Authentication | 3 (+ OTP/social flows) | Phone & social currently bypass backend |
| 2. Home | 3 | Merchandising feed |
| 3. Explore / Search | 2 | Shares `/listings` with catalog |
| 4. Product (detail) | 3 | Read side of catalog |
| 5. Listing (vendor) | 4 | Write side; needs `vendorId` + real uploads |
| 6. Cart & Checkout | 9 | COD order placement |
| 7. Wishlist | 6 | Consumer-only |
| 8. Orders | 11 | Full lifecycle, both roles |
| 9. Profile | 6 | Incl. account deletion |
| 10. Notifications | 0 (🆕 build all) | App is mock-only; no push |
| 11. Store (hours) | 3 | Vendor availability |

---

## 1. Authentication — `lib/features/auth/`

**Purpose:** account creation and login for buyers and vendors; issues the Bearer token everything else uses.

### Data model — `UserEntity`
`id, name, email, phoneNumber, avatarUrl, role (vendor|consumer), isVerified, rating, totalSales, joinedAt, location` + vendor fields: `storeName, storeSlug, storeCategory, storeDescription, storeLogoUrl, storeCity, whatsappNumber, latitude, longitude, governorate, town, detailAddress, bio, dateOfBirth, instagramHandle, facebookPage, isNewUser`. Role enum: `vendor | consumer` (add `admin` server-side for the dashboard).

### Endpoints
| Method | Path | Notes |
|---|---|---|
| POST | `/auth/register` | ✅ Create account (buyer or vendor). Returns user + token. |
| POST | `/auth/login` | ✅ Email/password. Returns user + token. |
| POST | `/auth/logout` | ⚠️ Declared but the app never calls it — logout is client-side. Implement for token revocation if you add server sessions. |

**Request (register):** `{ name, email, phoneNumber, password, role }` (+ vendor fields when role=vendor).
**Response:** `{ user: {…UserEntity}, token: "<jwt>" }`.

### Gaps / fixes ⚠️
- Login/register currently use inline maps — define typed DTOs server-side.
- **Phone OTP** and **social sign-in** (Google/Apple/Facebook) currently bypass the backend entirely (handled by Firebase on-device). Decide whether the server must create/verify a user record for these — recommended: verify the Firebase ID token server-side and mint your own JWT so all users exist in your DB.
- No refresh token today (token embedded in user payload) — agree a refresh strategy.

---

## 2. Home — `lib/features/home/`

**Purpose:** the buyer landing feed (banners, hot deals, categories).

### Data model — `DealEntity`
`id, title, price, imageUrl, discountPercent`.

### Endpoints
| Method | Path | Notes |
|---|---|---|
| GET | `/home/banners` | ✅ Hero banners. |
| GET | `/home/hot-deals` | ✅ Flash/hot deals (list of DealEntity). |
| GET | `/home/categories` | ✅ Category shortcuts. |

### Gaps / fixes ⚠️
- No dedicated new-arrivals or recommended endpoints — the app reuses hot-deals. Add real ones when ready.
- Make banners **admin-editable** (merchandising) — see the admin dashboard need in the roadmap.

---

## 3. Explore / Search — `lib/features/explore/`

**Purpose:** search + filters + suggestions.

### Endpoints
| Method | Path | Notes |
|---|---|---|
| GET | `/listings` | ✅ Search catalog. Query: `q, category, subcategory, minPrice, maxPrice, condition, vendorId, sort, cursor, limit`. Returns active listings only. |
| GET | `/listings/suggestions` | ✅ Type-ahead. Returns `List<String>`. |

### Gaps / fixes ⚠️
- `/listings` is shared with the Listing module's create route — disambiguate by method (GET=search, POST=create).
- Suggestions are untyped strings today — keep simple or return `{ suggestions: [...] }`.

---

## 4. Product (Detail) — `lib/features/product/`

**Purpose:** the product page (gallery, specs, seller, reviews, similar).

### Data model — `ProductDetailEntity`
Wraps a listing and adds: `compareAtPrice, stockQuantity (⚠️ app defaults to 99 — send real stock), locationLine, seller, specifications (key/value map), reviewSummary, reviews[], similarProducts[]`.
`ProductSellerEntity`: `id, name, avatarUrl, rating, salesCount, verified` (⚠️ app has placeholder defaults 4.9/230/false — send real values).
`ReviewEntity`: `id, userId, userName, userAvatar, rating, comment, helpfulCount, createdAt`.

### Endpoints
| Method | Path | Notes |
|---|---|---|
| GET | `/listings/{id}` | ✅ Full product detail. |
| GET | `/listings/similar?category=` | ✅ Similar products (excludes current id client-side). |
| GET | `/listings/{id}/reviews` | ✅ Reviews list. |

**Response (detail) — canonical keys (drop aliases):**
```json
{
  "listing": { "…full listing…" },
  "compareAtPrice": 94999.00,
  "stockQuantity": 5,
  "locationLine": "Cairo",
  "seller": { "id": "v_12", "name": "TechHub", "avatarUrl": "…", "rating": 4.7, "salesCount": 812, "verified": true },
  "specifications": { "Storage": "256GB" },
  "reviewSummary": { "average": 4.6, "count": 214 },
  "reviews": [ … ],
  "similarProducts": [ … ]
}
```

### Gaps / fixes ⚠️
- The app's parser accepts alternate keys (`compare_at_price`, `stock`, `vendor`/`seller`, `specs`). Pick one canonical set — above — and we remove the tolerance.
- Real `stockQuantity` and real `seller` stats are mandatory before launch (placeholders mislead buyers).

---

## 5. Listing (Vendor Products) — `lib/features/listing/`

**Purpose:** vendor product management (create/edit/delete + "my listings" with stats).

### Data model — `ListingEntity`
`id, title, description, price, status, imageUrls[], categoryLabel, conditionLabel, postedAt, viewCount, saveCount, inquiryCount`.
Status enum: `draft, pending, active, paused, sold, rejected` → **reconcile to** `draft, pending, active, paused, out_of_stock, rejected, archived` server-side.
Create form fields: `photoPaths (max 5), name, priceInput, compareAtPriceInput, description, categoryId, subcategoryId, condition, brand, quantity, location, shippingCostInput, shippingAvailable, attributes[{key,value}]`.

### Endpoints
| Method | Path | Notes |
|---|---|---|
| POST | `/listings` | ✅ Create. ⚠️ App sends only `{title, description, price, images}` — **extend** to full payload incl. `vendorId`, stock, category, condition, attributes. New products start `status=pending` (admin approval). |
| GET | `/listings/mine` | ✅ Vendor's own listings, all statuses, with view/save/inquiry stats. |
| PATCH | `/listings/{id}` | ✅ Update. ⚠️ App sends `{title, description, price, status}` — extend to all editable fields. Support partial price/stock updates. |
| DELETE | `/listings/{id}` | ✅ ⚠️ Change to **soft-delete** (`status=archived`), never hard-delete. |

### Gaps / fixes ⚠️
- **`vendorId` does not exist on the listing model — add it (required).** Ownership is currently only implied by the token on `/listings/mine`.
- **Image upload uses local file paths** — build a real `POST /uploads` (multipart or presigned) returning hosted URLs; the app then sends `images: [{url, position}]`.
- No variant/SKU model — single SKU per product at launch (locked decision).
- Content edits (title/images/description) → re-enter `pending`; price/stock edits stay live (policy).

### 🆕 Supporting endpoints to add
| Method | Path | Notes |
|---|---|---|
| POST | `/uploads` | 🆕 Image upload (multipart) or `/uploads/sign` for presigned. |
| GET | `/categories` | 🆕 Server-driven taxonomy (replaces the app's hardcoded category list). |
| POST | `/listings/{id}/status` | 🆕 Admin approve/reject/archive (moderation). |

---

## 6. Cart & Checkout — `lib/features/cart/`

**Purpose:** multi-vendor cart, coupons, and COD order placement.

### Data model — `CartItemEntity`
`id, listingId, listingName, listingImage, listingSlug, vendorId, vendorName, vendorStoreName, vendorAvatar, vendorRating, vendorVerified, price, compareAtPrice, quantity, maxQuantity, category, condition, shippingAvailable, shippingCost, isAvailable, addedAt`.
`PlaceOrderParams`: checkout payload (⚠️ contains card fields the app does **not** send to the API — **COD only at launch; remove card capture**).

### Endpoints
| Method | Path | Notes |
|---|---|---|
| GET | `/cart/{consumerId}` | ✅ Get cart (grouped by vendor). |
| POST | `/cart/{consumerId}/items` | ✅ Add or update item. |
| PATCH | `/cart/{consumerId}/items/{itemId}` | ✅ Update quantity. |
| DELETE | `/cart/{consumerId}/items/{itemId}` | ✅ Remove item. |
| DELETE | `/cart/{consumerId}` | ✅ Clear cart. |
| POST | `/cart/coupons/apply` | ✅ Apply coupon (validate server-side). |
| DELETE | `/cart/{consumerId}/coupon` | ✅ Remove coupon. |
| POST | `/orders` | ✅ **Place order (COD).** Re-validate stock/price; decrement stock atomically. |
| GET | `/listings/{listingId}` | ✅ Used to build a cart line from a listing (same as Product detail). |

### Gaps / fixes ⚠️
- **Coupons must be validated server-side** (not trusted from client).
- **Checkout re-validation:** if stock < requested → `409` with available qty; if price changed → return delta so the app can confirm. Never silently change the charged amount.
- Card fields in `PlaceOrderParams` are unused — COD only; drop them.
- No `cart/*` routes in the app's `ApiEndpoints` (inline paths) — you define them per above.

---

## 7. Wishlist — `lib/features/wishlist/`

**Purpose:** saved items with price-drop tracking (consumer-only).

### Data model — `WishlistItemEntity`
`id, listingId, listingName, listingImages[], listingSlug, vendorId, vendorName, vendorStoreName, vendorAvatar, isVendorVerified, price, compareAtPrice, previousPrice, priceDropPercent, category, condition, rating, reviewCount, stockQuantity, isAvailable, isInCart, shippingAvailable, shippingCost, addedAt, lastPriceCheckAt`.

### Endpoints
| Method | Path | Notes |
|---|---|---|
| GET | `/wishlist/{consumerId}` | ✅ Get wishlist. |
| POST | `/wishlist/{consumerId}/items` | ✅ Add item. |
| DELETE | `/wishlist/{consumerId}/items/{listingId}` | ✅ Remove item. |
| DELETE | `/wishlist/{consumerId}` | ✅ Clear wishlist. |
| PUT | `/wishlist/items/{listingId}` | ✅ ⚠️ Upsert — path omits `consumerId`; make consistent (`/wishlist/{consumerId}/items/{listingId}`). |

### Gaps / fixes ⚠️
- Price-drop fields (`previousPrice`, `priceDropPercent`, `lastPriceCheckAt`) imply a server job that snapshots price over time — build it to power price-drop notifications.

---

## 8. Orders — `lib/features/orders/`

**Purpose:** the full fulfillment lifecycle for buyers and vendors.

### Data model — `OrderEntity`
Status enum: `pending, confirmed, processing, shipped, delivered, cancelled, refunded`.
`PaymentMethod`: `cashOnDelivery` at launch (⚠️ remove `cibCard, dahabiCard, baridimob` — Algerian, out of scope).
`OrderAddress`: `fullName, phone, street, city, wilaya→governorate, postalCode, isDefault`.
`ShippingInfo`: `trackingNumber, courierName, estimatedDelivery`.
`OrderItemModel`: **denormalized snapshot** — `id, listingId, listingName, listingImage, category, condition, price, quantity, total`. Keep this snapshot; it protects order history from product changes/deletion.
`OrderStatsEntity`: vendor dashboard counters.

### Endpoints
| Method | Path | Notes |
|---|---|---|
| GET | `/orders/consumer/{consumerId}` | ✅ Buyer's orders. |
| GET | `/orders/vendor/{vendorId}` | ✅ Vendor's orders. |
| GET | `/orders/{orderId}` | ✅ Order detail. |
| GET | `/orders/vendor/{vendorId}/stats` | ✅ Vendor order stats. |
| POST | `/orders/{orderId}/cancel` | ✅ Cancel (buyer). |
| POST | `/orders/{orderId}/confirm` | ✅ Confirm (vendor). |
| POST | `/orders/{orderId}/reject` | ✅ Reject (vendor). |
| POST | `/orders/{orderId}/processing` | ✅ Mark processing. |
| POST | `/orders/{orderId}/shipped` | ✅ Mark shipped. |
| POST | `/orders/{orderId}/delivered` | ✅ Mark delivered. |
| POST | `/orders/consumer/{consumerId}` | ✅ Register a placed order (see gap). |

### Gaps / fixes ⚠️
- Order creation is split in the app: `POST /orders` (cart) + a `register` call (orders datasource). **Unify to one authoritative `POST /orders`** server-side.
- Enforce valid status transitions (e.g. can't ship a cancelled order).
- No courier integration yet (`ShippingInfo` is manual) — line up a courier partner for real tracking.

---

## 9. Profile — `lib/features/profile/`

**Purpose:** view/edit profile, avatar, vendor store page, account deletion.

### Data model
Reuses `UserEntity` (Module 1).

### Endpoints
| Method | Path | Notes |
|---|---|---|
| GET | `/users/{userId}` | ✅ Get profile. |
| GET | `/users/{sellerId}/store` | ✅ Public vendor store profile. |
| PUT | `/users/{userId}` | ✅ Update profile. |
| POST | `/users/{userId}/avatar` | ✅ ⚠️ Avatar upload — app currently returns a placeholder URL; implement real upload. |
| DELETE | `/users/me` | ✅ **Delete account** — real deletion path (supports the Privacy Policy's data-deletion right). |
| GET | `/users/{sellerId}/listings` | ✅ Vendor store listings. |

### Gaps / fixes ⚠️
- Avatar update ignores the file today — make it a real upload (reuse `/uploads`).
- Ensure `DELETE /users/me` performs true deletion/anonymization, honoring legal obligations (keep what's needed for completed orders/tax).

---

## 10. Notifications — `lib/features/notifications/` 🆕 BUILD ENTIRELY

**Purpose:** activity inbox + push. **The app has ZERO REST endpoints here — all mock.** This is the biggest backend gap.

### Data model — `NotificationEntity`
`id, type, priority (low/normal/high/urgent), title, body, imageUrl, actionRoute, actionData, isRead, createdAt, orderId, listingId`.
`NotificationType` — 21 values: `orderPlaced, orderConfirmed, orderShipped, orderDelivered, orderCancelled, priceDrop, backInStock, flashSale, newMessage, reviewReply, promotionalOffer, newOrder, orderCancelledVendor, newReview, listingApproved, listingRejected, paymentReceived, lowStock, accountVerified, systemAnnouncement, securityAlert`.

### 🆕 Endpoints to build
| Method | Path | Notes |
|---|---|---|
| GET | `/notifications` | 🆕 Paginated feed for the user. |
| GET | `/notifications/unread-count` | 🆕 Badge count. |
| POST | `/notifications/{id}/read` | 🆕 Mark read. |
| POST | `/notifications/read-all` | 🆕 Mark all read. |
| POST | `/notifications/{id}/unread` | 🆕 Mark unread. |
| DELETE | `/notifications/{id}` | 🆕 Delete. |
| PUT | `/notifications/settings` | 🆕 Per-type push/email/SMS toggles (app stores these locally today). |

### Push ⚠️
- Integrate **Firebase Cloud Messaging (FCM)** — the app has no push SDK yet. Emit notifications on order status changes, price drops, listing approval, low stock, etc. (map to the 21 types).

---

## 11. Store (Store Hours) — `lib/features/store/`

**Purpose:** vendor weekly availability + open/closed status.

### Data model
`StoreHoursEntity`: `vendorId, isStoreOpen, temporaryMessage, schedule[DayScheduleEntity], updatedAt`.
`DayScheduleEntity`: per-day open/close times.
`StoreStatusEntity`: `isOpen, currentDayHours, nextOpenDay, statusLabel, nextOpenLabel` (can be derived server-side).

### Endpoints
| Method | Path | Notes |
|---|---|---|
| GET | `/vendors/{vendorId}/store-hours` | ✅ Get hours. |
| PUT | `/vendors/{vendorId}/store-hours` | ✅ Update hours. |
| PATCH | `/vendors/{vendorId}/store-status` | ✅ Toggle open/closed. |

### Gaps / fixes ⚠️
- Validate schedule (open < close, no overlaps). The app already has a store-hours validator — mirror its rules.

---

## Summary of the biggest backend-side fixes (do these deliberately)

1. **Add `vendorId` to every listing** — required for a real multi-vendor marketplace.
2. **Real image upload** (`/uploads`) — replace local-file-path strings.
3. **Server-driven `/categories`** — replace the app's hardcoded taxonomy.
4. **Admin/moderation endpoints** — vendor + product approval (the go-live gate).
5. **Build notifications from scratch** + FCM push (currently 100% mock).
6. **Soft-delete + denormalized order snapshots** — protect order history.
7. **Checkout re-validation** — stock/price at order time; atomic decrement.
8. **Reconcile enums** — product status set; payment method = COD only.
9. **Pick canonical JSON keys** — so we can drop the app's alias tolerance.

*Companion: **01_BACKEND_ROADMAP.md** for the phased plan and step-by-step checklist.*
