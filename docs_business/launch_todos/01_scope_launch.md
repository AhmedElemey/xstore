# Business brief: Lock launch scope (COD marketplace vs pilots)

**To-do ID:** `scope-launch`  
**Priority:** P0 — launch narrative  
**Audience:** Product owner, marketing, mobile + backend leads

---

## 1. Executive summary

xStore ships **three experiences in one mobile app**: a **consumer/vendor marketplace** (COD checkout), a **“send package”** consumer pilot, and a **courier** role with COD cash wallet. For launch, the business must **name one hero product** (marketplace) and **label or hide** logistics pilots so users, vendors, and investors understand what xStore is on day one.

**Recommendation:** Public positioning = **“Buy and sell in Egypt with cash on delivery.”** Package send and courier flows = **beta / xStore Delivery** until GMV and ops justify a second brand.

---

## 2. Problem statement

| Risk | Impact |
|------|--------|
| Mixed messaging (shop + courier + P2P shipping) | Lower conversion; confused SEO and app-store copy |
| Marketing spend on “delivery app” users who never buy | High CAC, weak retention |
| Vendors expect marketplace tools; consumers discover courier login | Support load, trust erosion |
| Operational complexity (COD settlement × 3 products) | Cash leakage before processes exist |

---

## 3. Current product state (mobile)

- **Consumer shell:** Home, Explore, Wishlist, Orders, Profile — browse, cart, checkout, orders ([`app_routes.dart`](../../lib/core/router/app_routes.dart)).
- **Vendor shell:** Home, Explore, Add listing, Incoming orders, Profile.
- **Courier shell:** Deliveries, Cash wallet, Profile — separate login ([`courierLogin`](../../lib/core/router/app_routes.dart)).
- **Consumer-only routes:** Send package, My packages ([`send_package_screen.dart`](../../lib/features/delivery/presentation/screens/send_package_screen.dart)).
- **Strategic alignment:** [`02_development_roadmap.md`](../02_development_roadmap.md) — **COD-only at launch**; payment gateway post-launch.

---

## 4. Scope decision framework

**In scope for v1.0 launch (marketplace):**

- Guest browse → login → cart → **COD checkout** → order tracking
- Vendor listings, incoming orders, store hours, profile/store on API
- Notifications inbox + device token registration
- WhatsApp contact (see doc 05)

**Pilot / beta (explicitly labeled):**

- Send package (consumer)
- Courier app surfaces (platform drivers only; not marketed to general public)

**Out of scope for launch narrative (may exist in app but not marketed):**

- In-app chat, card payments, guest checkout (per roadmap Phase 4)

---

## 5. Recommended actions

### Product & UX

1. **App Store / Play Store** title and subtitle: marketplace + COD; no “courier” in primary line.
2. **Profile / menu:** Move “Send package” under a **Beta** section with one-line explanation (admin-priced, COD at pickup).
3. **Onboarding:** Three slides stay shop / store / trust — do not introduce courier narrative on first run.
4. **Internal:** Courier login remains a **hidden/deep link** or separate build flavor if ops team needs it before public courier hiring.

### Marketing

1. One landing message: categories, trusted sellers, **pay when you receive**.
2. Launch geography: **one governorate or category vertical** (e.g. fashion, home) to prove loop.
3. Do not run paid ads for package-send until marketplace repeat rate is measured.

### Legal & ops

1. Terms/Privacy must describe **marketplace COD** first; add annex for beta delivery if kept live.
2. Support playbook: “Is xStore Uber for packages?” → “No; main app is shopping. Delivery beta is separate.”

---

## 6. Success metrics

| Metric | Target (first 90 days post-launch) |
|--------|-------------------------------------|
| Orders placed (COD) | Primary KPI |
| % sessions touching send-package | < 5% of consumer sessions (unless deliberate pivot) |
| App store reviews mentioning “confused purpose” | Trend down week over week |
| Vendor signups citing “sell online” | > 80% of vendor intake survey |

---

## 7. Dependencies & owners

| Dependency | Owner |
|------------|--------|
| Copy (AR/EN) for beta labels | Product + localization |
| Store listing assets | Marketing |
| Hide/relabel routes | Mobile |
| Courier workforce plan | Operations (separate from marketplace GTM) |

---

## 8. Risks if not done

- Launch looks “unfinished multi-product” instead of focused marketplace.
- COD settlement and support trained on wrong user stories.
- Competitors with clear “Souq for X” positioning win mindshare.

---

## 9. Checklist

- [ ] Written one-sentence launch positioning approved by owner
- [ ] Store listings updated (AR + EN)
- [ ] Send package + courier labeled beta or removed from consumer marketing surfaces
- [ ] Sales/support script aligned
- [ ] Launch campaign assets reviewed against scope doc
