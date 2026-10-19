# QA suite (`test/qa/`)

A from-scratch QA pass (2026-09-24), independent of the rest of `test/`. Each
test encodes an edge case; a **failing** test is a **confirmed defect**, cross-
referenced in `/QA_REPORT.md` by name. Do not "fix" these tests by weakening the
assertion — fix the product code, then the test goes green.

| File | Covers |
|------|--------|
| `core_validators_qa_test.dart` | phone/email/name/password/birth-date/money/listing-form validation, JWT parsing |
| `network_qa_test.dart` | `TokenRefreshInterceptor`, `mapDioException` |
| `cart_logic_qa_test.dart` | discount, shipping, vendor grouping, selection totals (all pass) |
| `formatters_qa_test.dart` | notification-time + date formatting (all pass) |
| `location_cache_qa_test.dart` | geo-header Egypt-bounds fallback (all pass) |
| `support/scripted_adapter.dart` | a scripted Dio HTTP adapter for offline network tests |

Run: `flutter test test/qa/`
