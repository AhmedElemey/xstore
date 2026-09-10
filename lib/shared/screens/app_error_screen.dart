import 'package:flutter/material.dart';

import '../../core/utils/extensions/context_extensions.dart';
import '../widgets/error_state_widget.dart';

/// Full-screen fallback for navigation/route failures (wired as go_router's
/// `errorBuilder`) — replaces Flutter's default raw error page.
class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({
    super.key,
    this.message,
    this.onRetry,
  });

  /// Falls back to the localized default when omitted, since a `const`
  /// constructor default can't call `context.l10n`.
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ErrorStateWidget(
          message: message ?? context.l10n.routeErrorMessage,
          onRetry: onRetry,
          retryLabel: context.l10n.goHome,
        ),
      ),
    );
  }
}
