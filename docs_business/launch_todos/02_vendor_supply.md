# Business brief: Vendor supply (web catalog + moderation)

**To-do ID:** `vendor-supply`  
**Priority:** P0 — supply-side launch blocker  
**Audience:** Product owner, backend agency, dashboard/web dev

---

## 1. Executive summary

Marketplaces fail without **supply**. xStore’s mobile app lets vendors add listings, but **serious Egyptian sellers** need keyboard, bulk edits, and image workflow on **desktop/web**. Your own dashboard vision ([`03_dashboard_product_vision.md`](../03_dashboard_product_vision.md)) states: *vendors won’t upload a real catalog by tapping through a phone*.

**Recommendation:** Treat **vendor web dashboard (minimum slice) + admin approval queue** as **co-equal launch blockers** with consumer COD checkout — not a post-launch nice-to-have.

---

## 2. Problem statement

| Gap | Business impact |
|-----|-----------------|
| Phone-only catalog entry | Thin inventory, high vendor churn after signup |
| No admin product/vendor approval | Fraud listings, COD abuse, chargebacks via “never received” |
| Analytics/earnings menus “Coming Soon” on mobile | Vendors assume platform is not ready for business |
| Categories hardcoded or partially API-driven | Wrong taxonomy → poor discovery |

---

## 3. Minimum launch slice (vendor web)

Per [`03_dashboard_product_vision.md`](../03_dashboard_product_vision.md) **must-have for launch:**

1. **Product management** — list own products, create/edit, image upload, inline price/stock.
2. **Stock alerts** — low/out of stock visible on login.
3. **Orders** — incoming orders; confirm → ship → deliver (same lifecycle as mobile).
4. **Store profile** — name, logo, hours, contact (aligns with mobile store-hours + profile API).

**Admin must-have:**

1. **Vendor approval & suspension**
2. **Product approval queue** (pending → live)
3. **Order oversight** — all orders, filter by vendor/status
4. **Category management** — server-driven taxonomy (EP-10)

**Pragmatic split (from vision doc):**

- Vendor UI: **Flutter Web** reusing mobile API/models (fastest for one team).
- Admin moderation at launch: **internal tool (Retool-style)** on same API if bespoke admin UI slips — still must exist on day one.

---

## 4. Mobile app role after web ships

Mobile becomes **companion**, not primary catalog tool:

| Mobile | Web |
|--------|-----|
| Push: new order | Bulk catalog edit |
| Quick stock/price tweak (optional) | Image uploads, variants |
| Store open/closed toggle | Analytics (phase 2) |
| WhatsApp with buyers | Payout statements (later) |

Update vendor profile menu: link **“Manage catalog on web”** instead of dead Analytics/Earnings screens until APIs exist (see doc 04).

---

## 5. Backend dependencies

From [`02_development_roadmap.md`](../02_development_roadmap.md) and dashboard vision:

- Auth with `role` + `vendorId` scoping on every vendor endpoint
- Product CRUD + image upload (EP-1…EP-9)
- Categories API (EP-10)
- Moderation status (EP-11)
- Orders API with vendor scope
- **No dashboard screen is real before these ship**

---

## 6. Success metrics

| Metric | Meaning |
|--------|---------|
| Active vendors with ≥ 10 live SKUs | Supply depth |
| Median time vendor signup → first approved listing | Onboarding friction |
| Approval queue SLA (hours) | Trust + fraud control |
| % orders fulfilled without cancellation | Supply quality |
| GMV per active vendor (weekly) | Vendor ROI narrative |

---

## 7. Go-to-market for vendors

1. **Recruit 20–50 anchor vendors** in one vertical before consumer blast.
2. Onboarding: web catalog session (hand-holding), not “download app only.”
3. Commission and settlement terms documented before first live SKU.
4. WhatsApp business support line for vendor ops (Egypt norm).

---

## 8. Risks

| Risk | Mitigation |
|------|------------|
| Launch consumer demand before inventory | Soft launch; invite-only buyers or single category |
| Approve bad listings fast to inflate SKU count | Keep moderation gate; quality > quantity |
| Vendor uses personal WhatsApp to bypass platform | Accept for launch (doc 05); track off-platform leakage later |

---

## 9. Checklist

- [ ] Vendor web MVP scope signed with dev (4 modules above)
- [ ] Admin approval queue live (tool or branded UI)
- [ ] Server-side `vendorId` enforcement audited
- [ ] Anchor vendor cohort recruited
- [ ] Mobile vendor menu points to web for catalog management
- [ ] EP-11 moderation enforced (no live listing without approve)
