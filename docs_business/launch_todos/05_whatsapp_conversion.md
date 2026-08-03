# Business brief: WhatsApp as official seller contact

**To-do ID:** `whatsapp-conversion`  
**Priority:** P1 — conversion & cost control  
**Audience:** Product owner, mobile, vendor success

---

## 1. Executive summary

In Egypt, **WhatsApp is the default B2C channel**. Building in-app chat at launch is **high cost, low differentiation** ([`02_development_roadmap.md`](../02_development_roadmap.md) explicitly defers chat).

**Recommendation:** Make **WhatsApp the official “Contact seller”** on product detail and order detail; **remove or hide** “Chat seller” Coming Soon; measure click-through.

---

## 2. Business case

| In-app chat | WhatsApp |
|-------------|----------|
| Long build; moderation; notifications | Already on every phone |
| Users leave app | Users stay in familiar UX |
| Platform owns thread | **Risk:** disintermediation | Mitigate with order context in pre-filled message |

For launch, **conversion and vendor satisfaction** beat platform-owned messaging.

---

## 3. Current product state

- Vendor registration and profile include **`whatsappNumber`** (required for vendors on register flow).
- Profile/store merge **`whatsAppNumber`** from API ([`user_model.dart`](../../lib/features/auth/data/models/user_model.dart)).
- **Order detail** already exposes WhatsApp to buyer when vendor number present ([`order_detail_scroll_content.dart`](../../lib/features/orders/presentation/widgets/order_detail_scroll_content.dart)).
- **Product detail / seller profile:** ensure parity — prominent CTA, not buried.
- Router still has **chat → Coming Soon** — should be removed or redirected to WhatsApp.

---

## 4. Standard UX pattern

**Primary CTA:** “Message seller on WhatsApp” (AR: رسالة البائع على واتساب)

**Behavior:**

1. Normalize Egyptian numbers (`01xxxxxxxxx` → `+20…`).
2. Open `https://wa.me/<digits>?text=<encoded prefilled message>`.
3. Prefill example (EN): `Hi, I'm interested in [Product name] on xStore (link).`
4. Prefill with **order id** on order detail: `Question about order #12345 on xStore.`

**Fallback:** If no WhatsApp number, show “Call seller” (tel:) or “Contact via xStore support.”

---

## 5. Vendor onboarding rules

| Rule | Why |
|------|-----|
| Valid WhatsApp required at vendor register | No dead-end buyer contact |
| Editable in profile edit | Number changes |
| Show on public seller profile | Discovery-phase trust |
| Admin can flag vendors with invalid numbers | Quality |

---

## 6. Metrics

| Event | Use |
|-------|-----|
| `whatsapp_seller_tap` | `source=product|order|store`, `listing_id`, `order_id` |
| Tap rate / product views | Seller responsiveness proxy |
| Orders without prior WhatsApp tap | Pure in-app conversion baseline |
| Vendor complaints “buyers spam WhatsApp” | Ops tuning |

**North star helper:** WhatsApp taps should **correlate with** order placement, not replace it — track both.

---

## 7. Disintermediation (honest tradeoff)

**Accept for launch:** Some deals close entirely in WhatsApp.

**Later levers (post-GMV):**

- Order-specific QR or discount codes only valid in-app
- Buyer protection messaging only for in-app orders
- Featured seller badge tied to in-app fulfillment rate

Do not block WhatsApp — it drives vendor signup in Egypt.

---

## 8. Marketing alignment

- Vendor pitch: “Get orders on xStore; talk to customers on WhatsApp you already use.”
- Consumer: “Questions? Message the store on WhatsApp.”
- Do not advertise “in-app chat” until built.

---

## 9. Checklist

- [ ] WhatsApp CTA on product detail + seller profile (parity with order detail)
- [ ] Prefilled message templates (AR + EN)
- [ ] Remove Chat Coming Soon route or replace with WhatsApp
- [ ] Analytics event `whatsapp_seller_tap`
- [ ] Vendor help doc: response time expectations
- [ ] QA on iOS + Android (url_launcher / external app)

---

## 10. Dependencies

- Doc 04 (remove chat Coming Soon)
- Live seller `whatsAppNumber` on listings/store API
- Doc 03 (instrument taps in funnel context)
