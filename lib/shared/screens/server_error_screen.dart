import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/network/server_error_provider.dart';
import '../../core/router/app_routes.dart';
import '../widgets/error_state_widget.dart';

/// Full-screen fallback shown whenever any API call fails with an HTTP 5xx
/// status — see [serverErrorProvider] and the redirect in `app_router.dart`.
/// Replaces whatever the failing screen would have rendered instead of
/// leaking the raw server error inline.
class ServerErrorScreen extends ConsumerWidget {
  const ServerErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ErrorStateWidget(
          message: AppStrings.serverErrorMessage,
          retryLabel: AppStrings.goHome,
          onRetry: () {
            ref.read(serverErrorProvider.notifier).clear();
            context.go(AppRoutes.home);
          },
        ),
      ),
    );
  }
}
