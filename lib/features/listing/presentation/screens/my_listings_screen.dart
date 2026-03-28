import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/async_value_extensions.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../providers/my_listings_provider.dart';
import '../widgets/listing_card.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
