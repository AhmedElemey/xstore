import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';
import 'connectivity_provider.dart';

/// Stable error key stored in provider state; map to l10n in [resolveAppError].
const rateLimitErrorCode = 'rateLimitExceeded';

/// CONFIRMED (live probe, 2026-08-14): `POST /api/orders` 400s with this
/// case for a consumer who hasn't verified their phone number yet.
const phoneNotVerifiedErrorCode = 'phoneNotVerified';

/// CONFIRMED (live probe, 2026-08-14): `POST /api/listings` 403s with this
/// case when the vendor's store has no saved lat/lng — register only
/// collects city/governorate dropdowns, so every vendor hits this on their
/// first listing until they complete a location step.
const storeLocationRequiredErrorCode = 'storeLocationRequired';

/// Live probe 2026-08-29: `POST /api/listings` 403 `errorEn` is now
/// "Account must be verified to create listings." (distinct from store
/// location). Map to this code so listing UI can send the user through
/// email-then-phone verify instead of a generic unauthorized snackbar.
const accountNotVerifiedErrorCode = 'accountNotVerified';

/// Live probe 2026-08-29: `POST /api/auth/send-phone-otp` 400s with
/// "Please add and verify your email address before requesting a phone OTP."
const emailRequiredBeforePhoneErrorCode = 'emailRequiredBeforePhone';

/// Maps internal error codes (e.g. offline) to user-facing l10n strings.
String resolveAppError(BuildContext context, String? error) {
  if (isOfflineError(error)) return context.l10n.noInternet;
  if (error == rateLimitErrorCode) {
    return 'Too many requests. Please wait a minute and try again.';
  }
  if (error == emailRequiredBeforePhoneErrorCode) {
    return context.l10n.verifyEmailBeforePhone;
  }
  if (error == accountNotVerifiedErrorCode) {
    return context.l10n.listingErrorAccountNotVerified;
  }
  return error ?? context.l10n.errorGeneric;
}
