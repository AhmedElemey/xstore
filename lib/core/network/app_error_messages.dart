import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';
import 'connectivity_provider.dart';

/// Stable error key stored in provider state; map to l10n in [resolveAppError].
const rateLimitErrorCode = 'rateLimitExceeded';

/// Maps internal error codes (e.g. offline) to user-facing l10n strings.
String resolveAppError(BuildContext context, String? error) {
  if (isOfflineError(error)) return context.l10n.noInternet;
  if (error == rateLimitErrorCode) {
    return 'Too many requests. Please wait a minute and try again.';
  }
  return error ?? context.l10n.errorGeneric;
}

/// Heuristic match on a registration failure caused by a phone/email that's
/// already registered. The backend's exact wording for this case isn't
/// documented in the API contract, so this matches on common phrasing
/// rather than a stable error code — broaden the list if a live 400 comes
/// back with different wording.
bool isDuplicateAccountError(String? error) {
  if (error == null) return false;
  final lower = error.toLowerCase();
  return lower.contains('already exist') ||
      lower.contains('already registered') ||
      lower.contains('already has an account') ||
      lower.contains('already in use');
}
