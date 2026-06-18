import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';
import 'connectivity_provider.dart';

/// Maps internal error codes (e.g. offline) to user-facing l10n strings.
String resolveAppError(BuildContext context, String? error) {
  if (isOfflineError(error)) return context.l10n.noInternet;
  return error ?? context.l10n.errorGeneric;
}
