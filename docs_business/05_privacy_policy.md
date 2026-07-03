# xStore — Privacy Policy

> **⚠️ NOT LEGAL ADVICE — TEMPLATE FOR REVIEW.** I'm not a lawyer. This draft is grounded in the data xStore actually collects (from the codebase audit) and oriented to Egypt's **Personal Data Protection Law No. 151 of 2020 (PDPL)**. **Have an Egyptian-qualified privacy lawyer review it before publishing**, and confirm the current status of the PDPL executive regulations, any data-controller registration/licensing obligations, and cross-border transfer rules with counsel.
>
> **Fill the `{{PLACEHOLDERS}}` before publishing.**

**Effective date:** {{EFFECTIVE_DATE}}
**Last updated:** {{LAST_UPDATED}}

---

## 1. Who We Are

This Privacy Policy explains how {{LEGAL_ENTITY_NAME}} ("**xStore**", "**we**", "**us**"), the operator of the xStore marketplace app (the "**Platform**"), collects and processes your personal data. For the purposes of the PDPL, xStore is the **data controller**. Registered address: {{REGISTERED_ADDRESS}}. Contact: {{PRIVACY_EMAIL}}.

## 2. Data We Collect

We collect only what we need to run the marketplace:

**a. Information you provide**
- **Account data:** name, email address, and **mobile phone number** (verified by one-time password / OTP), password, and whether you are a Buyer or Vendor.
- **Profile data:** profile photo/avatar and, for Vendors, store name, store location/governorate, store hours, and contact details.
- **Order & delivery data:** delivery address, recipient name and phone, order contents, quantities, and notes.
- **Content:** product reviews, ratings, Listings (for Vendors), and messages/inquiries you submit.
- **Support communications:** information you share when you contact us.

**b. Information collected automatically**
- **Device & usage data:** device type, app version, language setting, and interactions used to operate and improve the Platform.
- **Approximate/technical location:** governorate/city you enter for delivery; connectivity status. {{Confirm with dev whether precise GPS is used — the current app uses a governorate picker, not GPS.}}
- **Authentication tokens** stored securely on your device to keep you signed in.

**c. Payment data**
At launch, orders are **Cash on Delivery (COD)**. **We do not collect or store card numbers, CVV, or bank details through the Platform.** If online payment is introduced later, it will be handled by a licensed payment provider and this Policy will be updated accordingly.

## 3. How We Use Your Data

We use personal data to: create and manage your account; verify your phone number; display and process Orders; connect Buyers and Vendors to complete transactions; enable delivery; show relevant Listings; send order and account notifications; provide customer support; maintain security and prevent fraud; comply with legal obligations; and improve the Platform.

## 4. Legal Basis (PDPL)

We process personal data on the basis of: your **consent** (which you may withdraw); the **performance of a contract** with you (e.g. fulfilling Orders); our **legitimate interests** in operating and securing the Platform; and **compliance with legal obligations**. Where we rely on consent (e.g. marketing messages), you may withdraw it at any time.

## 5. How We Share Your Data

We share personal data only as needed to operate the marketplace:

- **With Vendors:** when you place an Order, the relevant Vendor receives the information needed to fulfill and deliver it — your **name, delivery address, phone number, and order details**. Vendors may only use this data to fulfill your Order.
- **With Buyers:** Vendors' store name, location, ratings, and contact information necessary for a transaction.
- **With service providers (processors):** authentication and app infrastructure (e.g. Google/Firebase), hosting, notifications, and analytics providers that process data on our behalf under appropriate safeguards.
- **With delivery/courier partners:** to deliver Orders and collect COD payment.
- **For legal reasons:** to comply with law, court orders, or lawful requests, and to protect rights, safety, and prevent fraud.

We do **not** sell your personal data.

## 6. International Data Transfers

Some service providers (e.g. Google/Firebase) may process data on servers outside Egypt. Where personal data is transferred abroad, we take steps intended to ensure an adequate level of protection consistent with the PDPL. {{⚠️ Counsel to confirm PDPL cross-border transfer requirements and any regulator authorization needed.}}

## 7. Data Retention

We keep personal data only as long as necessary for the purposes described here, including maintaining your account, completing and evidencing transactions, resolving disputes, and complying with legal, tax, and accounting obligations. When no longer needed, data is deleted or anonymized. {{Specify concrete retention periods with counsel.}}

## 8. Security

We use technical and organizational measures to protect your data, including encrypted transport (TLS) and secure on-device storage of authentication tokens. No system is completely secure; we cannot guarantee absolute security, but we work to protect your information and to notify you and the competent authority of qualifying breaches as required by law.

## 9. Your Rights (PDPL)

Subject to applicable law, you have the right to: **access** your personal data; **correct** inaccurate data; **delete** your data ("right to be forgotten"); **object to** or **restrict** certain processing; **withdraw consent**; and **data portability** where applicable. To exercise these rights, contact **{{PRIVACY_EMAIL}}**. You may also lodge a complaint with Egypt's competent data protection authority.

Note: some data must be retained to complete an active Order or to meet legal obligations, so certain requests may be limited accordingly.

## 10. Notifications & Marketing

We send **transactional** messages (order status, account, security) as part of the service. With your consent, we may send **promotional** messages; you can opt out at any time via the app's notification settings or the unsubscribe mechanism. {{Push notifications require an FCM integration — see roadmap; confirm channels actually live at launch.}}

## 11. Children's Privacy

The Platform is not intended for anyone under **18**. We do not knowingly collect data from minors. If you believe a minor has provided us data, contact {{PRIVACY_EMAIL}} and we will delete it.

## 12. Cookies / Analytics

{{State whether analytics/tracking SDKs are used. If the app uses Firebase Analytics or similar, disclose it and the opt-out. If none at launch, state "The app does not currently use advertising cookies or third-party ad tracking."}}

## 13. Changes to This Policy

We may update this Policy from time to time. Material changes will be notified in the app or by other reasonable means, and the "Last updated" date will change. Continued use after changes take effect constitutes acceptance where permitted by law.

## 14. Contact

Privacy questions or requests: **{{PRIVACY_EMAIL}}** · {{SUPPORT_PHONE}} · {{REGISTERED_ADDRESS}}. {{If you appoint a Data Protection Officer, list them here.}}

---

### Placeholders to fill before publishing
`{{LEGAL_ENTITY_NAME}}` · `{{REGISTERED_ADDRESS}}` · `{{PRIVACY_EMAIL}}` · `{{SUPPORT_PHONE}}` · `{{EFFECTIVE_DATE}}` · `{{LAST_UPDATED}}` · retention periods (Sec 7) · analytics disclosure (Sec 12) · GPS confirmation (Sec 2b) · DPO (Sec 14).

### Two things for the dev team to make this policy *true* (not just posted)
1. **Account deletion must actually work** — Section 9 promises a delete right; there needs to be a real "delete my account/data" path (in-app or via {{PRIVACY_EMAIL}} with a documented process). Don't promise a right the app can't honor.
2. **Confirm analytics/location reality** — verify whether any analytics SDK or GPS is active and disclose accordingly; the audit suggests governorate-picker location (not GPS) and no ad tracking, but confirm before publishing.

### Arabic version
Commission a professional legal Arabic translation once counsel finalizes the English; treat the Arabic as an official version for Egyptian users.
