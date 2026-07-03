# xStore — Development Roadmap (Backend + Mobile)

**Audience:** Backend dev (agency), Mobile dev.
**Framing:** Two parallel tracks, three phases. No fixed dates — **⚠️ give me a launch date and I'll turn these into weeks.** Complexity is S/M/L. The whole point of this doc is the **"backend must ship X before mobile can do Y"** dependency callouts, because that's where a 1–3 month launch actually slips.

**Owner's bottom line:** the critical path is the backend catching up to what the app already does against mock data. The app is ahead; the API doesn't exist yet. Everything below sequences to unblock mobile as early as possible and to close the two things that are **legal/trust liabilities** (real payments, Terms/Privacy) before any public release.

---

## Guiding priorities (how I ranked this)

1. **Launch blockers first** (real backend, real payments, legal pages) — no revenue and real liability without them.
2. **Trust/consistency next** (Egypt-only cleanup, product moderation).
3. **Optimizations last** (guest checkout, real push, analytics depth).

Feature requests get measured against this. If it doesn't beat a P0, it waits.

---

## PHASE 1 — Foundation: Auth + Catalog live (kill MOCK for browse/list)

**Goal:** a real user can log in and browse a real catalog. Gets us off `MOCK=true` for the top of the funnel.

### Backend track — Phase 1
| Task | Cx | Unblocks mobile | Depends on |
|---|---|---|---|
| Auth API: register/login/OTP, issue Bearer token, 401 semantics | M | Everything (global interceptor already reads token) | — |
| **Product CRUD API** (EP-1…EP-8 from Deliverable 1) with `vendorId` on model | L | Catalog, detail, vendor "my listings" | Auth |
| **Image upload** (EP-9, multipart or presigned) | M | Create/edit product with real images | Storage bucket |
| **Categories API** (EP-10) to replace hardcoded client taxonomy | S | Server-driven categories | — |
| Seed real data + migrate mock users/listings to DB | S | Realistic QA | Product API |

### Mobile track — Phase 1
| Task | Cx | Notes |
|---|---|---|
| Flip `MOCK=false` per module via `--dart-define=MOCK` (already wired in `MockConfig`) | S | Do it module-by-module, not big-bang |
| **Add release-mode guard to `mock_config.dart`** (force `useMock=false` in `kReleaseMode`) | S | **P0 safety** — today a release build defaults to mock data if the define is missed |
| Point catalog/detail/my-listings at live EP-1…EP-8 | M | Parsers already tolerate JSON; **tighten to canonical keys** as backend firms up |
| Replace local-file-path images with upload flow (EP-9) | M | Removes the "images never upload" gap |
| **Egypt-only cleanup** (see §Cleanup below) | S | Independent of backend — do it now while blocked |
| **Terms of Service + Privacy Policy screens** (currently stubs) | S | Static content; I'll supply copy. Independent of backend |

> **🔗 Dependency callouts (Phase 1)**
> - Backend **Product CRUD (EP-2/3/6)** must ship before mobile can leave MOCK for catalog/detail/listings.
> - Backend **Image upload (EP-9)** must ship before mobile create/edit is real.
> - **Egypt cleanup + Terms/Privacy have NO backend dependency** — mobile does these in parallel from day one. Don't let them wait.

---

## PHASE 2 — Commerce: Cart, Checkout, Payments (the money path)

**Goal:** a real order can be placed and paid. This is the revenue-critical phase and contains the biggest liability (UI-only payments today).

### Backend track — Phase 2
| Task | Cx | Unblocks mobile | Depends on |
|---|---|---|---|
| Cart API (9 endpoints already documented in `cart_module_api_docs.json`) | M | Real multi-vendor cart, coupons | Product API |
| **Checkout re-pricing + stock re-validation** at order time (edge cases 2–5, Del.1) | M | Safe checkout, "price changed" prompt | Cart, Product |
| **Payment gateway integration** — Paymob or Fawry (Egypt) + **COD** | L | Real payment; removes PCI liability | Legal/merchant account |
| Coupon/discount engine (backend-validated, not client) | M | Trustworthy coupons | Cart |
| Address book API (currently a stub) | S | Real saved addresses at checkout | Auth |

