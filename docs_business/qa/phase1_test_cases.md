# xStore Phase 1 — QA test cases

**Scope:** v1.0 launch marketplace (guest browse → login → cart → COD checkout → order tracking; vendor listings, incoming orders, store hours, commission wallet; notifications) plus the integrations added this cycle: `GET /api/home` aggregate, vendor orders API, FCM push, Universal/App Links, Google login, Amplitude + xStore analytics collector.
**Build under test:** `dev` + PR #49 (`claude/audit-bug-drift-fixes`).
**Last updated:** 2026-09-23

## How to read this

| Column | Meaning |
|---|---|
| **P** | P0 = launch blocker, P1 = must pass before release, P2 = should pass |
| **Auto** | The automated test that covers the case (`test/…`), or **Manual** when it needs a device, a live backend, or a platform service |
| **Status** | ✅ passes · 🐞 bug found in this pass (fixed in this PR unless noted) · ⚠️ open gap or product decision |

**Test matrix:** Android 10+ and iOS 15+ physical devices · EN and AR (RTL) · roles: guest, consumer, vendor (courier smoke only) · backend: dev API (live) and `--dart-define=MOCK=true` for UI-only runs.

**Test accounts:** seeded consumer, seeded vendor (admin-approved, with at least one Active listing), a second vendor for cross-account checks. Seed coordinates are `(25, 25)`, so Explore's nearby search is empty from Cairo and must fall back to the Home catalog (see EXP-03).

---

## 1. Launch, onboarding, guest mode

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| ONB-01 | P0 | First launch | Fresh install → open app | Splash (≥2.5 s) → location rationale once → onboarding slides (shop/store/trust only, no courier) | `onboarding_screen_live_flow_test.dart`, `splash_screen_live_flow_test.dart` | ✅ |
| ONB-02 | P0 | Returning signed-in user | Kill app with a session → reopen | Splash → role home (consumer Home, vendor Incoming Orders); onboarding never shown again | `splash_screen_live_flow_test.dart` | ✅ |
| ONB-03 | P1 | Continue as guest | Login → "Continue as Guest" | Home/Explore/product/seller browsable; guest flag survives restart | `require_login_test.dart`, `auth_redirect_and_providers_test.dart` | ✅ |
| ONB-04 | P0 | Guest hits an account action | As guest: add to cart / wishlist / checkout / Orders tab | Sign-in sheet (not a hard redirect); "Sign in" opens login; after login the user can continue the flow | `require_login_test.dart` (sheet) + Manual (continue after login) | ✅ |
| ONB-05 | P1 | Location permission denied | Deny location on the rationale | App works; delivery coordinates fall back to the chosen address / Cairo; no repeated prompt | `core/utils/app_location_cache_test.dart` | ✅ |
| ONB-06 | P2 | Offline launch | Airplane mode → open app | Offline banner; cached/static fallbacks, no crash or full-screen server error | `shared/widgets/offline_banner_test.dart` | ✅ |

