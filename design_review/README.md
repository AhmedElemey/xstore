# xStore — Design Review

This package is a designer-ready visual review of the xStore Flutter marketplace app (Egypt, EGP, roles: consumer / vendor / courier). It contains 44 screenshots across 5 modules, plus `index.html`, a browsable review page.

**How to view:** open `index.html` in any browser. It's self-contained (inline CSS, relative image paths) — it works straight from the unzipped folder, no server needed.

## How it was captured

- Dev build (`main_dev.dart`), running with mock data (no live backend).
- Web renderer, simulating a 390×844 logical viewport at 2x pixel density (standard iPhone-class phone size).
- Captured 2026-07-18.

## Module map

| Folder | Role / area | Screens |
| --- | --- | --- |
| `01-auth` | Onboarding, login, registration, courier sign-in | 9 |
| `02-guest` | Unauthenticated browsing — home, explore, product, seller, static pages | 7 |
| `03-consumer` | Signed-in buyer — shopping, cart, checkout, orders, account | 16 |
| `04-vendor` | Seller — listings, orders, earnings, analytics, store settings | 9 |
| `05-courier` | Delivery role — assigned deliveries, cash collection, profile | 3 |

**Total: 44 screens.**

## Known issues to review

These are already tracked, not new findings — flagging them here so they're visible before the visual review starts:

1. **Vendor — Incoming Orders.** Order list renders empty due to a layout crash (infinite-height constraint). Header stats render but no order cards appear.
2. **Vendor — My Listings (empty state).** The floating "+ New Listing" button overlaps and clips the "Add Your First Listing" CTA.
3. **Mock data market mismatch.** Some screens show Algerian cities/addresses/names (Algiers, Constantine, "12 Rue Didouche Mourad") in an Egypt-market app; vendor profile even reads "Algiers, Egypt."
4. **Consumer — Order Detail.** A delivered order shows a "Processing — Pending" step between two already-completed timeline steps.
5. **Notifications — empty state copy.** Reads "Your all notifications will appear here" (grammar).
6. **Vendor — bottom navigation.** Tab label truncates to "Incoming Ord…" at 390px width.
7. **Order Detail — footer overlap.** "Cancel Order" footer button slightly overlaps scroll content.
