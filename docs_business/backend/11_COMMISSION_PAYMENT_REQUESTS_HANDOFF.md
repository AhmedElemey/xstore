# Commission payment requests — backend handoff (PROPOSED, not yet built)

**Status:** the mobile app (`lib/features/commission/`) and the admin dashboard
(XStoreAdminDashboard `src/app/features/payments/`) are built against this contract. Until the
backend ships it, a vendor's submit shows a real error and the dashboard's Fee Payments page
shows "Payment requests aren't available yet."

## Why

Vendors owe platform fees (flat EGP per order, accrued in `VendorCommissionWallet.OutstandingEgp`).
Today the only way to reduce that balance is an admin calling
`POST /api/admin/vendors/{id}/commission/settle` after being paid off-app. This feature lets the
vendor report a payment from the app with proof, and lets an admin approve it in one click.

## Flow

1. Vendor opens **Wallet → Pay platform fees** and picks a method: InstaPay, Vodafone Cash,
   Orange Cash or Etisalat Cash.
2. The app shows where to send the money (read from a General Setting, see below). The vendor
   sends it outside the app.
3. The vendor enters the amount sent, attaches a screenshot/photo of the receipt and submits.
   → a **Pending** payment request.
4. An admin opens **Fee Payments** in the dashboard, checks the receipt and either:
   - **approves** it (optionally lowering the amount if the receipt shows less) → the approved
     amount is deducted from the vendor's outstanding balance, or
   - **rejects** it with a reason shown to the vendor. The balance is unchanged.

## Endpoints

### Vendor — `POST /api/vendor/commission-payments`

`[Authorize(Roles = "VENDOR")]` — the vendor id comes from the token, never the body.
`multipart/form-data`:

| Field | Type | Rules |
|---|---|---|
| `method` | string | `InstaPay` \| `VodafoneCash` \| `OrangeCash` \| `EtisalatCash` (PascalCase, like the other enums) |
| `amountEgp` | decimal | `> 0` (sent as an invariant-culture string, e.g. `"250.5"`) |
| `receiptImage` | file | required; JPEG/PNG/WebP; suggest max 5 MB. The app compresses to JPEG ≤ ~1600px before upload. |

→ `201` with the created row (shape below). `400` with `errorEn`/`errorAr` for validation
failures; the app shows `errorEn`/`errorAr` as-is.

Multiple pending requests per vendor are allowed (a vendor may pay in parts).

### Admin — `GET /api/admin/commission-payments`

`[Authorize(Roles = "ADMINISTRATOR, SUPERADMIN")]`

Query: `status` (`Pending`|`Approved`|`Rejected`, omit for all), `keyword` (store name),
`from`, `to` (created-at range, same format as the other admin lists), `page` (1-based),
`pageSize`. Newest first.

→ `{ items: CommissionPaymentDto[], totalCount, totalPages }`

```jsonc
CommissionPaymentDto {
  "id": 41,
  "vendorId": 7,
  "vendor": { "id": 7, "storeName": "Cairo Gadgets" },
  "method": "VodafoneCash",
  "amountEgp": 350.0,            // what the vendor claimed
  "approvedAmountEgp": null,     // set on approve
  "status": "Pending",           // Pending | Approved | Rejected
  "receiptImageUrl": "/uploads/commission-receipts/41.jpg",
  "rejectionReason": null,
  "createdAt": "2026-09-30T10:15:00Z",
  "reviewedAt": null,
  "reviewedBy": null             // admin user id
}
```

### Admin — `POST /api/admin/commission-payments/{id}/approve`

Body: `{ "amountEgp": 300.0 }` — `> 0`. The admin may lower it below the claimed amount; it's
worth rejecting a value above the claim.

In **one transaction**:
1. Require `status == Pending` (else `409`, so a double click can't deduct twice).
2. Subtract `amountEgp` from the vendor's `VendorCommissionWallet.OutstandingEgp`, floored at 0
   — the same effect as the existing settle endpoint.
3. Set `status = Approved`, `approvedAmountEgp`, `reviewedAt`, `reviewedBy`.

→ `200`/`204`. The vendor's `exceedsWarnThreshold`/`exceedsPauseThreshold` flags on
`GET /api/vendor/orders` must reflect the new balance (a paused vendor can publish again once
under the pause threshold).

### Admin — `POST /api/admin/commission-payments/{id}/reject`

Body: `{ "reason": "Receipt is unreadable" }` — required, non-blank. Requires `Pending`
(else `409`). Sets `status = Rejected`, `rejectionReason`, `reviewedAt`, `reviewedBy`. The
balance is unchanged.

### Notifications (recommended)

Send the vendor a push/in-app notification on approve ("Your payment of EGP 300 was approved")
and on reject (with the reason). The app has no request-history screen yet, so the notification
is how the vendor learns the outcome.

## Pay-to accounts (where vendors send the money)

Stored as a **General Setting** (the dashboard's System → General Settings page, see the
dashboard's `BACKEND_HANDOFF.md` "General Settings"), so numbers change without an app release:

- key: `commission_payment_accounts`
- dataType: `Json`
- value:

```json
{
  "InstaPay": "xstore@instapay",
  "VodafoneCash": "01000000000",
  "OrangeCash": "01200000000",
  "EtisalatCash": "01100000000"
}
```

The app reads it from the public, already-live `GET /api/general-settings?search=commission_payment_accounts`
and uses only the row whose `key` matches exactly (`search` is a substring match). It also accepts
the value bare, inside the `{data: ...}` envelope, inside a `{key, value}` row, and as either a
JSON string or an object. (An earlier draft named `GET /api/app-settings/{key}`; that route was
never built.) A method with no entry shows "account isn't set up yet — contact
support" instead of a number.

## Open questions for the backend

- Receipt storage path and retention (these are financial records — keep them).
- Should an approval above the vendor's current outstanding balance be allowed (credit), or
  capped at the balance? The contract above floors the balance at 0, so any excess is lost.
