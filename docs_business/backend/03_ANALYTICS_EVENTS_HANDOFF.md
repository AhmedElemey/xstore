# xStore — Analytics Events Backend Handoff

**Status:** client-side implemented and shipping (mobile app), backend endpoint **not yet built**.
**Companion:** business rationale and the approved event schema/funnel are in
[`../launch_todos/03_funnel_metrics.md`](../launch_todos/03_funnel_metrics.md) — this doc is
the wire contract for the backend team to implement against. Once the collector endpoint is
live, this feeds the Analytics tab stubbed in
[`../admin-dashboard/BACKEND_HANDOFF.md`](../admin-dashboard/BACKEND_HANDOFF.md) instead of
hardcoded demo data.

## Why a custom endpoint instead of Firebase Analytics only

`03_funnel_metrics.md` originally scoped Phase A as Firebase Analytics client-side events with
a spreadsheet/Metabase view on the orders DB. That's still fine as a parallel/backup signal, but
the product decision (2026-08-06) is to also collect the same events into xStore's own backend
so the **admin dashboard** can show funnel/journey analytics directly — Firebase's console isn't
wired into `XStoreAdminDashboard`. This doc covers the custom pipeline; nothing here removes the
option to also enable Firebase Analytics later.

## Client behavior (already built)

`lib/core/analytics/analytics_service.dart` batches events locally (SharedPreferences-backed
queue, cap 500, drop-oldest) and flushes batches of up to 20 every ~20s, on connectivity
regained, or immediately once 20 events queue up. Until this endpoint exists, POSTs get a 404
(tolerated — same pattern as every other undeployed route in this app, see
`lib/core/network/legacy_route_options.dart`) and the client backs off exponentially (10s → 300s
cap) instead of hammering the route. No app-side changes needed when the backend ships this —
the queue just starts draining.

## Endpoint

```
POST /api/analytics/events
```

**Auth:** same as every other route in this app — static Basic license key in the
`Authorization` header (`ApiAuthHeaders.basicLicenseKey`), **not** a per-user JWT. Events fire
for guests too, so there is no user-scoped auth gate on this route; identity travels inside the
payload (`userId`, nullable).

**Request body:**

```json
{
  "events": [
    {
      "eventId": "5c1b2e2a-....-....-....-............",
      "name": "view_item",
      "occurredAt": "2026-08-06T10:15:30.000Z",
      "sessionId": "9e2f....",
      "deviceId": "3a7c....",
      "userId": "u_123",
      "userRole": "consumer",
      "screenName": "/product/123",
      "platform": "android",
      "properties": {
        "item_id": "p_456",
        "category": "Phones & tablets",
        "seller_id": "v_123",
        "price_egp": 48999,
        "guest": false
      }
    }
  ]
}
```

- `eventId` — client-generated UUIDv4. **Idempotency key** — dedupe on this (batches can be
  retried after a timeout even if the first attempt actually landed).
- `userId` / `userRole` — null for guests. `userRole` is one of `consumer` | `vendor` | `courier`.
- `screenName` — the go_router path active when the event fired (auto-tracked; not necessarily
  where the event's *action* happened, just app context).
- `properties` — flat JSON map, event-specific. Values are JSON primitives only (string / number
  / bool / null) — never nested objects/arrays.

**Response:** `202 Accepted` (or `200 { "accepted": <int> }`). Any 2xx is treated as "batch
delivered, drop it from the local queue." Do not return a partial-failure shape — if any event in
the batch is malformed, either accept the whole batch (log the bad row backend-side) or reject
the whole batch with a non-2xx (client will retry all of it, `eventId` dedupe absorbs the
resend).

**Storage:** append-only event log — `eventId, name, occurredAt, sessionId, deviceId, userId,
userRole, screenName, platform, properties (jsonb)`. No aggregation required yet; that's for the
dashboard's Analytics tab to compute (funnel counts, view→cart→checkout→purchase rates, guest
vs logged-in split — see `03_funnel_metrics.md` §4 for the exact rates to expose there).

## Event catalog (names are frozen — see `event_names.dart`, do not rename without updating both sides)

| Event | Fired when | Key `properties` |
|---|---|---|
| `view_item` | Product detail screen loads | `item_id`, `category`, `seller_id`, `price_egp`, `guest` |
| `add_to_cart` | Add-to-cart succeeds | `item_id`, `quantity`, `cart_value_egp` |
| `begin_checkout` | Checkout screen mounts | `cart_value_egp`, `item_count`, `vendor_count` |
| `checkout_payment_method_selected` | Payment method picked in checkout | `method` |
| `purchase` | Order placed (COD) | `order_id`, `value_egp`, `currency`, `payment_type`, `item_count` |
| `login_success` | Login/OTP/Google/Apple/Facebook succeeds | `method` (`password`\|`otp`\|`google`\|`apple`\|`facebook`), `role` |
| `register_success` | New account created | `method`, `role` |
| `logout` | User signs out | `role` |
| `login_prompt_shown` | Guest hits an account-gated action | (none — `screenName` gives context) |
| `screen_view` | Every go_router navigation | `screen_name` |
| `search_performed` | Explore search returns results (non-empty query) | `query`, `result_count` |
| `wishlist_add` / `wishlist_remove` | Wishlist toggle | `item_id` |
| `listing_published` | Vendor's new listing is created | `item_id`, `category`, `price_egp` |
| `listing_status_changed` | Vendor pauses/resumes a listing | `item_id`, `status` (`paused`\|`active`) |
| `listing_resubmitted` | Vendor resubmits a rejected listing | `item_id`, `price_egp` |
| `listing_deleted` | Vendor deletes/cancels a listing | `item_id` |
| `order_status_changed` | Any order lifecycle transition (either role) | `order_id`, `status` (`confirmed`\|`processing`\|`shipped`\|`delivered`\|`cancelled`), `role` (`vendor`\|`consumer`), `method` (delivery method, confirm only), `reason` (reject/cancel only) |

## Open question for whoever implements this

Confirm whether `properties` should be a typed/validated schema per `name` (stricter, more
backend work) or accepted as opaque `jsonb` (simpler, matches how the client already treats it,
recommended for v1 — validation can be added once the dashboard's actual query patterns are
known). Reply on this doc or the handoff thread if a stricter shape is wanted before v1 ships.