## 2. Authentication

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| AUTH-01 | P0 | Consumer register (phone) | Register with name, phone, password, governorate/city → OTP | Account created; OTP screen; valid OTP lands on Home signed in | `register_screen_live_flow_test.dart`, `otp_screen_live_flow_test.dart` | ✅ |
| AUTH-02 | P0 | Vendor register | Register as vendor with store name (AR/EN), store category from `/api/storecategories` | Success overlay; vendor shell after approval | `register_screen_live_flow_test.dart`, `social_role_screen_live_flow_test.dart` | ✅ |
| AUTH-03 | P0 | Phone + password login | Valid credentials | Role home; FCM token registered (NOTIF-08) | `login_screen_live_flow_test.dart` | ✅ |
| AUTH-04 | P0 | Wrong password / unknown phone | Invalid credentials | Server message shown inline; stays on login; no crash | `login_screen_live_flow_test.dart` | ✅ |
| AUTH-05 | P1 | OTP wrong / expired / resend | Enter wrong OTP; wait 60 s; resend | Error message; resend disabled for 60 s countdown, then enabled | `otp_screen_live_flow_test.dart`, `forgot_password_otp_screen_live_flow_test.dart` | ✅ |
| AUTH-06 | P0 | Google login — existing account | Google sign-in with a registered email | Signed in; backend session persisted; `clientId` sent in the POST body | `social_login_fallback_test.dart` + Manual (`clientId`) | ✅ |
| AUTH-07 | P0 | Google login — no account | Google sign-in with an unregistered email | Routed to register (Google never creates an account itself) | `social_role_screen_live_flow_test.dart` | ✅ |
| AUTH-08 | P1 | Google account switch | Sign in with account A, log out, sign in again | Account picker shown again (sign-in is reset before each attempt) | Manual | ✅ |
| AUTH-09 | P1 | Apple / Facebook new user | Sign in as a new user | Role picker (buyer/seller) → registration | `social_role_screen_live_flow_test.dart` | ✅ |
| AUTH-10 | P0 | Forgot password | Phone → OTP → new password | Can log in with the new password only | `forgot_password_screen_live_flow_test.dart`, `reset_password_screen_live_flow_test.dart` | ✅ |
| AUTH-11 | P0 | Session expiry | Expire the access token on the server, then use the app | Silent refresh once; if refresh fails → login screen, local state cleared | `token_refresh_interceptor_test.dart` | ✅ |
| AUTH-12 | P0 | Logout | Profile → Logout | Login screen; local session cleared even if social sign-out throws; old account's data not visible to the next login; `logout` event sent before the token is revoked; FCM token unregistered | `social_login_fallback_test.dart`, `analytics_service_test.dart` + Manual (data isolation, FCM) | ✅ |
| AUTH-13 | P0 | Tokens never in logs | Debug build: log in with phone and with Google, watch logcat / Xcode console | `X-Auth-Token`, password, `idToken` redacted in request dumps; Google `idToken` shown only truncated + `aud` | `logging_interceptor_test.dart` | 🐞 fixed (full Google idToken was printed) |
| AUTH-14 | P1 | Role guards | Consumer opens `/vendor-orders`; vendor opens `/cart`, `/orders` | Redirected to own role home | `auth_redirect_and_providers_test.dart` | ✅ |
| AUTH-15 | P1 | Delete account | Profile → Delete account → confirm | Account removed; logged out; login with same credentials fails | `features/profile/data/datasources/profile_remote_datasource_delete_account_test.dart` (API call) + Manual | ✅ |

## 3. Home (`GET /api/home` aggregate)

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| HOME-01 | P0 | Home loads | Open Home (consumer or guest) | Banners, categories, hot deals, new arrivals, recommended render; skeleton only on first load | `home_screen_live_flow_test.dart` | ✅ |
| HOME-02 | P1 | One request per load | Proxy/Charles: open Home, scroll to the bottom | Exactly **one** `GET /api/home`; no `/api/banners` or `/api/listings` when the aggregate has data | `home_screen_live_flow_test.dart` | 🐞 fixed (was 3 requests) |
| HOME-03 | P1 | Pull to refresh | Pull down on Home | Exactly one more `GET /api/home`; all sections update | `home_screen_live_flow_test.dart` | ✅ |
| HOME-04 | P1 | Tab re-entry refresh | Home → another tab → Home | One `GET /api/home` refetch | `route_reentry_refresh_test.dart` | ✅ |
| HOME-05 | P1 | Aggregate empty / 500 | Server returns empty sections or 5xx for `/api/home` | Each section falls back to its own endpoint (`/api/banners`, `/api/listings`); no full-screen error | `features/home/data/repositories/home_repository_impl_test.dart` | ✅ |
| HOME-06 | P2 | Only Active listings | Seed a Draft/Pending listing | Never shown on Home | `features/home/data/datasources/home_remote_datasource_test.dart` | ✅ |
| HOME-07 | P1 | Banner tap | Tap a banner with / without `actionUrl` | Navigates / does nothing (no crash) | `features/home/presentation/widgets/hero_banner_carousel_test.dart` | ✅ |
| HOME-08 | P2 | Cart badge | Add items → back to Home | Cart icon count matches cart | `cart_screen_live_flow_test.dart` | ✅ |

