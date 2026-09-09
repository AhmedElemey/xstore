# xStore Admin Dashboard — Backend Endpoint Requirements

Hand-off list for the backend developer. This reconciles what the **admin dashboard**
(`docs_business/admin-dashboard/xstore-admin-dashboard/`) needs against what the
**backend** (`xStoreEcommerce`, .NET) implements today.

Legend: ✅ exists (reuse) · ⚠️ partial (extend) · ❌ new (build) · 🆕 new entity/table required

**Currency:** EGP (raw numbers, no formatting). **Payments:** Cash on Delivery.

---

## 0. Cross-cutting prerequisites (do these first — they block everything)

1. **CORS** — add a policy allowing the dashboard's origin(s); config-driven allow-list.
   Without it the browser blocks every call. *(Already on the backend to-do list.)*
2. **HTTPS** — the API is currently served over `http://…jtempurl.com`. The dashboard will
   be hosted over HTTPS, and browsers block HTTPS→HTTP calls (mixed content). Serve the API
   over HTTPS. *(Already on the backend to-do list.)*
3. **Admin auth** — dashboard logs in via existing `POST /api/auth/login` and stores the JWT.
   All admin endpoints must require `[Authorize(Roles = "ADMINISTRATOR")]`. Confirm the admin
   role token works with the standard `Authorization: Bearer` header.
4. **Two conventions to settle** (dashboard assumes one, backend uses the other):
   - **Route prefix:** dashboard assumes `/admin/*`; backend uses `/api/*`. Recommend building
     admin endpoints under `/api/admin/*` and pointing the dashboard's base path there.
   - **ID type:** dashboard mockups use string IDs (`v_123`, `p_456`, `XS-2026-4471`); backend
     uses `int`. Backend `int` is fine — the dashboard will adapt. Just be consistent.
5. **Response envelope** — keep the existing `Result<T>` shape so the dashboard can read
   `{ data, message, statusCode }` uniformly. List endpoints should return the existing
   `PagedResponse<T>` (`{ items, totalCount, page, pageSize }`).

---

## 1. Wireable today (Phase 1 — little/no backend work)

