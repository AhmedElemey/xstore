# xStore Admin Dashboard — Backend Handoff

Front-end design prototype (no build step, plain HTML/CSS/JS). All data is currently
hard-coded in `src/app.js` and all actions are simulated (toasts/drawers). This doc lists
the endpoints and payload shapes the dashboard expects so the backend can wire it up.

Base path assumed: `/admin` (admin-authenticated). Currency is EGP, payment is Cash on Delivery.

## Files
- `src/index.html` — shell (sidebar, topbar, content container)
- `src/styles.css` — design tokens + all styles
- `src/app.js` — views, drawers, forms, and the in-memory demo data (`VENDORS`, `VLISTINGS`,
  `VCOMM`, `ORDERS`, `DISPUTES`, `CUSTOMERS`, `CATS`, `COUPONS`, `BANNERS`, `TEAM`)

Each in-memory constant in `app.js` maps 1:1 to a GET endpoint below. Replace the constant
with the response and the views render unchanged.

---

## Endpoints by view

### Overview  (`overview()`)
- `GET /admin/overview` → `{ gmv30d, orders30d, activeVendors, pendingApprovals, revenueTrend:[num], salesByCategory:[{name,count}] }`
- `GET /admin/orders?limit=5&sort=recent`
- `GET /admin/products?status=pending&limit=4`

### Product Moderation  (`moderation()`, `productDrawer()`)
- `GET /admin/products?status=pending`
- `POST /admin/products/{id}/approve`
- `POST /admin/products/{id}/reject`
- `POST /admin/products/{id}/request-changes`

### Vendors  (`vendors()`, `vendorDrawer()`, `vdecide()`)
- `GET /admin/vendors` → list of Vendor (see shape below)
- `GET /admin/vendors/{id}`
- `POST /admin/vendors/{id}/approve` · `.../reject` · `.../suspend` · `.../reinstate`

### Vendor detail page  (`vendorProducts()` — tabs: Listings / Orders / Commission)
- **Listings** — `GET /admin/vendors/{id}/products` → list of Listing
- **Orders** — `GET /admin/vendors/{id}/orders` → list of Order (buyer, items, total, status)
- **Commission** — see the Commission wallet section below

### Orders  (`orders()`, `orderDrawer()`)
- `GET /admin/orders?status=` · `GET /admin/orders/{id}`
- `POST /admin/orders/{id}/cancel`

### Disputes  (`disputes()`, `disputeDrawer()`)
- `GET /admin/disputes?status=`
- `POST /admin/disputes/{id}/resolve` body `{ resolution: "refund"|"partial"|"reject" }`

### Users / Customers  (`customers()`, `userDrawer()`)
- `GET /admin/users?role=consumer` · `GET /admin/users/{id}`
- `POST /admin/users/{id}/suspend`

### Categories  (`categories()`, `openCategoryForm()`)
- `GET /categories` (server-driven taxonomy) · `POST /admin/categories`
- `PATCH /admin/categories/{id}` `{ visible: bool }`

### Coupons  (`coupons()`)
- `GET /admin/coupons` · `POST /admin/coupons` · `PATCH /admin/coupons/{id}` · `DELETE /admin/coupons/{id}`

### Content & Banners  (`content()`)
- `GET /admin/banners` · `POST /admin/banners` · `PATCH /admin/banners/{id}` · `DELETE /admin/banners/{id}`
- `POST /admin/broadcasts` `{ title, audience, message }` (push)

### Settings  (`settings()`)
- `GET /admin/settings` · `PATCH /admin/settings` (marketplace policy toggles)
- `GET /admin/team` · `POST /admin/team/invite` `{ name, email, role }`

### Announcements
- `POST /admin/announcements` `{ title, audience, message }`

---

## Data shapes

### Vendor
```json
{
  "id": "v_123",
  "name": "Cairo Tech Hub",
  "owner": "Ahmed Salah",
  "city": "Giza",
  "category": "Electronics",
  "status": "active",          // active | pending | suspended
  "verified": true,
  "products": 214,
  "gmv": 486300,
  "rating": 4.7,
  "joined": "2026-01",
  "whatsapp": "+20 102 999 1122",
  "email": "shop@gizagadgets.eg"
}
```

### Listing  (vendor product)
```json
{
  "id": "p_456",
  "title": "iPhone 13 Pro 256GB",
  "subcategory": "Phones & tablets",
  "price": 48999,
  "compareAt": 52999,          // 0 / null if none
  "stock": 7,
  "status": "live",            // live | pending | out (out of stock)
  "sold30d": 42,
  "rating": 4.7
}
```

### Order
```json
{
  "id": "XS-2026-4471",
  "buyer": "Ahmed Hassan",
  "phone": "+20 100 111 2233",
  "address": "12 Tahrir St, Dokki, Giza",
  "vendorId": "v_123",
  "status": "delivered",       // pending|confirmed|processing|shipped|delivered|cancelled
  "payment": "cod",
  "items": [ { "title": "iPhone 13 Pro 256GB", "qty": 1, "unitPrice": 48999 } ]
}
```

---

## Commission wallet  (most important — newest feature)

Mirrors the Flutter entity `VendorCommissionWallet`
(`lib/features/commission/domain/entities/vendor_commission_wallet.dart`).
Platform takes a flat **2%** commission per COD order; unpaid commission accrues as the
vendor's **outstanding balance**, settled weekly. Thresholds are **per-vendor, admin-editable**.

### Shape
```json
{
  "outstandingEgp": 210.0,
  "warnThresholdEgp": 100.0,   // >= warn  -> notify vendor to pay      (alert: "warn")
  "pauseThresholdEgp": 200.0   // >= pause -> block new listing publishes (alert: "paused")
}
```
Alert level (server or client): `outstanding >= pause` → **paused**; else `>= warn` → **warn**; else **none**.

### Endpoints
- `GET  /admin/vendors/{id}/commission` → the wallet shape above
- `PATCH /admin/vendors/{id}/commission` `{ warnThresholdEgp, pauseThresholdEgp }`
  — save thresholds. Validate `pauseThresholdEgp >= warnThresholdEgp`.
- `POST /admin/vendors/{id}/commission/settle` `{ amountEgp }`
  — record a payment received from the vendor; subtract from `outstandingEgp` (floor 0).
  Omit `amountEgp` (or send the full balance) to **mark fully paid** (reset to 0).

> Note: the Flutter app currently hard-codes `kCommissionWarnThresholdEgp` /
> `kCommissionPauseThresholdEgp` as global consts. For per-vendor editing to work, the
> backend needs to store these per vendor and the app must read them from
> `GET /admin/vendors/{id}/commission` instead of the const.

---

## Wiring notes
- Every list view renders rows with `data-status="…"` — keep the status enum values above so
  the filter chips keep working.
- Money is rendered with `EGP(n)`; send raw numbers (EGP, no formatting).
- Actions currently call `toast(...)`; swap those for `fetch()` calls and re-render on success.