### Mobile track — Phase 2
| Task | Cx | Notes |
|---|---|---|
| Wire cart/checkout to live cart API | M | Multi-vendor grouping UI already built |
| **Remove raw card fields (number/expiry/CVV) from checkout** | S | **P0 liability fix, do immediately.** COD-only launch ⇒ no processor, so card capture is pure liability. Reduce checkout to **COD only**; hide/disable card + wallet methods |
| "Stock changed at checkout" confirm UX | S | Consumes backend re-validation response (no re-pricing needed for COD, but confirm stock) |
| Address book screen (real) | S | Replaces stub |

> **🔗 Dependency callouts (Phase 2)**
> - Backend **Cart API** before mobile cart leaves MOCK.
> - **No payment gateway on the launch critical path** — see decision below. This removes the biggest launch-staller.

**✅ DECISION (locked) — Payments at launch: COD only.** The payment gateway (Ahmed to own) moves to a **post-launch phase** (see Phase 4 below). Consequence: checkout is COD-only at launch, card/wallet methods hidden, and raw card fields removed from the UI now. No PCI exposure, no gateway dependency blocking go-live.

---

## PHASE 3 — Orders, Notifications, Analytics, Polish

**Goal:** full order lifecycle, real notifications, and the data you need to run the business. Launch-completing, then post-launch optimization.

### Backend track — Phase 3
| Task | Cx | Unblocks mobile | Depends on |
|---|---|---|---|
| Orders API (11 endpoints documented in `orders_module_api_docs.json`): confirm/ship/deliver lifecycle | M | Real order tracking both roles | Checkout |
| **Push notifications** backend (FCM) — replace mock-only notifications | M | Real push | Firebase (`firebase.json` present) |
| Vendor moderation + status API (EP-11) | S | Admin approval flow | Product API |
| Analytics events + aggregation (sales, views, conversion) | M | Dashboard metrics (Del.3) | Orders |
| Reviews write API | S | Customers post reviews | Orders |

### Mobile track — Phase 3
| Task | Cx | Notes |
|---|---|---|
| Wire orders screens to live orders API | M | Lifecycle UI already built |
| **Integrate real push SDK** (FCM), replace mock notifications | M | Firebase config already in repo |
| Chat (currently "coming soon") | L | **⚠️ Defer.** Cheap launch substitute: vendor profiles already carry a `whatsappNumber` field — deep-link buyer→vendor to WhatsApp (S effort) instead of building in-app chat |
| Reviews submission UI | S | |
| Final QA pass with `MOCK=false` everywhere | M | Verification gate before store submission |

> **🔗 Dependency callouts (Phase 3)**
> - Backend **Orders API** before mobile order tracking is real.
> - Backend **FCM setup** before mobile push works (Firebase already in `firebase.json`).
> - **Chat and deep analytics are the scope-creep risk zone.** They don't block launch. Park them.

---

## PHASE 4 (post-launch) — Payment gateway + optimizations

**Goal:** add online payment once the marketplace is live and transacting on COD. **Owner:** Ahmed.

| Task | Cx | Notes |
|---|---|---|
| Paymob/Fawry merchant onboarding (KYC) | — | **Start ~4–6 weeks before you want it live** — calendar lead time, not dev time |
| Gateway integration (backend): checkout re-pricing, webhooks, refunds | L | Re-pricing matters once money moves at authorization time |
| Mobile: re-enable card/wallet methods via gateway SDK/redirect | M | Replaces the removed raw card UI — **never re-add raw card capture** |
| Guest checkout (v1.1 experiment) | M | A/B against login-gated baseline |
| Wallets: Vodafone Cash / InstaPay | M | High adoption in Egypt; usually via the same gateway |

> **🔗 Callout:** because this is post-launch and you own it, it does **not** gate go-live. Just start KYC early — that's the only long-lead item.

---

## Egypt-only cleanup (concrete, grounded punch-list)

Independent of backend — schedule in Phase 1. These are actual leftovers found in the code:

| File | Issue |
|---|---|
| `lib/l10n/app_en.arb`, `app_ar.arb` | Key `currencyDzd` (value already "EGP"/"ج.م" but **key name is wrong**); `ordersCurrentLocationMock` = "In transit — Algiers hub"; `ordersPaymentCib` / `checkoutPayCibTitle` = "CIB Card"; `cartCouponMinOrder` = "Minimum order 5,000 **DZD**"; `couponDetailFree500` = "500 **DZD**"; `cartShippingPaid` = "+{amount} **DZD**"; `locationHintAlgiers` = "e.g. Algiers" |
| `lib/core/constants/app_strings.dart` | Same set duplicated as Dart constants (`currencyDzd`, `Algiers hub`, `CIB Card`, `DZD` shipping, `5,000 DZD`, `500 DZD`) |
| `lib/core/mock/mock_users.dart` | `location: 'Algiers, Egypt'`, `storeCity: 'Algiers'`, `'Oran, Egypt'` (nonsense mixed geography) |
| `lib/core/mock/mock_orders.dart` | Addresses "Rue Didouche Mourad, Algiers" / "Blvd de la Soummam, Oran"; `paymentMethod: 'CIB Card'` |
| `lib/core/mock/mock_listings.dart` | "seller can meet in Algiers", "locally only in Oran" |
| `lib/core/mock/mock_banners.dart` | "Free Shipping — orders above 2000 **DZD**" |
| `lib/core/mock/mock_notifications.dart` | Multiple **DZD** amounts, "login from Algiers", Algerian names, "ship to Oran" |
| `lib/features/orders/domain/entities/order_entity.dart` | **`PaymentMethod` enum = `cashOnDelivery, cibCard, dahabiCard, baridimob`** — three of four are **Algerian** brands (see payment note below) |
| `lib/l10n/*.arb` payment subtitles | `checkoutPayDahabiSubtitle` = "Egypt Post golden card" and `checkoutPayBaridiSubtitle` = "Egypt Post mobile payment" — **factually wrong: Dahabia & BaridiMob are Algérie Poste products.** Trust/regulatory risk, not just a string |
| `lib/core/constants/app_strings.dart`, `*.arb` | `checkoutWilaya` = "Wilaya", `storeWilayaLabel` = "Store Wilaya" — **Algerian term**; Egypt uses *governorate / muhafazah* (محافظة). Data file is already `egypt_wilayas.dart` |
| `lib/core/mock/mock_users.dart` | `storeWilaya: 'Alger'` (Algiers) |
| `lib/core/utils/formatters.dart` | `Formatters.dzdWhole()` + `dzdSavedDisplay()` — code-level DZD formatters (comment even says "Egyptn DZD") |

**Action:** rename `currencyDzd` → `currencyEgp` and `dzdWhole`/`dzdSavedDisplay` → EGP equivalents (and all refs), replace DZD → EGP everywhere, swap Algiers/Oran → Cairo/Giza/Alexandria, replace the "Wilaya" label with "Governorate", fix "Algiers, Egypt" geography. Low effort, high trust payoff — sloppy geography kills local credibility instantly.

> **🚩 Payment lineup is an Algeria leftover.** Three of the four `PaymentMethod` values (CIB, Dahabia, BaridiMob) are Algerian brands, two mislabeled "Egypt Post." **Launch decision: COD only** — so for launch, reduce the enum/UI to `cashOnDelivery` and remove the other three from checkout. The Egypt-appropriate online methods (cards + Vodafone Cash / InstaPay) come back in **Phase 4** with the gateway. Either way, the three Algerian values must go.

> **🚩 P0 safety — MOCK has no release guard.** `lib/core/mock/mock_config.dart` reads `bool.fromEnvironment('MOCK', defaultValue: true)` with **no `kReleaseMode` guard**. A release build that forgets `--dart-define=MOCK=false` ships **fake data to production**. Add a hard guard (force `useMock=false` in release, or fail the build) — see Phase 1 mobile track.

---

## Guest checkout — the decision, isolated

**✅ DECISION (locked): launch login-gated; guest checkout as a v1.1 experiment (Phase 4).** It's a genuine conversion lever but an *optimization*, not a launch blocker. Optional cheap win: ungating **browse** (not checkout) lets people window-shop without an account while still gating the purchase — consider if you want a funnel bump sooner.

---

## Phase-gate summary

| | Phase 1 | Phase 2 | Phase 3 |
|---|---|---|---|
| **Theme** | Catalog live | Money path | Lifecycle + polish |
| **Backend** | Auth, Product CRUD, uploads, categories | Cart, checkout re-pricing, **payments**, addresses | Orders, push, moderation, analytics |
| **Mobile** | MOCK off for browse, images, **Egypt cleanup + Terms/Privacy** | Cart/checkout live, **kill UI-only cards**, guest decision | Orders live, real push, QA gate |
| **Exit criteria** | Real user browses real catalog | Real paid order placed safely | Full lifecycle, no MOCK anywhere |
| **Liabilities closed** | Terms/Privacy live | **PCI risk gone (no raw cards)** | — |

**The three things I will not launch without:** working backend for catalog+orders, a real payment path (COD acceptable), and Terms/Privacy. Everything else is negotiable against the date you give me.
