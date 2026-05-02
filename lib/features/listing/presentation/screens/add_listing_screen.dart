import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/animations/app_dialogs.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../data/listing_categories_data.dart';
import '../providers/listing_form_notifier.dart';
import '../providers/listing_form_state.dart';
import '../widgets/attributes_section.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/condition_selector.dart';
import '../widgets/listing_form_field.dart';
import '../widgets/photo_upload_section.dart';
import '../widgets/quantity_stepper.dart';
import '../utils/listing_localized_labels.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _compare = TextEditingController();
  final _description = TextEditingController();
  final _brand = TextEditingController();
  final _location = TextEditingController();
  final _shippingCost = TextEditingController();
  final _attrKeys = <TextEditingController>[];
  final _attrVals = <TextEditingController>[];
  late final FocusNode _brandFocus = FocusNode();

  @override
  void dispose() {
    _brandFocus.dispose();
    _name.dispose();
    _price.dispose();
    _compare.dispose();
    _description.dispose();
    _brand.dispose();
    _location.dispose();
    _shippingCost.dispose();
    for (final c in _attrKeys) {
      c.dispose();
    }
    for (final c in _attrVals) {
      c.dispose();
    }
    super.dispose();
  }

  void _applyStateToControllers(ListingFormState s) {
    _name.text = s.name;
    _price.text = s.priceInput;
    _compare.text = s.compareAtPriceInput;
    _description.text = s.description;
    _brand.text = s.brand;
    _location.text = s.location;
    _shippingCost.text = s.shippingCostInput;
    _syncAttributeControllers(s.attributes);
  }

  void _syncAttributeControllers(List<AttributeEntry> attrs) {
    while (_attrKeys.length < attrs.length) {
      _attrKeys.add(TextEditingController());
      _attrVals.add(TextEditingController());
    }
    while (_attrKeys.length > attrs.length) {
      _attrKeys.removeLast().dispose();
      _attrVals.removeLast().dispose();
    }
    for (var i = 0; i < attrs.length; i++) {
      if (_attrKeys[i].text != attrs[i].key) {
        _attrKeys[i].text = attrs[i].key;
      }
      if (_attrVals[i].text != attrs[i].value) {
        _attrVals[i].text = attrs[i].value;
      }
    }
  }

  Future<void> _openPhotoSheet() async {
    await showAnimatedBottomSheet<void>(
      context: context,
      builder: (ctx) => Material(
        color: ctx.elevatedSurfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(LucideIcons.camera, color: ctx.iconPrimary),
                title: Text(
                  ctx.l10n.listingTakePhoto,
                  style: Theme.of(
                    ctx,
                  ).textTheme.bodyLarge?.copyWith(color: ctx.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(listingFormNotifierProvider.notifier)
                      .pickFromCamera();
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.imagePlus, color: ctx.iconPrimary),
                title: Text(
                  ctx.l10n.listingChooseFromGallery,
                  style: Theme.of(
                    ctx,
                  ).textTheme.bodyLarge?.copyWith(color: ctx.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(listingFormNotifierProvider.notifier)
                      .pickFromGallery();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _publish() async {
    final notifier = ref.read(listingFormNotifierProvider.notifier);
    notifier.updateField('name', _name.text);
    notifier.updateField('priceInput', _price.text);
    notifier.updateField('compareAtPriceInput', _compare.text);
    notifier.updateField('description', _description.text);
    notifier.updateField('brand', _brand.text);
    notifier.updateField('location', _location.text);
    notifier.updateField('shippingCostInput', _shippingCost.text);

    final retryLabel = context.l10n.retry;
    final ok = await notifier.submit(context.l10n);
    if (!mounted) {
      return;
    }
    if (ok) {
      context.go('${AppRoutes.listingMy}?msg=published');
      return;
    }
    final err = ref.read(listingFormNotifierProvider).errors['submit'];
    if (err != null) {
      AppSnackbar.show(
        context,
        message: err,
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: retryLabel,
          textColor: AppColors.white,
          onPressed: () => _publish(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(listingFormNotifierProvider);
    final notifier = ref.read(listingFormNotifierProvider.notifier);
    final canSubmit = notifier.canSubmit;
    final showCompareWarn = notifier.showCompareAtWarning;

    ref.listen<ListingFormState>(listingFormNotifierProvider, (prev, next) {
      if (prev?.draftRevision != next.draftRevision) {
        _applyStateToControllers(next);
      }
      final pl = prev?.attributes.length ?? 0;
      if (pl != next.attributes.length || prev?.categoryId != next.categoryId) {
        _syncAttributeControllers(next.attributes);
      }
    });

    final err = form.errors;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        surfaceTintColor: AppColors.transparent,
        centerTitle: true,
        title: Text(context.l10n.addListing),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.textSecondary),
            onPressed: form.isSubmitting
                ? null
                : () async {
                    notifier.updateField('name', _name.text);
                    notifier.updateField('priceInput', _price.text);
                    notifier.updateField('compareAtPriceInput', _compare.text);
                    notifier.updateField('description', _description.text);
                    notifier.updateField('brand', _brand.text);
                    notifier.updateField('location', _location.text);
                    notifier.updateField(
                      'shippingCostInput',
                      _shippingCost.text,
                    );
                    await notifier.saveDraft();
                    if (!context.mounted) {
                      return;
                    }
                    // ignore: use_build_context_synchronously
                    AppSnackbar.success(
                      context,
                      context.l10n.listingDraftSaved,
                    );
                  },
            child: Text(context.l10n.saveDraft),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.x3l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ListingPhotosBasicsSection(
                    form: form,
                    notifier: notifier,
                    errors: err,
                    openPhotoPicker: _openPhotoSheet,
                    nameController: _name,
                    priceController: _price,
                    compareController: _compare,
                    descriptionController: _description,
                    showCompareWarn: showCompareWarn,
                  ),
                  _ListingCategoryBrandSection(
                    form: form,
                    notifier: notifier,
                    errors: err,
                    brandController: _brand,
                    brandFocusNode: _brandFocus,
                    categoryDisplay: _categoryLabel(form.categoryId),
                    subcategoryDisplay: _subcategoryLabel(
                      form.categoryId,
                      form.subcategoryId,
                    ),
                  ),
                  _ListingShippingAttributesSection(
                    form: form,
                    notifier: notifier,
                    errors: err,
                    locationController: _location,
                    shippingCostController: _shippingCost,
                    attrKeyControllers: _attrKeys,
                    attrValueControllers: _attrVals,
                  ),
                  const Gap(AppSpacing.x4l),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: _PublishBar(
                publishLabel: context.l10n.publishListing,
                enabled: canSubmit && !form.isSubmitting,
                loading: form.isSubmitting,
                onPressed: _publish,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String id) {
    if (id.isEmpty) {
      return context.l10n.listingSelectCategory;
    }
    return listingLocalizedCategoryName(context, id);
  }

  String _subcategoryLabel(String catId, String subId) {
    if (subId.isEmpty) {
      return context.l10n.listingSelectSubcategory;
    }
    return listingLocalizedSubcategoryName(context, catId, subId);
  }
}

class _ListingPhotosBasicsSection extends StatelessWidget {
  const _ListingPhotosBasicsSection({
    required this.form,
    required this.notifier,
    required this.errors,
    required this.openPhotoPicker,
    required this.nameController,
    required this.priceController,
    required this.compareController,
    required this.descriptionController,
    required this.showCompareWarn,
  });

  final ListingFormState form;
  final ListingFormNotifier notifier;
  final Map<String, String?> errors;
  final VoidCallback openPhotoPicker;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController compareController;
  final TextEditingController descriptionController;
  final bool showCompareWarn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PhotoUploadSection(
          paths: form.photoPaths,
          errorText: errors['photos'],
          onOpenPicker: openPhotoPicker,
          onRemove: notifier.removePhoto,
          onReorder: notifier.reorderPhotos,
        ),
        const Gap(AppSpacing.x3l),
        _AccentSectionTitle(context.l10n.listingSectionBasicInfo),
        const Gap(AppSpacing.lg),
        ListingFormField(
          label: context.l10n.listingProductNameLabel,
          controller: nameController,
          hint: context.l10n.listingProductNameHint,
          maxLength: 100,
          errorText: errors['name'],
          onChanged: (v) => notifier.updateField('name', v),
        ),
        const Gap(AppSpacing.lg),
        ListingFormField(
          label: context.l10n.listingPriceLabel,
          controller: priceController,
          hint: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixText: '${notifier.currencyCode} ',
          errorText: errors['price'],
          onChanged: (v) => notifier.updateField('priceInput', v),
        ),
        const Gap(AppSpacing.lg),
        Text(
          context.l10n.listingCompareAtTitle,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: context.scaledPx(6)),
        ListingFormField(
          label: '',
          controller: compareController,
          hint: '0.00',
          prefixText: '${notifier.currencyCode} ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) => notifier.updateField('compareAtPriceInput', v),
        ),
        Text(
          context.l10n.listingCompareAtHelper,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.textHint,
                height: 1.35,
              ),
        ),
        if (showCompareWarn)
          Padding(
            padding: EdgeInsets.only(top: context.scaledPx(6)),
            child: Text(
              context.l10n.listingCompareAtWarning,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.isDark
                        ? AppColors.warningLight
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        const Gap(AppSpacing.lg),
        ListingFormField(
          label: context.l10n.listingDescriptionLabel,
          controller: descriptionController,
          hint: context.l10n.listingDescriptionHint,
          minLines: 4,
          maxLines: null,
          maxLength: 1000,
          errorText: errors['description'],
          onChanged: (v) => notifier.updateField('description', v),
        ),
      ],
    );
  }
}

class _ListingCategoryBrandSection extends StatelessWidget {
  const _ListingCategoryBrandSection({
    required this.form,
    required this.notifier,
    required this.errors,
    required this.brandController,
    required this.brandFocusNode,
    required this.categoryDisplay,
    required this.subcategoryDisplay,
  });

  final ListingFormState form;
  final ListingFormNotifier notifier;
  final Map<String, String?> errors;
  final TextEditingController brandController;
  final FocusNode brandFocusNode;
  final String categoryDisplay;
  final String subcategoryDisplay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(AppSpacing.x3l),
        _AccentSectionTitle(context.l10n.listingSectionCategoryDetails),
        const Gap(AppSpacing.lg),
        _PickerField(
          label: context.l10n.listingFormCategoryLabel,
          value: categoryDisplay,
          valueIsPlaceholder: form.categoryId.isEmpty,
          errorText: errors['category'],
          onTap: () => showListingCategoryPicker(
            context: context,
            title: context.l10n.listingFormCategoryPickerTitle,
            categories: ListingCategoriesData.categories,
            selectedId:
                form.categoryId.isEmpty ? null : form.categoryId,
            onSelected: (id) => notifier.updateField('categoryId', id),
          ),
        ),
        const Gap(AppSpacing.lg),
        if (form.categoryId.isNotEmpty) ...[
          _PickerField(
            label: context.l10n.listingFormSubcategoryLabel,
            value: subcategoryDisplay,
            valueIsPlaceholder: form.subcategoryId.isEmpty,
            errorText: errors['subcategory'],
            onTap: () {
              final cat =
                  ListingCategoriesData.categoryById(form.categoryId);
              if (cat == null) {
                return;
              }
              showListingSubcategoryPicker(
                context: context,
                category: cat,
                selectedId: form.subcategoryId.isEmpty
                    ? null
                    : form.subcategoryId,
                onSelected: (id) => notifier.updateField('subcategoryId', id),
              );
            },
          ),
          const Gap(AppSpacing.lg),
        ],
        ConditionSelector(
          options: ListingCategoriesData.conditions,
          selected: form.condition,
          errorText: errors['condition'],
          optionLabel: (o) => listingLocalizedCondition(context, o),
          onChanged: (v) => notifier.updateField('condition', v),
        ),
        const Gap(AppSpacing.lg),
        RawAutocomplete<String>(
          textEditingController: brandController,
          focusNode: brandFocusNode,
          optionsBuilder: (tv) => notifier.brandSuggestionsFor(tv.text),
          onSelected: (s) {
            brandController.text = s;
            notifier.updateField('brand', s);
          },
          fieldViewBuilder: (context, c, fn, onFieldSubmitted) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.listingBrandOptional,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: context.scaledPx(6)),
                TextField(
                  controller: c,
                  focusNode: fn,
                  onChanged: (v) => notifier.updateField('brand', v),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.textPrimary,
                      ),
                  decoration: InputDecoration(
                    hintText: context.l10n.listingBrandHint,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.textHint,
                        ),
                    filled: true,
                    fillColor: context.surfaceVariantColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.scaledPx(AppTypography.rem(0.875)),
                      vertical: context.scaledPx(AppTypography.rem(0.875)),
                    ),
                  ),
                ),
              ],
            );
          },
          optionsViewBuilder: (context, onSelected, opts) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: context.surfaceColor,
                surfaceTintColor: AppColors.transparent,
                elevation: 4,
                shadowColor: context.shadowColor,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: opts.length,
                    itemBuilder: (context, i) {
                      final o = opts.elementAt(i);
                      return ListTile(
                        dense: true,
                        title: Text(
                          o,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: context.textPrimary),
                        ),
                        onTap: () => onSelected(o),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ListingShippingAttributesSection extends StatelessWidget {
  const _ListingShippingAttributesSection({
    required this.form,
    required this.notifier,
    required this.errors,
    required this.locationController,
    required this.shippingCostController,
    required this.attrKeyControllers,
    required this.attrValueControllers,
  });

  final ListingFormState form;
  final ListingFormNotifier notifier;
  final Map<String, String?> errors;
  final TextEditingController locationController;
  final TextEditingController shippingCostController;
  final List<TextEditingController> attrKeyControllers;
  final List<TextEditingController> attrValueControllers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(AppSpacing.x3l),
        _AccentSectionTitle(context.l10n.listingSectionStockShipping),
        const Gap(AppSpacing.lg),
        QuantityStepper(
          quantity: form.quantity,
          errorText: errors['quantity'],
          onChanged: (q) => notifier.updateField('quantity', q),
        ),
        const Gap(AppSpacing.lg),
        ListingFormField(
          label: context.l10n.listingFormLocationLabel,
          controller: locationController,
          hint: context.l10n.listingFormLocationHint,
          prefix: const Icon(LucideIcons.mapPin, size: 22),
          errorText: errors['location'],
          onChanged: (v) => notifier.updateField('location', v),
        ),
        const Gap(AppSpacing.lg),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            context.l10n.listingShippingAvailable,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.textPrimary,
                ),
          ),
          value: form.shippingAvailable,
          onChanged: (v) => notifier.updateField('shippingAvailable', v),
        ),
        if (form.shippingAvailable) ...[
          const Gap(AppSpacing.md),
          ListingFormField(
            label: context.l10n.listingShippingCostLabel,
            controller: shippingCostController,
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixText: '${notifier.currencyCode} ',
            errorText: errors['shippingCost'],
            onChanged: (v) => notifier.updateField('shippingCostInput', v),
          ),
        ],
        const Gap(AppSpacing.x3l),
        _AccentSectionTitle(context.l10n.listingSectionProductAttributes),
        Text(
          context.l10n.listingAttributesSubtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
        ),
        const Gap(AppSpacing.lg),
        AttributesSection(
          keyControllers: attrKeyControllers,
          valueControllers: attrValueControllers,
          onAdd: notifier.addAttribute,
          onRemove: notifier.removeAttribute,
          onKeyChanged: (i, v) => notifier.updateAttribute(i, key: v),
          onValueChanged: (i, v) =>
              notifier.updateAttribute(i, value: v),
        ),
      ],
    );
  }
}

