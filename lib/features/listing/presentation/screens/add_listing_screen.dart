import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../providers/listing_form_provider.dart';
import '../widgets/listing_form_field.dart';
import '../widgets/photo_upload_grid.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(listingFormProvider.notifier);
    notifier.setTitle(_title.text);
    notifier.setDescription(_description.text);
    final price = double.tryParse(_price.text) ?? 0;
    notifier.setPrice(price);

    final ok = await notifier.submit();
    if (!mounted) {
      return;
    }
    if (ok) {
      context.go(AppRoutes.listingMy);
      return;
    }
    final message = ref.read(listingFormProvider).errorMessage;
    if (message != null) {
      context.showSnack(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(listingFormProvider);
    final notifier = ref.read(listingFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Add listing')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          ListingFormField(
            label: 'Title',
            controller: _title,
            onChanged: notifier.setTitle,
          ),
          const Gap(AppSpacing.sm),
          ListingFormField(
            label: 'Description',
            controller: _description,
            maxLines: 4,
            onChanged: notifier.setDescription,
          ),
          const Gap(AppSpacing.sm),
          ListingFormField(
            label: 'Price',
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => notifier.setPrice(double.tryParse(v) ?? 0),
          ),
          const Gap(AppSpacing.md),
          PhotoUploadGrid(
            paths: form.photoPaths,
            onAdd: () => notifier.pickPhotos(),
            onRemove: notifier.removePhotoAt,
          ),
          const Gap(AppSpacing.lg),
          XstoreButton(
            label: 'Publish',
            isLoading: form.isSubmitting,
            onPressed: form.isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