## 4. Explore, search, product

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| EXP-01 | P0 | Keyword search | Search "earbuds" | Matching Active listings; `search_performed` tracked | `explore_screen_live_flow_test.dart` | ✅ |
| EXP-02 | P1 | Category from Home | Tap a Home category chip, then a second one | Explore filters by the tapped category each time; search bar updates | `explore_screen_route_category_test.dart` | ⚠️ one case already fails on `dev` (known) |
| EXP-03 | P0 | Nearby empty → catalog fallback | Device in Cairo against seed data at (25,25) | Explore shows the Home catalog instead of an empty tab | `explore_live_listings_test.dart` | ✅ |
| EXP-04 | P1 | Grid/list toggle, sort, filters | Toggle view; apply price/condition filters | Results update; state survives tab switch | `explore_screen_live_flow_test.dart` | ✅ |
| EXP-05 | P1 | Compare-at price | Listings with compare-at > price, = price, < price, none | Struck-through "was" price **only** when compare-at > price, in grid and list | `features/explore/presentation/widgets/product_card_compare_at_price_test.dart` | 🐞 fixed |
| EXP-06 | P1 | Error state | Search returns 5xx | Inline error with retry | `explore_error_state_test.dart` | ✅ |
| PRD-01 | P0 | Product detail | Open any listing | Photos, price in EGP, condition, seller, rating + review count, stock hint | `product_detail_screen_live_flow_test.dart` | ✅ |
| PRD-02 | P1 | `view_item` once | Open a product, post a review, come back | `view_item` tracked once per open, not on every refresh | `analytics_service_test.dart` | ✅ |
| PRD-03 | P0 | Add to cart from product | Sticky bar → Add to cart / Buy now | Cart updated; guest gets the login prompt | `product_sticky_bar_test.dart` | ✅ |
| PRD-04 | P1 | Seller / Visit store | Tap seller | Store page lists that seller's live listings | `vendor_store_screen_live_flow_test.dart`, `public_seller_stats_test.dart` | ✅ |
| PRD-05 | P1 | WhatsApp seller | Tap WhatsApp | Opens WhatsApp chat with the seller's number in `20…` format | `whatsapp_digits_test.dart` | ✅ |
| PRD-06 | P1 | Share | Share a product | Link uses the live website origin (`https://xstore.com/product/<id>`) | Manual | ✅ |
| REV-01 | P1 | Reviews list | Product → Reviews | Page 1 loads (1-based), author shows full name, not an email | `product_reviews_screen_live_flow_test.dart`, `review_author_label_test.dart` | ✅ |
| REV-02 | P1 | Review requires purchase | Try to review a product you never received | Not allowed | `product_reviews_screen_live_flow_test.dart` | ✅ |

## 5. Wishlist

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| WSH-01 | P0 | Add / remove | Heart on a card and on product detail | State in sync across screens; persists after restart | `wishlist_screen_live_flow_test.dart`, `features/wishlist/presentation/providers/wishlist_provider_test.dart` | ✅ |
| WSH-02 | P1 | Price dropped filter | Item whose price dropped since saved | Shown under "Price dropped"; count/sort agree with the card badge | `features/wishlist/presentation/providers/wishlist_provider_test.dart` | ✅ |
| WSH-03 | P2 | Sort | Each sort option | Order matches the option | `features/wishlist/presentation/widgets/wishlist_sort_row_test.dart` | ✅ |

