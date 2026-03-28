import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/async_value_extensions.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../providers/my_listings_provider.dart';
import '../widgets/listing_card.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  var _handledPublishToast = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledPublishToast) {
      return;
    }
    final msg = GoRouterState.of(context).uri.queryParameters['msg'];
    if (msg == 'published') {
      _handledPublishToast = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Listing published successfully'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(AppRoutes.listingMy);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(myListingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My listings')),
      body: listings.toWidget(
        data: (data) {
          if (data.isEmpty) {
            return const EmptyStateWidget(
              title: 'No listings yet',
              subtitle: 'Create a listing to see it here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(myListingsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: data.length,
              separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = data[index];
                return ListingCard(
                  listing: item,
                  onDelete: () async {
                    try {
                      await ref
                          .read(myListingsProvider.notifier)
                          .deleteById(item.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        errorBuilder: (e) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(myListingsProvider),
        ),
      ),
    );
  }
}
