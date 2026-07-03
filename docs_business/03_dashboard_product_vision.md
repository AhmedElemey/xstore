# xStore — Admin/Vendor Web Dashboard: Product Vision

**Audience:** You (owner) now; a dashboard designer/dev later.
**Framing:** A **web** dashboard, separate from the mobile app, serving two roles — **Vendors** (manage their own catalog + orders) and **Platform Admin** (you — run the whole marketplace). Built on the *same* backend API as the mobile app (Deliverable 1's Product CRUD is the shared contract), so this is mostly new UI, not a new system.

**Owner's lens:** the dashboard is not a launch blocker for *buyers*, but it is a launch blocker for *vendors and for you*. Vendors won't upload a real catalog by tapping through a phone, and you can't moderate/approve or watch for fraud without an admin view. So a **thin must-have slice ships alongside launch; the rest is fast-follow.**

---

## 1. Who uses it & permission model

Two roles, one app, hard-separated by permission. Reuses the existing Bearer-token auth; the token just needs a `role` claim (`vendor` | `admin`) and, for vendors, the `vendorId`.

| Capability | Vendor | Admin |
|---|---|---|
| See/manage **own** products | ✅ | ✅ (any vendor's) |
| Create/edit/archive products | ✅ own | ✅ any |
| **Approve/reject** products | ❌ | ✅ |
| See **own** orders | ✅ | ✅ (all orders) |
| Update order status (ship/deliver) | ✅ own | ✅ any |
| See **own** sales/analytics | ✅ | ✅ marketplace-wide |
| Vendor approval/suspension | ❌ | ✅ |
| Category management | ❌ | ✅ |
| Dispute handling | Respond to own | ✅ arbitrate |
| Payouts | See own | Manage all |
| Coupons | Own store (⚠️ decision) | Platform-wide |

**Guardrail:** every vendor endpoint is scoped server-side to `token.vendorId` — a vendor must never be able to read/write another vendor's data by guessing an ID. (Same `vendorId`-on-product requirement from Deliverable 1, §0.)

---

## 2. Core modules / screens

### 2.1 Vendor dashboard

**Must-have for launch:**
1. **Product management** — list of own products (all statuses), create/edit using the Deliverable 1 CRUD, image upload, **quick price/stock edit inline**. This is the #1 reason the dashboard must exist at launch: bulk/comfortable catalog entry on a real keyboard.
2. **Stock alerts** — low-stock and out-of-stock flags front-and-center (drives restocking = drives revenue).
3. **Orders** — incoming orders for their store, with the confirm → ship → deliver lifecycle already modeled in the app.
4. **Store profile** — name, logo, hours (store-hours already exist in the app/`store_module`), contact.

**Nice-to-have later:**
5. Sales analytics (trends, best-sellers, conversion).
6. Store-level coupons/promotions.
7. Bulk product import (CSV) — big time-saver once vendors scale.
8. Messaging/inquiries (ties to the deferred chat feature).
9. Payout statements.

### 2.2 Admin dashboard (you)

**Must-have for launch:**
1. **Vendor approval & moderation** — approve/suspend vendors; **product approval queue** (the `pending` gate from Deliverable 1). Without this you can't safely onboard vendors or stop bad listings.
2. **Order oversight** — all orders, filter by vendor/status/date; intervene on stuck orders.
3. **Category management** — CRUD the taxonomy that's currently **hardcoded client-side** (`listing_categories_data.dart`). Backend EP-10 makes this server-driven; this screen edits it.

**Nice-to-have later:**
4. **Marketplace analytics** — GMV, orders, top vendors/products, conversion, growth.
5. **Dispute handling** — case queue, evidence (the denormalized order snapshots from Deliverable 1 §4.2 are your evidence trail), resolution + refund trigger.
6. Coupon/promotion management platform-wide.
7. Payout management / vendor settlements.
8. CMS for banners/home merchandising (mock banners exist today).
9. User (customer) management + support tooling.

---

## 3. Home-screen metrics (front-and-center per role)

**Vendor home:**
- Today/7-day **sales (EGP)** and order count
- **Orders needing action** (to confirm / to ship) — the money-movers
- **Low/out-of-stock count** (from `stockQuantity`)
- Product views / saves / inquiries (`viewCount`, `saveCount`, `inquiryCount` already tracked)
- Pending-approval products (if approval is on)

**Admin home:**
- **GMV** + order volume (today / 7d / 30d) with trend
- **Approval queue size** — vendors and products waiting on you
- **Open disputes / flagged orders**
- Active vendors & new signups
- Top categories / top vendors by GMV
- Payment mix (COD vs. gateway) — matters for cash-flow and COD risk in Egypt

---

## 4. Tech approach — my recommendation (business level)

You'll defer the final call to the dev team; here's my reasoning as owner, optimizing **speed-to-launch vs. long-term cost.**

| Option | Speed to launch | Long-term cost | Owner's take |
|---|---|---|---|
| **A. Flutter Web** (reuse the app codebase) | **Fastest** — reuse models, entities, API clients, auth already built | Flutter Web is weak for data-dense admin tables, SEO-irrelevant here but heavier bundles, and desktop UX polish is fiddly | Good for the **vendor** side (mirrors mobile, same team, same code) |
| **B. Separate React/Next admin panel** | Slower to stand up initially | **Cheaper long-term** for complex tables, filtering, charts, moderation queues; huge hiring pool; best-in-class admin component libraries | Best for the **admin** side, which is table/CRUD/analytics-heavy |
| **C. Off-the-shelf admin** (Retool/Refine/Forest on top of the API) | Very fast for *admin* internal tooling | Recurring license; less brand control; not for vendor-facing | Viable **stopgap for your admin tools** at launch |

**My recommendation — pragmatic split:**

- **Launch:** ship the **vendor** dashboard as **Flutter Web (Option A)** — reuse the Deliverable 1 CRUD, entities, and auth you've already built; the same mobile dev can do it; fastest path to letting vendors load a real catalog. For **your admin** tools, use an **off-the-shelf internal tool (Option C)** on top of the same API so you can approve/moderate from day one without building UI.
- **Post-launch:** rebuild the **admin** panel as a **dedicated React/Next app (Option B)** once volume justifies it — that's where data-density and long-term maintainability pay off.

This gets both roles *functional at launch* with minimal net-new code, and defers the expensive, correct admin build to when you actually have a marketplace to administer. The one thing I'd **not** do is build a bespoke, polished admin panel from scratch *before* launch — it's the classic pre-revenue time sink.

**⚠️ DECISION NEEDED:**
1. Are you comfortable running your admin moderation through an internal-tool (Retool-style) UI at launch, or do you want a branded admin from day one? (Rec: internal tool first.)
2. Do vendors get **store-level coupons** at launch, or platform-only coupons controlled by you? (Rec: platform-only first — simpler, less abuse surface.)
3. Same backend team builds these APIs — confirm the agency's scope includes the **admin/moderation + analytics-aggregation** endpoints (EP-10/EP-11 + analytics), or that's a gap.

---

## 5. What must exist for the dashboard to work (backend dependencies)

Everything here rides on Deliverable 2's backend track. Specifically the dashboard needs: `vendorId` on products, the moderation/status endpoint (EP-11), category CRUD (EP-10), the orders API with vendor scoping, and an analytics-aggregation layer (Phase 3). **No dashboard screen is real before those ship** — so the dashboard is a Phase 2–3 deliverable, not Phase 1, and its "must-have launch slice" (vendor product entry + admin approval) should be scheduled to land *with* the mobile launch, not after.
