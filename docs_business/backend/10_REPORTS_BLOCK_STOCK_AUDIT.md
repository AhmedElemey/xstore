# Reports, Block/Unblock and Stock-Before-Checkout: Endpoint Audit

**Date:** 2026-09-24 · **Source:** `xStoreEcommerce_API.postman_collection` (latest) · **Checked against:** hosted API `xstoreegy002-001-site1.etempurl.com` and the `dev` app code

Reviewed from four angles: business owner (risk and priority), backend (contract), Flutter (app wiring) and QA (tests and live probes).

## How it was tested

- **Live probes (no login).** There were no test credentials, and guessing the seeded accounts' passwords is off-limits, so authenticated routes were checked by response status only. **401** means the route is deployed. A bare **404** means it isn't (a made-up sibling path was used to confirm this). The stock route is public, so its full contract could be probed.
- **The hosted catalog is empty** (`/api/home` and `/api/listings` return nothing), so a real in-stock or out-of-stock listing could not be tested live.
- **Automated tests:** unit tests for the datasource and a checkout-provider flow test, using a scripted Dio (listed below).

## 1. Endpoint validity

| Endpoint | In collection | Hosted API | App uses it | Verdict |
|---|---|---|---|---|
| `POST /api/reports/vendor` | ✅ | ✅ 401 (deployed) | ✅ Report Vendor sheet | **Valid.** App body now matches (ids as numbers) |
| `POST /api/reports/user` | ✅ | ✅ 401 | ❌ | Valid, not used by the app (see B4) |
| `GET /api/admin/reports/vendor` | ✅ | ✅ 401 | n/a (admin) | Valid |
| `GET /api/admin/reports/user` | ✅ | ✅ 401 | n/a (admin) | Valid |
| `POST /api/users/{id}/block` | ✅ | ❌ **404, not deployed** | n/a (admin) | **Broken on hosted** (B1) |
| `POST /api/users/{id}/unblock` | ✅ | ❌ **404, not deployed** | n/a (admin) | **Broken on hosted** (B1) |
| `POST /api/admin/vendors/{id}/block` | ✅ | ✅ 401 | n/a (admin) | Valid |
| `POST /api/admin/vendors/{id}/unblock` | ✅ | ✅ 401 | n/a (admin) | Valid, but the request may 415 (B2) |
| `GET /api/listings/{id}/stock?quantity=N` | ✅ | ✅ public | ✅ **now, before checkout** | **Valid.** Contract below |

**Stock contract (probed live):** Result envelope `{isSuccess, data, errorEn, errorAr, statusCode}`.
- `data` is a **bool**: can the listing fill `quantity` right now.
- Unknown or inactive listing: `404 "Listing not found."`
- `quantity` ≤ 0: `400 "'Quantity Value' must be greater than '0'."`
- Non-numeric `quantity`: ASP.NET's standard validation 400.
- `quantity` omitted: falls through to the listing lookup (404 for an unknown id).
- Not observed: the success body for a real listing, since the catalog is empty.

## 2. What we fixed in the app (this branch)

1. **Stock is checked before checkout** (`cart_remote_datasource.dart`). The backend has no multi-item order, so checkout places one `POST /api/orders` per cart line. Before this fix, a sold-out line found halfway through the loop left the buyer with a half-placed order. Now every line is checked in parallel **before any order is placed**. If any line is short:
   - **nothing is ordered;**
   - the short line's quantity is capped to the stock that's left, or the line is marked unavailable;
   - the cart reloads, and the buyer sees *"Some items no longer have enough stock… Nothing was ordered yet."* (EN/AR).

   If the stock check itself fails (network error, 5xx), checkout still goes ahead and the order POST stays the final check, so a stock-endpoint outage can't stop every sale.
2. **Stock is no longer made up.** A cart line whose listing had no stock field got `maxQuantity = 10`. A missing stock value now makes the line unavailable.
3. **Report Vendor matches the contract.** `vendorId`/`orderId` are sent as JSON numbers (as in the collection and in `createOrder`). The stale "PROPOSED / 404s" comments are gone, and the analytics failure reason `outOfStock` is tracked.

## 3. Backend asks (priority order)

| # | Priority | Ask |
|---|---|---|
| B0 | **P0** | **Confirm that `POST /api/orders` re-checks and decrements stock atomically.** The app's pre-check can't stop two buyers taking the last unit at the same moment; only the order write can. If it doesn't, we will oversell COD orders and vendors will cancel on the doorstep. |
| B1 | **P1** | **Deploy `POST /api/users/{id}/block` and `/unblock`** (both 404 on hosted). Right now the admin can block vendors but **cannot block an abusive customer**. |
| B2 | P1 | Unblock has **no body and no Content-Type** in the collection. This ASP.NET API has already returned **415** for a body-less POST (`/orders/{id}/cancel`). Either accept an empty body, or document `{}` with `application/json`. |
| B3 | P1 | **Define what a blocked account gets back** from login and every other call: a stable status (403) plus a stable `errorEn`/code and `blockedUntil`. The app shows `errorEn` today, but a blocked user needs a proper "account suspended until X" screen, not a generic error. Also document the `blockedUntil` format (ISO-8601 UTC?). |
| B4 | P2 | **Reports have no workflow.** There is no status (open/resolved/dismissed), no admin action route, and no link from a report to block. Reports will pile up unread. Also document the allowed `reason` values: the app sends `Fraud, PoorProductQuality, ItemNotAsDescribed, NoResponseFromSeller, Harassment, Other`, and the collection only shows `Fraud`/`Harassment`. Decide on duplicate protection (one report per order?). |
| B5 | P2 | **The stock endpoint only answers yes/no.** Return `{available, availableQuantity}` so the app can cap the quantity from one call instead of re-reading the listing. |
| B6 | P3 | **Collection hygiene:** approve/reject/settle appear under both `/api/users/...` and `/api/admin/vendors/...`, and settle is `PUT` in one and `POST` in the other. Pick one canonical route. Also, the admin-only user routes have no `/admin` prefix. |

## 4. Business risks

- **App Store Guideline 1.2 (user-generated content).** Buyers post reviews and contact sellers, and Apple expects a way to **block abusive users**. There is no route for a user to block another user (only admin block). Reporting covers part of this; ask the backend whether a user-level block is planned before iOS review.
- **The vendor side has no report flow.** A vendor abused by a buyer can't report them in the app, even though `POST /api/reports/user` exists. This belongs in the phase-2 backlog.

## 5. QA coverage

**Automated (all passing):**
- `test/features/cart/data/datasources/cart_remote_datasource_test.dart`:
  - each line is checked with its own quantity before any order;
  - one short line blocks the whole checkout and is capped to what's left;
  - a 404 marks the line unavailable;
  - "refused but the listing claims enough" marks the line unavailable (no retry loop);
  - a stock-check outage doesn't block checkout;
  - missing stock is unavailable.
- `test/checkout_order_flow_test.dart`: the provider-level flow. `outOfStock` is surfaced and no `POST /api/orders` is sent.
- `test/vendor_report_usecase_test.dart`: the Report Vendor wire body matches the collection.

**Still to test manually (needs a test consumer and an admin account, plus one approved listing with stock 1):**
1. Two buyers order the last unit at the same moment → one succeeds and the other gets a clear error (this checks B0).
2. Cart with qty 3 while stock is 1 → Place Order → message shown, the line is capped to 1, no order is created.
3. Report Vendor on a real order → 2xx, and the report shows in `GET /api/admin/reports/vendor`.
4. Admin blocks a vendor → the vendor's next API call or login shows what? (checks B3) → unblock → the vendor recovers.
