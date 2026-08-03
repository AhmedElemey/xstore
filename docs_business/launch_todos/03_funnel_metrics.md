# Business brief: North-star funnel and instrumentation

**To-do ID:** `funnel-metrics`  
**Priority:** P0 — measurement  
**Audience:** Product owner, mobile, backend, marketing

---

## 1. Executive summary

You cannot optimize what you do not measure. For xStore launch, define **one north-star funnel** tied to revenue:

**Guest or signed-in user → Product viewed → Add to cart → Checkout started → COD order placed**

Everything else (courier, send package, wishlist saves) is **secondary** until this loop works at scale.

---

## 2. Why this funnel

| Stage | Business meaning |
|-------|------------------|
| Product viewed | Demand + discovery working |
| Add to cart | Intent; pricing/trust sufficient |
| Checkout started | Address/payment path engaged |
| Order placed (COD) | **GMV event** — commissionable |

Aligned with roadmap: **COD-only at launch** ([`02_development_roadmap.md`](../02_development_roadmap.md)); no gateway noise in primary metric.

---

## 3. Current app touchpoints (for event naming)

| Step | Screen / action | Code reference |
|------|-----------------|----------------|
| Browse | Home, Explore | [`home_screen.dart`](../../lib/features/home/presentation/screens/home_screen.dart) |
| Product view | Product detail | [`product_detail_screen.dart`](../../lib/features/product/presentation/screens/product_detail_screen.dart) |
| Add to cart | Product detail / cart | [`cart_provider.dart`](../../lib/features/cart/presentation/providers/cart_provider.dart) |
| Checkout | Multi-step checkout | [`checkout_screen.dart`](../../lib/features/cart/presentation/screens/checkout_screen.dart) |
| Order confirmed | Confirmation sheet | [`order_confirmation_sheet.dart`](../../lib/features/cart/presentation/widgets/order_confirmation_sheet.dart) |
| Guest gate | Login prompt on cart tab | [`require_login.dart`](../../lib/shared/utils/require_login.dart) |

---

## 4. Recommended event schema

Use consistent names in **Firebase Analytics** (client) and optionally mirror on backend at order create.

| Event name | Parameters (examples) |
|------------|------------------------|
| `view_item` | `item_id`, `category`, `seller_id`, `price_egp`, `guest` |
| `add_to_cart` | `item_id`, `quantity`, `cart_value_egp` |
| `begin_checkout` | `cart_value_egp`, `item_count`, `vendor_count` |
| `purchase` | `order_id`, `value_egp`, `currency=EGP`, `payment_type=cod` |
| `login_prompt_shown` | `source` (tab, wishlist, checkout) |
| `login_success` | `method` (password, otp, google) |

**Funnel dashboard (weekly review):**

1. View → cart rate  
2. Cart → checkout start rate  
3. Checkout start → purchase rate  
4. Overall view → purchase rate  
5. Split: guest vs logged-in  

---

## 5. Backend / business metrics (not only analytics)

| Metric | Source |
|--------|--------|
| GMV (EGP) | Orders API |
| Order count | Orders API |
| AOV | GMV / orders |
| Cancellation rate | Order status |
| COD delivered rate | Delivered / placed |
| Repeat purchase (30d) | User id + order dates |

---

## 6. Implementation phases

**Phase A (pre-launch, minimal):**

- Firebase Analytics events on the 4 funnel steps + purchase
- Owner dashboard: spreadsheet or Metabase on orders DB until admin analytics exists

**Phase B (launch + 30 days):**

- Uninstall monitoring, crash-free sessions
- Campaign UTM → first `view_item` (deep links)

**Phase C (post-launch):**

- Vendor-side funnel: listing live → first order
- Cohort by governorate / category

---

## 7. Governance

- **Single owner** reviews funnel every Monday (15 min).
- No more than **5 primary KPIs** in launch war room.
- Secondary metrics (wishlist, notifications open rate) reported monthly.

---

## 8. Privacy (Egypt / store policies)

- Document events in Privacy Policy ([`05_privacy_policy.md`](../05_privacy_policy.md) maintenance).
- No PII in analytics parameter values (hash phone if ever sent).
- Align with Firebase + Apple/Google data disclosure requirements.

---

## 9. Success criteria

| Milestone | Target |
|-----------|--------|
| Events firing in staging | 100% of funnel steps |
| Purchase event matches order DB | ± 1% reconciliation |
| First production week | Baseline funnel rates documented |
| Week 4 | One experiment run (e.g. OTP-first login) with before/after |

---

## 10. Checklist

- [ ] Event spec signed (names + params)
- [ ] Mobile implements Phase A events
- [ ] Backend order id on `purchase` event
- [ ] Weekly funnel template (Sheet/Notion)
- [ ] Marketing tags UTM convention documented
