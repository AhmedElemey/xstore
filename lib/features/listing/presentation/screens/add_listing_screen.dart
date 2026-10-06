import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/animations/app_dialogs.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../domain/entities/listing_entity.dart';
import '../../../catalog_categories/domain/entities/catalog_category_entity.dart';
import '../../../catalog_categories/presentation/providers/catalog_category_dependencies.dart';
import '../../../commission/domain/entities/commission_breakdown.dart';
import '../../../commission/presentation/providers/commission_config_provider.dart';
import '../../../commission/presentation/providers/vendor_commission_wallet_provider.dart';
import '../../../commission/presentation/widgets/commission_breakdown_card.dart';
import '../../../commission/presentation/widgets/vendor_commission_alert_banner.dart';
import '../data/listing_categories_data.dart';
import '../providers/listing_form_notifier.dart';
import '../providers/listing_form_state.dart';
import '../utils/catalog_category_tree.dart';
import '../widgets/attributes_section.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/condition_selector.dart';
import '../widgets/listing_form_field.dart';
import '../widgets/photo_upload_section.dart';
import '../widgets/quantity_stepper.dart';
import '../utils/listing_localized_labels.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/utils/require_phone_verified.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/location_cascade_field.dart';
import '../../../cities/presentation/providers/city_dependencies.dart';
import '../../../governments/presentation/providers/government_dependencies.dart';