## 6. Cart and COD checkout

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| CRT-01 | P0 | Cart totals | Add 2 items from 2 vendors, change quantities | Grouped by vendor; subtotal/shipping/total correct in EGP | `cart_totals_test.dart`, `features/cart/presentation/quantity_control_test.dart` | ✅ |
| CRT-02 | P1 | Quantity limits | Increase past stock; decrease to 0 | Capped at stock; 0 removes (with confirm) | `features/cart/presentation/quantity_control_test.dart` | ✅ |
| CHK-01 | P0 | Phone verification gate | Unverified phone → Checkout | Verification prompt first; checkout continues after verifying | `checkout_order_flow_test.dart` | ✅ |
| CHK-02 | P0 | Add delivery address | Add address via form and map pin | Saved; governorate/city cascade; reused next checkout | `checkout_add_address_sheet_test.dart`, `checkout_map_pin_address_test.dart`, `checkout_address_persistence_test.dart` | ✅ |
| CHK-03 | P0 | Place COD order | Checkout → review → Place order | One order per cart line (`POST /api/orders`); order-placed sheet; cart emptied; `purchase` tracked with `payment_type=cod` | `checkout_order_flow_test.dart`, `features/cart/data/datasources/cart_remote_datasource_test.dart` + Manual (Amplitude) | ✅ |
| CHK-04 | P0 | Partial failure | 2 lines, second line fails | First order kept, not re-placed on retry; failed line stays in the cart; partial-order dialog names how many failed | `features/cart/data/datasources/cart_remote_datasource_test.dart` | ✅ (test added — was untested) |
| CHK-05 | P0 | Delivery coordinates | Choose a map-pinned address different from device GPS | Order uses the pinned coordinates; a pin outside Egypt falls back to the device location | `features/cart/data/datasources/cart_remote_datasource_test.dart` | ✅ (test added — was untested) |
| CHK-06 | P1 | Double tap Place order | Tap Place order twice fast | One order per line | `checkout_order_flow_test.dart` | 🐞 fixed (no in-flight guard in the notifier; only the button's rebuild protected it) |

## 7. Consumer orders

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| ORD-01 | P0 | Orders list | Orders tab | All orders, newest first; filter tabs work; pull to refresh | `orders_screen_live_flow_test.dart` | ✅ |
| ORD-02 | P0 | Order detail / tracking | Open an order | Timeline, items, address, price breakdown; back returns to Orders even when opened via push | `order_detail_screen_live_flow_test.dart`, `order_detail_back_navigation_test.dart` | ✅ |
| ORD-03 | P0 | Cancel (pending/confirmed) | Cancel → pick reason → Confirm | Status Cancelled; the shared cancel dialog is identical on the card and the detail screen | `features/orders/presentation/providers/orders_provider_test.dart` | ✅ |
| ORD-04 | P1 | Cancel not offered later | Order Processing/Shipped | No cancel button | `orders_screen_live_flow_test.dart` | ✅ |
| ORD-05 | P1 | Cancelled order detail | Open a cancelled order | Detail loads (falls back to list data when `GET /orders/me/{id}` 404s) | `features/orders/data/datasources/orders_get_order_by_id_datasource_test.dart` | ✅ |
| ORD-06 | P0 | Leave a review | Delivered order → Leave a review → stars + comment → Submit | One POST; sheet closes; "Thanks" toast; product rating refreshes | `features/orders/presentation/widgets/order_review_sheet_test.dart` | 🐞 fixed (double tap posted twice) |
| ORD-07 | P1 | Review failure / already reviewed | Server 500; or listing already reviewed | Error toast, Submit re-enabled; "already reviewed" sheet with Edit | `features/orders/presentation/widgets/order_review_sheet_test.dart` (success path) + Manual | ✅ |
| ORD-08 | P1 | Report vendor | Order detail → Report | Submit disabled until a reason is picked ("Other" needs a comment); failure stays open with an inline error | `report_vendor_sheet_test.dart` | ✅ |
| ORD-09 | P2 | Reorder | Delivered order → Reorder | Items added to cart | `features/orders/presentation/providers/orders_provider_test.dart` | ✅ |

## 8. Vendor

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| VND-01 | P0 | Create listing | Add listing: title AR/EN, category, condition, price, 1–5 photos | Created (pending approval); photos compressed; draft cleared | `add_listing_screen_live_flow_test.dart`, `listing_create_multipart_test.dart` | ✅ |
| VND-02 | P0 | Photo cap | Try a 6th photo (camera, gallery, edit) | Blocked at 5 on every path | `listing_photo_paths_test.dart`, `features/listing/presentation/widgets/photo_upload_section_test.dart` | ✅ |
| VND-03 | P0 | Compare-at validation | Compare-at ≤ price | Field error "must be greater than price"; not submitted | `validators_test.dart` | ✅ |
| VND-04 | P1 | Edit / resubmit rejected listing | Edit a rejected listing | Pre-filled; resubmits | `listing_edit_hydration_test.dart`, `listing_resubmit_test.dart`, `add_listing_screen_edit_prefill_test.dart` | ✅ |
| VND-05 | P0 | Commission pause | Vendor over the pause threshold | Publishing blocked with the alert banner; warn banner above the warn threshold | `vendor_commission_alert_banner_test.dart`, `features/commission/presentation/providers/vendor_commission_wallet_provider_test.dart` | ✅ |
| VND-06 | P1 | Commission snapshot freshness | Proxy: edit profile name, save | No extra `GET /api/vendor/orders`; switching vendor refetches | `features/commission/presentation/providers/commission_config_provider_test.dart` | 🐞 fixed (refetched on every profile save) |
| VND-07 | P0 | Incoming orders list | Vendor → Incoming Orders | Pending first; counts (pending/active/revenue); one `GET /api/vendor/orders` per load | `vendor_orders_screen_live_flow_test.dart` | ✅ |
| VND-08 | P0 | Confirm with delivery method | Pending → Confirm → Self / Platform | Confirmed; list and profile pending badge update | `vendor_orders_screen_live_flow_test.dart`, `vendor_order_detail_screen_live_flow_test.dart` | ✅ |
| VND-09 | P0 | Reject with reason | Pending → Reject → preset reason | Cancelled with reason | `vendor_orders_screen_live_flow_test.dart` | ✅ |
| VND-10 | P0 | Processing → Shipped → Delivered | Advance an order through each step | Each status sent via `PUT /vendor/orders/status`; tracking info kept after refetch | `vendor_order_detail_screen_live_flow_test.dart`, `features/orders/presentation/providers/vendor_order_detail_provider_test.dart` | ✅ |
| VND-11 | P0 | Vendor opens order from push / link | Vendor taps an order push, or opens `https://xstore.com/order/<id>` | Vendor order detail (vendor sheets, list + badge update after actions) — not the consumer screen | `auth_redirect_and_providers_test.dart` | 🐞 fixed (opened the shared screen; list stayed stale) |
| VND-12 | P1 | Action failure on detail | Force 500 on confirm from the detail screen opened via push | Error toast on the detail screen; shown once | `features/orders/presentation/providers/vendor_order_detail_provider_test.dart` | 🐞 fixed (error was silently dropped) |
| VND-13 | P1 | Store hours | Set hours per day, closed days, invalid ranges | Saved; invalid ranges rejected | `store_hours_screen_live_flow_test.dart`, `store_hours_validator_test.dart` | ✅ |
| VND-14 | P1 | Store profile | Edit store name AR/EN, logo, banner, category | Saved; category saved by id; logo ≠ banner | `edit_profile_screen_live_flow_test.dart`, `features/profile/presentation/vendor_store_screen_test.dart` | ✅ |
| VND-15 | P1 | Wallet | Vendor Wallet tab | Commission per order, warn/pause flags; no invented balance figure | `vendor_wallet_screen_live_flow_test.dart` | ✅ |
| VND-16 | P2 | Reports | Vendor reports | Figures not capped by page size | `vendor_report_usecase_test.dart` | ✅ |

## 9. Notifications and FCM push (new)

Run on physical devices; iOS needs a real APNs token (simulators don't receive push).

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| NOTIF-01 | P0 | Inbox | Notifications screen | Paginated list, unread first/marked; mark read; badge count | `notifications_screen_live_flow_test.dart`, `features/notifications/notifications_paginated_response_test.dart` | ✅ |
| NOTIF-02 | P0 | Push while app foreground (Android) | Send an order push while the app is open | Local tray notification shown; inbox refreshes; `push_notification_received` tracked | Manual | ✅ |
| NOTIF-03 | P0 | Push while app foreground (iOS) | Same on iOS | System banner (no duplicate local notification) | Manual | ✅ |
| NOTIF-04 | P0 | Tap push, app in background | Background app → send push with `orderId` → tap | Opens `/order/<id>` (consumer) or vendor order detail (vendor); `push_notification_opened` tracked | `core/firebase/fcm_message_route_test.dart` + Manual | ✅ |
| NOTIF-05 | P0 | Tap push, app killed, signed in | Kill app → send push → tap | App cold-starts **straight to the order**, every time | `core/firebase/fcm_push_navigation_test.dart` + Manual | 🐞 fixed (route was lost when the session restored before the tap was read) |
| NOTIF-06 | P1 | Tap push while signed out | Log out → tap an older push | Login screen; after login the app opens the order | `core/firebase/fcm_push_navigation_test.dart` | ✅ |
| NOTIF-07 | P1 | Tap the foreground local notification (Android) | NOTIF-02, then tap the tray notification | Opens the route; `push_notification_opened` tracked | Manual | 🐞 fixed (tap was not tracked) |
| NOTIF-08 | P0 | Device token registration | Login; reinstall; token refresh; logout | Token registered after login; re-registered on refresh; unregistered on logout | `core/firebase/fcm_token_test.dart` (token fetch) + Manual (backend register/unregister) | ✅ |
| NOTIF-09 | P1 | Malicious `actionRoute` | Push with `actionRoute: https://evil.example` | Ignored (falls back to inbox), never opens a browser | `core/firebase/fcm_message_route_test.dart`, `core/firebase/fcm_push_navigation_test.dart` | ✅ |
| NOTIF-10 | P2 | Resume refresh | Background 1 min → push delivered without tray → resume | Inbox/badge refreshed on resume | Manual | ✅ |
| NOTIF-11 | P1 | Notification settings | Toggle notification preferences | Saved | `notification_settings_screen_live_flow_test.dart` | ✅ |

## 10. Deep links (new)

Test with `adb shell am start -a android.intent.action.VIEW -d <url>` and iOS Notes/Messages taps. Hosts: `xstore.com`, `www.xstore.com`.

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| DL-01 | P0 | Product link, signed in | Open `https://xstore.com/product/<id>` | Product detail; `deep_link_opened` tracked | `core/deeplink/deep_link_route_test.dart` + Manual | ✅ |
| DL-02 | P1 | Seller / category links | `/seller/<id>`, `/category/<name>` | Store page / Explore filtered by category | `core/deeplink/deep_link_route_test.dart` | ✅ |
| DL-03 | P1 | Product link, guest | Returning guest opens a product link | Product detail without login | `core/deeplink/deep_link_open_route_test.dart` + Manual | ✅ |
| DL-04 | P1 | Product link, first-time user | Fresh install (never guest, never signed in) → open a product link | App enters guest mode and opens the product (no login screen); guest mode persists; checkout/cart still ask for login | `core/deeplink/deep_link_open_route_test.dart` | 🐞 fixed (landed on login and lost the product; product decision: open as guest) |
| DL-05 | P0 | Order link | `/order/<id>` signed out, then log in | Login first, then the order (vendor: vendor order detail) | `auth_redirect_and_providers_test.dart`, `core/firebase/fcm_push_navigation_test.dart` | ✅ |
| DL-06 | P2 | Unknown link | `https://xstore.com/foo/bar`, other hosts | Ignored; app opens normally | `core/deeplink/deep_link_route_test.dart` | ✅ |

## 11. Analytics (Amplitude + xStore collector, new)

Verify in Amplitude (dev project, User Look-Up) and the backend collector table.

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| ANL-01 | P0 | Signed-in events reach Amplitude | Log in (short numeric user id) → browse | Events appear under the user id (no "Invalid id length") | `analytics_service_test.dart` | ✅ |
| ANL-02 | P0 | Guest events | Browse as guest | Amplitude receives them under the device id; collector keeps them queued until login | `analytics_service_test.dart` | ✅ |
| ANL-03 | P0 | Funnel events | Browse → product → cart → checkout → order | `screen_view` (with `referrer`), `view_item`, `add_to_cart`, `begin_checkout`, `purchase` (`payment_type=cod`) in order, once each | `analytics_service_test.dart` (screen_view/referrer, purchase revenue) + Manual (full funnel in Amplitude) | ✅ |
| ANL-04 | P0 | No PII in search | Search `010 1234 5678`, `+20 10-1234-5678`, `٠١٠١٢٣٤٥٦٧٨`, an email | Query sent as `[number]` / `[email]`; product words and short numbers kept | `features/explore/presentation/search_query_scrub_test.dart` | 🐞 fixed (spaced/dashed and Arabic-digit phones were sent unscrubbed) |
| ANL-04b | P0 | No free text in order events | Cancel/reject with a typed reason | `order_status_changed` carries no reason | Manual | ✅ |
| ANL-05 | P1 | Account switch | Queue events as A, log out, log in as B | A's events never sent under B's token | `analytics_service_test.dart` | ✅ |
| ANL-06 | P1 | Collector outage | Collector returns 5xx / 401 | App UI unaffected (no server-error screen, no logout); events retried later; queue capped at 500 | Manual (collector batching/200 behaviour is in `analytics_service_test.dart`) | ⚠️ outage path has no automated test |
| ANL-07 | P1 | Push/deep link events | NOTIF-04/05/07, DL-01 | `push_notification_opened` / `deep_link_opened` with `screen_name` | Manual | 🐞 fixed (NOTIF-07 tap missing) |

## 12. Localization, accessibility, resilience

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| L10N-01 | P0 | Arabic RTL | Switch to Arabic | All screens mirrored; Cairo font; no English leftovers in dialogs/sheets | Manual | ✅ |
| L10N-02 | P1 | Plurals and currency | Counts 0/1/2/11 in AR and EN; prices | ICU plurals correct; EGP formatting | `features/shared/currency_format_test.dart` (currency) + Manual (plurals) | ✅ |
| A11Y-01 | P2 | Large text | System text scale 1.3–2.0 | No overflow on cards, sheets, checkout | Manual | ✅ |
| RES-01 | P1 | 5xx on user action | Force 500 on add-to-cart / cancel / confirm | Error toast; state rolled back; no stuck spinner | `features/orders/presentation/providers/orders_provider_test.dart`, `auth_redirect_and_providers_test.dart` | ✅ |
| RES-02 | P1 | Slow network | Throttle to 3G | Loading states; no duplicate submissions | Manual | ✅ |

## 13. Beta surfaces (smoke only)

| ID | P | Scenario | Steps | Expected | Auto | Status |
|---|---|---|---|---|---|---|
| BETA-01 | P2 | Send package | Consumer → Send package | Form submits; listed under My packages; labeled beta | `send_package_screen_live_flow_test.dart`, `my_package_requests_screen_live_flow_test.dart` | ✅ |
| BETA-02 | P2 | Courier | Courier login → deliveries → collect cash | Flows work; not reachable from consumer marketing surfaces | `courier_delivery_flow_test.dart`, `courier_cash_screen_live_flow_test.dart` | ✅ |

---

## Findings from this pass

Found by walking every case against the code and the test suite. Each automated citation above was checked (grep + test names); several originally assumed covered were not, and are now either tested or marked Manual.

| # | Case | Severity | Finding | Resolution |
|---|---|---|---|---|
| 1 | NOTIF-05 | P0 | Cold-start push tap for a signed-in user could land on Home: the tap was staged and only flushed on the *next* sign-in, so when the session restore finished before `getInitialMessage()`, the route was lost. | Fixed: cold-start taps use the same path as warm taps (wait for the restore, then open or stage behind login). `core/firebase/fcm_push_navigation_test.dart`. |
| 2 | ANL-04 | P0 (privacy) | Search analytics scrubbed only 7+ consecutive ASCII digits. Phones typed with spaces/dashes or in Arabic-Indic digits reached Amplitude. | Fixed `scrubSearchQueryForAnalytics`; `features/explore/presentation/search_query_scrub_test.dart`. |
| 3 | CHK-06 | P1 | `Checkout.placeOrder` had no in-flight guard; only the button's rebuild prevented a second set of orders (no idempotency key on `POST /api/orders`). | Fixed with an `isPlacingOrder` guard; `checkout_order_flow_test.dart`. |
| 4 | NOTIF-07 / ANL-07 | P1 | Tapping the local notification raised for a foreground push did not send `push_notification_opened`, contrary to the analytics handoff. | Fixed in `fcm_push_handling_provider.dart`; Manual verification (needs FirebaseMessaging). |
| 5 | CHK-04, CHK-05 | P0 (coverage) | Partial-failure checkout and pinned-address coordinates were correct in code but had no tests. | Tests added in `features/cart/data/datasources/cart_remote_datasource_test.dart`. |
| 6 | DL-04 | P1 | A first-time user who opened a shared product link landed on login and lost the product. While fixing it: `GuestMode`'s initial prefs load could overwrite a concurrent `enable()` with the stale saved `false`. | Product decision: open as guest. `openDeepLinkRoute` enables guest mode for signed-out users on guest-browsable links; `GuestMode` ignores the initial load once set explicitly. `core/deeplink/deep_link_open_route_test.dart`. |
| 7 | ANL-06 | P2 | Collector 5xx/401 back-off and the 500-event queue cap have no automated test. | ⚠️ Open; Manual for now. |
| 8 | EXP-02 | P2 | `explore_screen_route_category_test.dart` "second category tap" fails on `dev` in the full run. | Known pre-existing failure. |
| 9 | — | P2 | `profile_screen_test.dart` (6 tests) fail on `dev` with a pending Timer. | Known pre-existing failure. |
| 10 | HOME-02, VND-06, VND-11, VND-12, ORD-06, EXP-05, AUTH-13 | P0–P1 | Audit findings. | Fixed earlier in PR #49. |

**Manual-only gaps worth automating next:** NOTIF-02/03/07 need a fake for `FirebaseMessaging` streams and `flutter_local_notifications`; DL-01/03 still need an `AppLinks` stream fake for the stream wiring itself (the routing logic is now tested via `openDeepLinkRoute`). Each is one small seam (inject the stream into the provider).