| Dashboard need | Endpoint | Status |
|---|---|---|
| Admin login | `POST /api/auth/login` | ✅ |
| Categories list | `GET /api/categories` | ✅ |
| Create category | `POST /api/categories` | ✅ |
| Update category | `PUT /api/categories/{id}` | ✅ |
| Toggle visible/active | `PUT /api/categories/{id}/status` | ✅ (dashboard's `PATCH {visible}` maps here) |
| Delete category | `DELETE /api/categories/{id}` | ✅ |
| Vendors/Users list | `GET /api/users?role=&status=` | ⚠️ confirm role + status filtering exists |
| Approve vendor | `PUT /api/users/{id}/approve` | ✅ |
| Reject vendor | `PUT /api/users/{id}/reject` | ✅ |
| Product/listing list | `GET /api/listings` | ✅ (read-only view) |

**Small extensions to make Phase 1 complete:**
- ⚠️ `GET /api/admin/users/{id}` — single user/vendor detail (verify it exists; add if not).
- ❌ `GET /api/admin/vendors/{id}/products` — a vendor's listings (can reuse listings filtered by userId).

> **⚠️ Blocker found while wiring Phase 1:** `UserDto` (returned by `GET /api/users`)
> currently exposes only name/email/phone/birthdate/creationDate — **no `Id`, no role,
> no `VendorStatus`** (both are commented out in the DTO). Without the `Id`, the dashboard
> **cannot call** `PUT /api/users/{id}/approve|reject`, and without role/status it can't tell
> vendors from consumers or pending from active. **Please add `Id`, `RoleName`, and
> `VendorStatus` to `UserDto`.** Until then the dashboard shows the Users/Vendors lists as
> read-only sample data and only **Categories** is fully wired.

---

## 2. Product moderation — ⚠️ extend Listing

Backend has listings but no admin moderation workflow.
- ❌ `GET /api/admin/products?status=pending` — pending-review queue.
- ❌ `POST /api/admin/products/{id}/approve`
- ❌ `POST /api/admin/products/{id}/reject`
- ❌ `POST /api/admin/products/{id}/request-changes` `{ note }`
- Needs a moderation status on `Listing` (e.g. `pending | live | rejected | out`) distinct from the
  vendor-facing active/inactive flag.

## 3. Vendors — ⚠️ extend Users

- ✅ list / approve / reject (see §1).
- ❌ `POST /api/admin/vendors/{id}/suspend`
- ❌ `POST /api/admin/vendors/{id}/reinstate`
- ❌ `GET /api/admin/vendors/{id}` — detail with `{ products, gmv, rating, joined, whatsapp, email, status, verified }`
  (gmv/rating depend on Orders + Reviews).
- ❌ `GET /api/admin/vendors/{id}/orders` — depends on Orders (§5).

## 4. Users / Customers — ⚠️ extend Users

- ✅ `GET /api/users?role=consumer`
- ❌ `POST /api/admin/users/{id}/suspend` (add an account-status/blocked flag on `User`).

---

## 5. 🆕 Orders — NEW (highest priority missing piece)

There is **no Order entity** in the backend. For a COD marketplace this is the core gap and blocks
Orders, Overview/analytics (GMV), vendor GMV, disputes, and commission.

**New entities:** `Order`, `OrderItem`.
```
Order      { id, buyerUserId, vendorId, status, payment("cod"), addressText, phone,
             subtotal, shipping, total, createdAt }
OrderItem  { id, orderId, listingId, titleSnapshot, qty, unitPrice }
```
Status enum: `pending | confirmed | processing | shipped | delivered | cancelled`.

**Endpoints:**
- ❌ `GET  /api/admin/orders?status=&limit=&sort=recent`
- ❌ `GET  /api/admin/orders/{id}`
- ❌ `POST /api/admin/orders/{id}/cancel`
- (Consumer-side order creation/checkout is also needed for real orders to exist — scope separately.)

## 6. 🆕 Commission wallet — NEW (per-vendor, mirrors Flutter `VendorCommissionWallet`)

Platform takes flat **2%** per COD order; unpaid accrues as outstanding, settled weekly.
Thresholds are **per-vendor, admin-editable** (Flutter currently hard-codes global consts —
move to per-vendor storage). Depends on Orders (§5).
```
{ outstandingEgp, warnThresholdEgp, pauseThresholdEgp }
```
- ❌ `GET   /api/admin/vendors/{id}/commission`
- ❌ `PATCH /api/admin/vendors/{id}/commission` `{ warnThresholdEgp, pauseThresholdEgp }` — validate `pause >= warn`
- ❌ `POST  /api/admin/vendors/{id}/commission/settle` `{ amountEgp? }` — subtract (floor 0); omit/full = mark paid

## 7. 🆕 Overview / Analytics — NEW (depends on Orders)

- ❌ `GET /api/admin/overview` → `{ gmv30d, orders30d, activeVendors, pendingApprovals, revenueTrend:[num], salesByCategory:[{name,count}] }`
- ❌ `GET /api/admin/analytics` (whatever the Analytics view needs — define with dashboard).

## 8. 🆕 Disputes — NEW

**New entity:** `Dispute { id, orderId, reason, status(open|review|resolved), createdAt }`.
- ❌ `GET  /api/admin/disputes?status=`
- ❌ `POST /api/admin/disputes/{id}/resolve` `{ resolution: "refund"|"partial"|"reject" }`

## 9. 🆕 Coupons — NEW

**New entity:** `Coupon { id, code, description, type(Platform|Seasonal), uses, active }`.
- ❌ `GET /api/admin/coupons` · `POST` · `PATCH /{id}` · `DELETE /{id}`

## 10. 🆕 Content & Banners + Broadcasts — NEW

**New entity:** `Banner { id, title, placement, status(Active|Scheduled|…) }`.
- ❌ `GET /api/admin/banners` · `POST` · `PATCH /{id}` · `DELETE /{id}`
- ❌ `POST /api/admin/broadcasts` `{ title, audience, message }` — push (can build on existing `Notification`).
- ❌ `POST /api/admin/announcements` `{ title, audience, message }`

## 11. 🆕 Settings & Team — NEW

- ❌ `GET /api/admin/settings` · `PATCH /api/admin/settings` — marketplace policy toggles.
  **New entity:** `MarketplaceSettings` (single row / key-value).
- ❌ `GET /api/admin/team` · `POST /api/admin/team/invite` `{ name, email, role }`.
  **New entity:** admin `TeamMember` (or reuse `User` with admin sub-roles).

---

## Suggested build order

1. **Cross-cutting §0** (CORS, HTTPS, admin auth) — unblocks Phase 1 going live.
2. **Phase 1 §1** small extensions (user detail, vendor products) — dashboard's working slice.
3. **§5 Orders** (the keystone) → then **§7 analytics**, **§3 vendor GMV**, **§6 commission**, **§8 disputes**.
4. **§2 moderation**, **§4 user suspend**.
5. **§9 coupons**, **§10 banners/broadcasts**, **§11 settings/team**.

## Notes for shapes
Full JSON shapes for Vendor / Listing / Order / Commission are in
`docs_business/admin-dashboard/xstore-admin-dashboard/BACKEND_HANDOFF.md`. Keep the documented
status-enum string values — the dashboard's filter chips key on them (`data-status`).
