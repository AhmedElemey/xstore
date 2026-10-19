# xStore — Report Vendor Backend Handoff

**Status (2026-09-24):** client-side implemented; the backend route now exists (in the Postman
collection, and the hosted API answers 401 rather than 404 to an unauthenticated call). An
authenticated end-to-end submit has not been checked yet. See `10_REPORTS_BLOCK_STOCK_AUDIT.md`.
**Companion:** none yet — this is the only doc for this feature. Once the endpoint exists, an
admin-facing report list/queue (see "Open questions" below) would be the natural next companion
doc, similar to how `03_ANALYTICS_EVENTS_HANDOFF.md` feeds the admin dashboard's Analytics tab.

## What this is

A consumer who has placed an order with a vendor can report that vendor (fraud, poor quality,
item not as described, no response, harassment, or a free-text "other" reason) from the order's
detail screen in the mobile app. This is a moderation/trust-and-safety feature, not a review —
it does not affect the vendor's public rating and is not shown to other consumers.

## Client behavior (already built)

`lib/features/reports/` in the Flutter app (domain/data/presentation layers) is fully wired:
a "Report Vendor" button sits next to "Visit Store" on the order detail screen (consumer view
only), opens a sheet to pick a reason and an optional/required comment, and POSTs to the
endpoint below via `VendorReportsRemoteDataSourceImpl`. A failed POST shows a real error to the
user; there is no fake "queued for later" success state.

## Endpoint

```
POST /api/reports/vendor
```

**Auth:** Standard authenticated-user auth (same `X-Auth-Token` / Basic license header pattern
as every other authenticated write in this API). Any authenticated consumer may call this — it
is not a vendor-only or admin-only route. The reporter's own identity comes from the auth token,
**not** from the request body.

**Request body:**

```json
{
  "vendorId": 123,
  "orderId": 456,
  "reason": "Fraud",
  "comment": "Paid but item never shipped, no response after 2 weeks."
}
```

- `vendorId` — the reported vendor's user id.
- `orderId` — the order establishing the consumer-vendor relationship. **Must belong to both the
  calling consumer and the named vendor** — reject with 400/403 if the order doesn't exist, isn't
  this consumer's, or isn't with this vendor. This is the server-side enforcement of "only after
  a placed order" — the mobile app can only reach this action from a real order's own detail
  screen, but the server must not trust that.
- `reason` — one of exactly six string values (see catalog below). Reject anything else.
- `comment` — optional free text. **Required (non-empty) when `reason` is `"Other"`** — the
  client already enforces this, but validate server-side too.

**Response:** `201 Created` on success. Response body shape is up to the backend team — the
mobile client doesn't read anything back from it — but returning at least the created report's
id and timestamp is good practice for later debugging/support lookups.

**Validation errors:** follow whatever this API's existing error-response convention is (this
app's mapper currently expects an `errorEn`/`errorAr` pair on 4xx bodies, matching every other
endpoint — see `02_BACKEND_API_DOCUMENTATION.md` if that's still the live contract).

## Reason catalog (values are frozen — do not rename without updating the mobile client)

| Wire value | Shown to the user as | Notes |
|---|---|---|
| `Fraud` | Fraud or scam | |
| `PoorProductQuality` | Poor product quality | |
| `ItemNotAsDescribed` | Item not as described | |
| `NoResponseFromSeller` | No response from seller | |
| `Harassment` | Harassment or abuse | |
| `Other` | Other | `comment` is required for this one |

## Suggested data model

Not prescriptive — match this repo's existing conventions (naming, enum storage, migration
process) rather than the exact shape below. At minimum, persist:

- `id`
- `vendorId` (FK)
- `orderId` (FK)
- `consumerId` (the reporter, from the auth token — FK)
- `reason` (string or int enum, matching however similar enums are stored elsewhere, e.g. order
  status)
- `comment` (nullable)
- `createdAt`

A `status` field (e.g. `Pending` / `Reviewed` / `ActionTaken`) is worth adding if there's an
intent to build a moderation workflow, but is not required for the mobile app to work — don't
over-build this ahead of an actual admin UI needing it.

## Open questions for whoever implements this

1. **Admin visibility.** Right now there is no way for anyone to see submitted reports once
   they land in the database. At minimum this needs to be queryable directly (SQL/admin tooling)
   for support purposes. A proper `GET /api/admin/reports/vendor` (role-restricted like
   `SystemSettingsController`) is recommended but not required to unblock the mobile feature —
   flag if/when that's wanted so a companion handoff doc can be written the way
   `03_ANALYTICS_EVENTS_HANDOFF.md` feeds the admin dashboard.
2. **Repeat-report handling.** No dedupe/rate-limit is specified here — decide whether the same
   consumer reporting the same vendor+order twice should be allowed, merged, or rejected as a
   duplicate. The mobile client does not currently prevent a second report on the same order.
3. **Notification.** Whether submitting a report should trigger any internal alert (email/Slack
   to a moderation team) is out of scope for this doc — flag if wanted.
