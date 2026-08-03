# Business brief: Push notifications on order lifecycle

**To-do ID:** `push-lifecycle`  
**Priority:** P1 — retention & support cost  
**Audience:** Product owner, backend, mobile, operations

---

## 1. Executive summary

xStore already **registers FCM device tokens** with the backend after login ([`fcm_device_token_sync_provider.dart`](../../lib/features/notifications/presentation/providers/fcm_device_token_sync_provider.dart)). The **in-app notification feed** uses live REST APIs ([`notifications_remote_datasource.dart`](../../lib/features/notifications/data/datasources/notifications_remote_datasource.dart)).

**Gap:** Push is not a complete **lifecycle product** until (1) **backend sends** FCM on order/status events, and (2) **mobile handles** foreground display and tap → relevant screen.

**Business value:** Fewer “Where is my order?” contacts; higher repeat purchase; vendors act faster on new orders.

---

## 2. User journeys that must notify

| Event | Consumer | Vendor |
|-------|----------|--------|
| Order placed | Confirmation push | **New order** (urgent) |
| Vendor confirmed | Push | — |
| Shipped / out for delivery | Push | — |
| Delivered (COD) | Push + review prompt later | Payment/settlement info |
| Cancelled | Push | Push |
| Low stock (optional) | — | Push |

Align copy with COD: emphasize **amount to prepare** for vendor, **pay on delivery** for buyer.

---

## 3. Current mobile technical state

| Capability | Status |
|------------|--------|
| Firebase init (dev/prod flavors) | Yes — [`main.dart`](../../lib/main.dart) |
| Permission + getToken | Yes — [`fcm_token.dart`](../../lib/core/firebase/fcm_token.dart) |
| POST/DELETE device token | Yes — authenticated API |
| Token refresh listener | Yes |
| Logout unregister | Yes |
| `onMessage` / foreground UI | **Not implemented** |
| Tap notification → route | **Not implemented** |
| iOS Release APS `production` | **RunnerRelease.entitlements** (verify in CI) |

**Notification settings:** Local toggles only — see doc 04; backend should respect opt-out when sync exists.

---

## 4. Backend requirements

1. **Store FCM token** per user/device (device-token endpoint).
2. **Trigger FCM** on order state transitions (same events that create inbox rows).
3. Payload contract (recommended):

```json
{
  "notification": { "title": "...", "body": "..." },
  "data": {
    "type": "order_status",
    "orderId": "...",
    "actionRoute": "/order/..."
  }
}
```

4. **Idempotency** — no duplicate pushes on retry.
5. **Rate limits** — avoid burst on bulk status updates.

Firebase **server key / Admin SDK** on backend; project `xstore-22e2f`.

---

## 5. Mobile completion (production UX)

**Minimum for launch:**

1. **Background/killed:** OS displays `notification` payload (no code required if payload structured correctly).
2. **Foreground:** Show in-app banner or local notification (may need `flutter_local_notifications` — product decision).
3. **Tap:** Open order detail or notifications inbox; refresh unread count ([`notifications_provider.dart`](../../lib/features/notifications/presentation/providers/notifications_provider.dart)).
4. **Cold start from push:** `getInitialMessage` → same routing.

**iOS:** APNs key in Firebase; Push capability; production entitlements on release builds.

**Android:** `POST_NOTIFICATIONS` already in manifest.

---

## 6. Operational playbook

| Issue | Response |
|-------|----------|
| User denies permission | Rely on in-app inbox + SMS fallback (backend policy) |
| Token not registered | Re-login; check API 401/500 |
| Vendor misses order | Escalation: SMS for new order if push failed |
| Backend down | Inbox empty; comms template for status page |

---

## 7. Success metrics

| Metric | Target |
|--------|--------|
| Device token register success rate (logged-in sessions) | > 85% on physical devices |
| Push delivery rate (FCM console) | Monitor; > 90% |
| Median time vendor confirm after order | Decrease vs no-push baseline |
| Support tickets “order status” | Decrease week over week |
| Notification open rate | Benchmark 10–20% for transactional |

---

## 8. Testing checklist (pre-production)

- [ ] Physical iPhone + Android, **prod flavor**
- [ ] Login → debug log or API proof of token register
- [ ] Backend test push to single token
- [ ] Each order state triggers one push + one inbox row
- [ ] Tap push → correct order screen
- [ ] Logout → token deregistered
- [ ] `scripts/probe_push_notifications.py` passes when API healthy

---

## 9. Dependencies

- Orders API live with status transitions
- Backend FCM integration (Phase 3 roadmap)
- Doc 03 — event `notification_open` optional
- Doc 04 — honest push preference copy until synced

---

## 10. Risks

| Risk | Mitigation |
|------|------------|
| Push works in dev APS only | Production entitlements + TestFlight test |
| Foreground silent | Implement foreground handler before marketing “instant updates” |
| Spam | Transactional only at launch; no promo blast until opt-in policy clear |