class _AccentSectionTitle extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables — title comes from l10n at runtime
  _AccentSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: context.scaledPx(10)),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
              letterSpacing: context.scaledPx(-0.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
    this.valueIsPlaceholder = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final String? errorText;
  final bool valueIsPlaceholder;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.scaledPx(6)),
        Material(
          color: context.surfaceVariantColor,
          borderRadius: BorderRadius.circular(12),
          child: Semantics(
            button: true,
            label: '${label.isNotEmpty ? '$label · ' : ''}$value',
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              splashColor: context.primaryColor.withValues(alpha: 0.08),
              highlightColor: context.primaryColor.withValues(alpha: 0.06),
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.surfaceVariantColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? AppColors.error : context.textDisabled,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? AppColors.error : context.textDisabled,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.scaledPx(AppTypography.rem(0.875)),
                    vertical: context.scaledPx(AppTypography.rem(0.875)),
                  ),
                  suffixIcon: Icon(
                    LucideIcons.chevronDown,
                    color: context.iconSecondary,
                    size: 22,
                  ),
                ),
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: valueIsPlaceholder
                        ? context.textHint
                        : context.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(
              top: context.scaledPx(4),
              left: context.scaledPx(4),
            ),
            child: Text(
              errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _PublishBar extends StatelessWidget {
  const _PublishBar({
    required this.publishLabel,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final String publishLabel;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: enabled
          ? [AppColors.primary, AppColors.accent]
          : [AppColors.materialGrey400, AppColors.materialGrey500],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled && !loading ? onPressed : null,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      publishLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: AppTypography.rem(1),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
