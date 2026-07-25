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
