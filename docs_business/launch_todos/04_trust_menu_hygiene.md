# Business brief: Profile menu trust (Coming Soon hygiene)

**To-do ID:** `trust-menu-hygiene`  
**Priority:** P0 — trust  
**Audience:** Product owner, mobile, UX

---

## 1. Executive summary

Several **high-visibility profile menu items** route to [`ComingSoonScreen`](../../lib/shared/screens/coming_soon_screen.dart) in [`app_router.dart`](../../lib/core/router/app_router.dart): Settings, Analytics, My orders placeholder paths, Earnings, Recently viewed, My reviews, Change password, Chat seller.

For **vendors**, Analytics and Earnings are especially damaging — they signal “platform not ready for business.”

**Recommendation:** **Remove, hide, or replace** each dead end with an **honest state** (web link, “available soon” with date, or working feature) before public launch.

---

## 2. Problem statement

| User perception | Result |
|-----------------|--------|
| “Everything is fake” | Abandon registration |
| Vendor expects earnings | Churn to Instagram/Facebook selling |
| Consumer taps My reviews | Lower trust in order history that *does* work |
| Investor/stakeholder demo | Embarrassment at Coming Soon screens |

Trust is disproportionately affected by **menu items users tap**, not by features they never discover.

---

## 3. Inventory of affected routes (mobile)

| Route / menu | Current behavior | User role |
|--------------|------------------|-----------|
| `/analytics` | Coming Soon | Vendor |
| `/earnings` | Coming Soon | Vendor |
| `/recently-viewed` | Coming Soon | Consumer |
| `/my-reviews` | Coming Soon | Consumer |
| `/change-password` | Coming Soon | All (password change may exist elsewhere) |
| Chat seller | Coming Soon | Consumer |
| `/settings` | Coming Soon | Generic |
| Some placeholders | Coming Soon | Various |

**Working nearby features (keep visible):** Orders, wishlist, profile edit, notifications, notification settings, store hours (vendor), incoming orders (vendor).

---

## 4. Decision matrix per item

Use one of four treatments:

| Code | Treatment | When to use |
|------|-----------|-------------|
| **A** | **Ship MVP** | Small effort, high trust (e.g. recently viewed local-only) |
| **B** | **Link out** | Web dashboard owns it (vendor analytics/earnings) |
| **C** | **Hide** | Not launch-critical; add back when ready |
| **D** | **Honest empty state** | Feature planned with quarter label, no fake UI |

Suggested mapping:

| Item | Rec |
|------|-----|
| Vendor Analytics | **B** → web dashboard or “Reports coming Q…” |
| Vendor Earnings | **B** → web or commission wallet screen if API ready |
| Recently viewed | **A** or **C** |
| My reviews | **D** until reviews API (Phase 3 roadmap) |
| Change password | **A** — wire to existing API if live |
| Chat seller | **C** — replace with WhatsApp (doc 05) |
| Settings | **A** — merge notification settings + theme/language already in profile |

---

## 5. Notification toggles trust gap

[`notification_settings_screen.dart`](../../lib/features/notifications/presentation/screens/notification_settings_screen.dart) stores push/email prefs in **SharedPreferences only** — not synced to backend.

**Business risk:** User disables push in app; marketing still sends; user feels spammed.

**Actions:**

- Short term: Label as “On this device only” until API exists.
- Medium term: Sync preferences to backend or respect FCM topic unsubscribe.

---

## 6. UX copy principles (AR + EN)

- Never show generic “Coming soon” without **what** and **when**.
- Prefer **“Manage on web”** with URL for vendors.
- Use [`AppLocalizations`](../../lib/core/localization/app_localizations.dart) — no hardcoded English-only trust strings.

---

## 7. Success metrics

| Metric | Target |
|--------|--------|
| Profile menu taps → Coming Soon | **0** at launch |
| Vendor support tickets “where is analytics?” | Down after web link |
| App store 1★ “fake app” keywords | Monitor |

---

## 8. Launch checklist

- [ ] Audit every `ComingSoonScreen` route in router
- [ ] Product sign-off matrix (A/B/C/D) per item
- [ ] Vendor menu shows web catalog/analytics path where applicable
- [ ] Notification settings disclaimer or backend sync plan
- [ ] QA script: tap every profile tile before store submission

---

## 9. Dependencies

- Doc 02 (vendor web) for link-out targets
- Doc 05 (WhatsApp replaces chat)
- Backend: change-password, reviews, earnings APIs per roadmap phase
