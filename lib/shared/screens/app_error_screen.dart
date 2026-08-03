import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../widgets/error_state_widget.dart';

/// Full-screen fallback for navigation/route failures (wired as go_router's
/// `errorBuilder`) — replaces Flutter's default raw error page.
class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({
    super.key,
    this.message = AppStrings.routeErrorMessage,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ErrorStateWidget(
          message: message,
          onRetry: onRetry,
          retryLabel: AppStrings.goHome,
        ),
      ),
    );
  }
}