/// Money fields (price, compare-at, shipping): fold Arabic-Indic digits, then
/// keep only digits, `.` and `,` — so typed or pasted letters never show in
/// the field while the notifier silently strips them from state.
final List<TextInputFormatter> _moneyInputFormatters = [
  TextInputFormatter.withFunction(
    (_, v) => v.copyWith(text: AppValidators.foldDigits(v.text)),
  ),
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key, this.editingListing});

  /// When non-null, the form opens prefilled with this listing's data and
  /// `submit()` updates it instead of creating a new one.
  final ListingEntity? editingListing;

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _compare = TextEditingController();
  final _description = TextEditingController();
  final _brand = TextEditingController();
  final _shippingCost = TextEditingController();
  final _attrKeys = <TextEditingController>[];
  final _attrVals = <TextEditingController>[];
  // The shell branch keeps this State (and its scroll offset) alive, so a
  // fresh form must scroll back to the top itself — see the draftRevision
  // listener in build.
  final _scroll = ScrollController();

  // Picker selection for the Location field. The listing itself only stores
  // the "Governorate - City" label (the API takes a free-text `location`),
  // so these ids just drive the picker's highlight and are cleared whenever
  // the form is reloaded — the saved label then shows as the field's hint.
  int? _cityId;
  int? _governorateId;

  // `/listing/add` is a StatefulShellRoute branch — go_router keeps its
  // Page/State alive across navigations to the same path, so tapping
  // "Edit" on a second listing (or "New Listing" after editing one) can
  // reuse this exact State instead of remounting it. Track what we last
  // synced so didUpdateWidget can react to that change; initState alone
  // would miss it.
  bool _hasSyncedEditingListing = false;
  String? _syncedEditingListingId;

  void _syncEditingListing() {
    final editing = widget.editingListing;
    final id = editing?.id;
    final isFirstSync = !_hasSyncedEditingListing;
    if (_hasSyncedEditingListing && id == _syncedEditingListingId) return;
    _hasSyncedEditingListing = true;
    _syncedEditingListingId = id;

    if (editing != null) {
      // Synchronous field-only flag (see prepareForEdit's doc) so the
      // notifier's own pending draft-load skips itself — must run before
      // any microtask, hence called here rather than deferred.
      ref.read(listingFormNotifierProvider.notifier).prepareForEdit(editing);
      // The actual state write is deferred past this build/lifecycle
      // callback — Riverpod forbids modifying provider state synchronously
      // from initState/didUpdateWidget.
      Future(() {
        if (!mounted) return;
        ref.read(listingFormNotifierProvider.notifier).loadForEdit(editing);
      });
    } else if (!isFirstSync) {
      // Switched from editing a listing back to "New Listing" while this
      // screen's state was reused — clear the stale edit state so submit()
      // creates instead of updating the previously-edited listing.
      Future(() {
        if (!mounted) return;
        ref.read(listingFormNotifierProvider.notifier).reset();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _syncEditingListing();
  }

  @override
  void didUpdateWidget(covariant AddListingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncEditingListing();
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _compare.dispose();
    _description.dispose();
    _brand.dispose();
    _shippingCost.dispose();
    _scroll.dispose();
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
    _cityId = null;
    _governorateId = null;
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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

  void _onLocationChanged(int? cityId, int? governorateId) {
    setState(() {
      _cityId = cityId;
      _governorateId = governorateId;
    });
    // Both lists are already loaded — the picker sheets just showed them.
    final isArabic = ref.read(appIsArabicProvider);
    final city = cityId == null
        ? null
        : ref
              .read(allCitiesProvider)
              .valueOrNull
              ?.where((c) => c.id == cityId)
              .firstOrNull;
    final governorate = ref
        .read(allGovernmentsProvider)
        .valueOrNull
        ?.where((g) => g.id == governorateId)
        .firstOrNull;
    // A governorate without a city leaves the field empty, so validation
    // still asks for a city.
    ref
        .read(listingFormNotifierProvider.notifier)
        .updateField(
          'location',
          city == null || governorate == null
              ? ''
              : '${governorate.name.resolve(isArabic)} - '
                    '${city.name.resolve(isArabic)}',
        );
  }

  Future<void> _publish() async {
    // Drop focus from the last-edited field (often shipping cost or an
    // attribute, near the bottom). Otherwise it stays focused in the
    // kept-alive shell branch and EditableText scrolls it back into view
    // when the keyboard reappears, undoing the reset's jump to the top.
    FocusScope.of(context).unfocus();
    // Proactive check — the backend 403s "Account must be verified to
    // create listings" for an unverified phone; check first instead of
    // letting a guaranteed-failing request go out.
    if (!await requirePhoneVerified(context, ref)) return;
    if (!mounted) return;

    final notifier = ref.read(listingFormNotifierProvider.notifier);
    notifier.updateField('name', _name.text);
    notifier.updateField('priceInput', _price.text);
    notifier.updateField('compareAtPriceInput', _compare.text);
    notifier.updateField('description', _description.text);
    notifier.updateField('brand', _brand.text);
    notifier.updateField('shippingCostInput', _shippingCost.text);

    final formBeforeSubmit = ref.read(listingFormNotifierProvider);
    final isEditing = formBeforeSubmit.editingListingId.isNotEmpty;
    final isPublishingDraft =
        formBeforeSubmit.editingStatus == ListingStatus.draft;
    final retryLabel = context.l10n.retry;
    final ok = await notifier.submit(context.l10n);
    if (!mounted) {
      return;
    }
    if (ok) {
      AppSnackbar.success(
        context,
        isEditing && !isPublishingDraft
            ? context.l10n.listingUpdatedSuccess
            : context.l10n.listingPublishedSuccess,
      );
      context.go(AppRoutes.listingMy);
      return;
    }
    final err = ref.read(listingFormNotifierProvider).errors['submit'];
    if (err == storeLocationRequiredErrorCode) {
      AppSnackbar.show(
        context,
        message: context.l10n.listingErrorStoreLocationRequired,
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: context.l10n.setStoreLocation,
          textColor: AppColors.white,
          onPressed: () => context.push(AppRoutes.profileEdit),
        ),
      );
      return;
    }
    if (err == accountNotVerifiedErrorCode) {
      AppSnackbar.show(
        context,
        message: context.l10n.listingErrorAccountNotVerified,
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: context.l10n.verifyNow,
          textColor: AppColors.white,
          onPressed: () => _publish(),
        ),
      );
      return;
    }
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
    final catalogCategories =
        ref.watch(allCatalogCategoriesProvider).valueOrNull ??
        const <CatalogCategoryEntity>[];
    final isArabic = ref.watch(appIsArabicProvider);

    ref.listen<ListingFormState>(listingFormNotifierProvider, (prev, next) {
      if (prev?.draftRevision != next.draftRevision) {
        _applyStateToControllers(next);
        // New/reset/loaded form: start at the top, not where the last
        // submit (the Publish button at the bottom) left off.
        if (_scroll.hasClients) _scroll.jumpTo(0);
      }
      // Brand lives on a local controller (same as name/price). Category /
      // subcategory changes clear it in notifier state without bumping
      // draftRevision, so copy that wipe here — otherwise Apple stays in
      // the field after switching to Furniture.
      if (prev?.brand != next.brand && _brand.text != next.brand) {
        _brand.text = next.brand;
      }
      final pl = prev?.attributes.length ?? 0;
      if (pl != next.attributes.length || prev?.categoryId != next.categoryId) {
        _syncAttributeControllers(next.attributes);
      }
    });

    final err = form.errors;
    final isEditing = form.editingListingId.isNotEmpty;

    // The Scaffold is the snackbar host; the sky paints behind it.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OrbitBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      // "Add Listing" is a bottom-nav tab root — no back
                      // button, same as Home/Explore/etc. Editing only ever
                      // gets here via context.go from My Listings (a tab
                      // switch, not a push), which leaves no back stack to
                      // pop, so this is the only way back without the bottom
                      // nav. _syncEditingListing already resets the form
                      // when the widget's editingListing later goes back to
                      // null (a fresh "Add"), so this doesn't need to reset
                      // anything itself.
                      if (isEditing) ...[
                        AuthBackButton(
                          onPressed: () => context.go(AppRoutes.listingMy),
                        ),
                        const Gap(AppSpacing.md),
                      ],
                      Expanded(
                        child: Text(
                          isEditing
                              ? context.l10n.editListingMenu
                              : context.l10n.addListing,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      // Drafts are a create-flow concept only — editing an
                      // existing listing writes straight to the server via
                      // Update Listing.
                      if (!isEditing)
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: context.linkColor,
                            textStyle: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: form.isSubmitting
                              ? null
                              : () async {
                                  notifier.updateField('name', _name.text);
                                  notifier.updateField(
                                    'priceInput',
                                    _price.text,
                                  );
                                  notifier.updateField(
                                    'compareAtPriceInput',
                                    _compare.text,
                                  );
                                  notifier.updateField(
                                    'description',
                                    _description.text,
                                  );
                                  notifier.updateField('brand', _brand.text);
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
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.x3l,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (ref.watch(vendorCommissionWalletProvider).valueOrNull
                          case final wallet?)
                        VendorCommissionAlertBanner(wallet: wallet),
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
                        categoryDisplay: _categoryLabel(
                          catalogCategories,
                          isArabic,
                          form.categoryId,
                        ),
                        subcategoryDisplay: _subcategoryLabel(
                          catalogCategories,
                          isArabic,
                          form.subcategoryId,
                        ),
                      ),
                      _ListingShippingAttributesSection(
                        form: form,
                        notifier: notifier,
                        errors: err,
                        cityId: _cityId,
                        governorateId: _governorateId,
                        onLocationChanged: _onLocationChanged,
                        shippingCostController: _shippingCost,
                        attrKeyControllers: _attrKeys,
                        attrValueControllers: _attrVals,
                      ),
                      const Gap(AppSpacing.x4l),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: XstoreButton(
                  label: isEditing && form.editingStatus != ListingStatus.draft
                      ? context.l10n.updateListing
                      : context.l10n.publishListing,
                  isLoading: form.isSubmitting,
                  onPressed: canSubmit && !form.isSubmitting ? _publish : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(
    List<CatalogCategoryEntity> categories,
    bool isArabic,
    String id,
  ) {
    if (id.isEmpty) {
      return context.l10n.listingSelectCategory;
    }
    final intId = int.tryParse(id);
    if (intId == null) {
      return context.l10n.listingSelectCategory;
    }
    return catalogCategoryById(categories, intId)?.name.resolve(isArabic) ??
        context.l10n.listingSelectCategory;
  }

  String _subcategoryLabel(
    List<CatalogCategoryEntity> categories,
    bool isArabic,
    String subId,
  ) {
    if (subId.isEmpty) {
      return context.l10n.listingSelectSubcategory;
    }
    final intId = int.tryParse(subId);
    if (intId == null) {
      return context.l10n.listingSelectSubcategory;
    }
    return catalogCategoryById(categories, intId)?.name.resolve(isArabic) ??
        context.l10n.listingSelectSubcategory;
  }
}

class _ListingPhotosBasicsSection extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final price = Validators.parseMoneyInput(form.priceInput);
    final categoryId = int.tryParse(form.categoryId);
    final feeEgp = ref.watch(commissionFeeEgpForCategoryProvider(categoryId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PhotoUploadSection(
          paths: form.photoPaths,
          existingUrls: form.existingImageUrls,
          errorText: errors['photos'],
          onOpenPicker: openPhotoPicker,
          onRemove: notifier.removePhoto,
          onRemoveExisting: notifier.removeExistingPhoto,
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
          inputFormatters: _moneyInputFormatters,
          prefixText: '${notifier.currencyCode} ',
          errorText: errors['price'],
          onChanged: (v) => notifier.updateField('priceInput', v),
        ),
        if (price != null && price > 0) ...[
          const Gap(AppSpacing.sm),
          CommissionBreakdownCard(
            breakdown: CommissionBreakdown.forPrice(price, feeEgp: feeEgp),
            currencyCode: notifier.currencyCode,
          ),
        ],
        const Gap(AppSpacing.lg),
        ListingFormField(
          label: context.l10n.listingCompareAtTitle,
          controller: compareController,
          hint: '0.00',
          prefixText: '${notifier.currencyCode} ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _moneyInputFormatters,
          errorText: errors['compareAt'],
          onChanged: (v) => notifier.updateField('compareAtPriceInput', v),
        ),
        const Gap(AppSpacing.sm),
        Text(
          context.l10n.listingCompareAtHelper,
          style: AppTypography.bodySmall.copyWith(
            color: context.textHint,
            height: 1.35,
          ),
        ),
        if (showCompareWarn && errors['compareAt'] == null)
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
    required this.categoryDisplay,
    required this.subcategoryDisplay,
  });

  final ListingFormState form;
  final ListingFormNotifier notifier;
  final Map<String, String?> errors;
  final TextEditingController brandController;
  final String categoryDisplay;
  final String subcategoryDisplay;

  @override
  Widget build(BuildContext context) {
    final selectedCategoryId = int.tryParse(form.categoryId);
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
            selectedId: selectedCategoryId,
            onSelected: (id) =>
                notifier.updateField('categoryId', id.toString()),
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
              final parentId = selectedCategoryId;
              if (parentId == null) return;
              showListingSubcategoryPicker(
                context: context,
                title:
                    '${context.l10n.subcategoryPickerPrefix}$categoryDisplay',
                parentId: parentId,
                selectedId: int.tryParse(form.subcategoryId),
                onSelected: (id) =>
                    notifier.updateField('subcategoryId', id.toString()),
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
        ListingFormField(
          label: context.l10n.listingBrandOptional,
          controller: brandController,
          hint: context.l10n.listingBrandHint,
          errorText: errors['brand'],
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => notifier.updateField('brand', v),
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
    required this.cityId,
    required this.governorateId,
    required this.onLocationChanged,
    required this.shippingCostController,
    required this.attrKeyControllers,
    required this.attrValueControllers,
  });

  final ListingFormState form;
  final ListingFormNotifier notifier;
  final Map<String, String?> errors;
  final int? cityId;
  final int? governorateId;
  final void Function(int? cityId, int? governorateId) onLocationChanged;
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
        LocationCascadeField(
          cityId: cityId,
          governorateId: governorateId,
          hint: form.location,
          errorText: errors['location'],
          onChanged: onLocationChanged,
        ),
        const Gap(AppSpacing.lg),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(
            context.l10n.listingShippingAvailable,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: context.textPrimary),
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
            inputFormatters: _moneyInputFormatters,
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
          onValueChanged: (i, v) => notifier.updateAttribute(i, value: v),
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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: context.brandGradient,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: context.scaledPx(10)),
        Expanded(
          child: Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              fontSize: 16,
              color: context.textPrimary,
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
          label.toUpperCase(),
          style: AppTypography.fieldLabel.copyWith(color: context.labelColor),
        ),
        SizedBox(height: context.scaledPx(8)),
        Semantics(
          button: true,
          label: '${label.isNotEmpty ? '$label · ' : ''}$value',
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            // Fill and borders (error included) come from the Orbit theme.
            child: InputDecorator(
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.scaledPx(16),
                  vertical: context.scaledPx(16),
                ),
                suffixIcon: Icon(
                  LucideIcons.chevronDown,
                  color: context.iconSecondary,
                  size: 22,
                ),
                errorText: hasError ? errorText : null,
              ),
              child: Text(
                value,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueIsPlaceholder
                      ? context.textHint
                      : context.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
