import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../commission/presentation/providers/vendor_commission_wallet_provider.dart';
import '../../data/models/listing_model.dart'
    show listingConditionFromToken, listingConditionLabel;
import '../../domain/entities/listing_entity.dart';
import 'listing_dependencies.dart';
import 'listing_form_state.dart';
import 'listing_form_state_extensions.dart';
import 'my_listings_notifier.dart';

part 'listing_form_notifier.g.dart';

const _draftKey = 'xstore_listing_form_draft';
const _maxPhotos = 5;
const _currencyCode = 'EGP';

/// The editable fields captured at loadForEdit() time, compared against the
/// live form state to tell whether the vendor actually changed anything.
/// Deliberately excludes editingListingId/editingStatus (identity, not
/// edited content) and volatile fields (errors/isSubmitting/draftRevision).
typedef _EditSnapshot = ({
  List<String> photoPaths,
  List<String> existingImageUrls,
  String name,
  String priceInput,
  String compareAtPriceInput,
  String description,
  String categoryId,
  String subcategoryId,
  String condition,
  String brand,
  int quantity,
  String location,
  String shippingCostInput,
  bool shippingAvailable,
  List<AttributeEntry> attributes,
});

_EditSnapshot _snapshotOf(ListingFormState s) => (
  photoPaths: List<String>.from(s.photoPaths),
  existingImageUrls: List<String>.from(s.existingImageUrls),
  name: s.name,
  priceInput: s.priceInput,
  compareAtPriceInput: s.compareAtPriceInput,
  description: s.description,
  categoryId: s.categoryId,
  subcategoryId: s.subcategoryId,
  condition: s.condition,
  brand: s.brand,
  quantity: s.quantity,
  location: s.location,
  shippingCostInput: s.shippingCostInput,
  shippingAvailable: s.shippingAvailable,
  attributes: List<AttributeEntry>.from(s.attributes),
);

bool _snapshotsEqual(_EditSnapshot a, _EditSnapshot b) =>
    a.name == b.name &&
    a.priceInput == b.priceInput &&
    a.compareAtPriceInput == b.compareAtPriceInput &&
    a.description == b.description &&
    a.categoryId == b.categoryId &&
    a.subcategoryId == b.subcategoryId &&
    a.condition == b.condition &&
    a.brand == b.brand &&
    a.quantity == b.quantity &&
    a.location == b.location &&
    a.shippingCostInput == b.shippingCostInput &&
    a.shippingAvailable == b.shippingAvailable &&
    listEquals(a.photoPaths, b.photoPaths) &&
    listEquals(a.existingImageUrls, b.existingImageUrls) &&
    listEquals(a.attributes, b.attributes);

@riverpod
class ListingFormNotifier extends _$ListingFormNotifier {
  final ImagePicker _picker = ImagePicker();

  // Set when this autoDispose notifier is torn down (screen popped) so
  // in-flight requests don't write state to a disposed notifier — that
  // throws an unhandled StateError.
  var _disposed = false;

  // Set synchronously by AddListingScreen.initState() right after this
  // notifier is first created (via prepareForEdit), i.e. before any
  // microtask — including _loadDraft's — has had a chance to run. Lets
  // _loadDraft skip itself so a saved create-flow draft never clobbers the
  // listing being edited. The actual state hydration happens separately
  // in loadForEdit, deferred past initState so it never writes `state`
  // synchronously during a widget build phase (Riverpod forbids that).
  ListingEntity? _pendingEditEntity;

  // Snapshot of the edited fields as loaded by loadForEdit(), so canSubmit
  // can tell "nothing changed" apart from "form is valid" — clicking
  // Update on an untouched form still round-trips the whole listing to the
  // backend, which resets it to pending review regardless of what status
  // this client sends back (see ListingFormState.editingStatus's doc).
  // Null when creating a new listing, where there's no "unchanged" concept.
  _EditSnapshot? _editSnapshot;

  String get currencyCode => _currencyCode;

  @override
  ListingFormState build() {
    _disposed = false;
    _pendingEditEntity = null;
    ref.onDispose(() => _disposed = true);
    Future.microtask(_loadDraft);
    return const ListingFormState();
  }

  /// Marks this form as editing [listing] so the pending draft-load skips
  /// itself. Must be called synchronously right after this notifier is
  /// first read (see the field doc above) — it only sets a plain field,
  /// never `state`, so it is safe to call from `initState()`.
  void prepareForEdit(ListingEntity listing) {
    _pendingEditEntity = listing;
  }

  /// Hydrates the form from an existing listing for editing. Call this
  /// deferred (e.g. `Future(() => ...)`), never synchronously from a
  /// widget's `initState`/`build` — see the 2026-08-26 Riverpod-lifecycle
  /// lesson in flutter-review SKILL.md.
  void loadForEdit(ListingEntity listing) {
    if (_disposed) return;
    final compareAt = listing.compareAtPrice;
    final shipping = listing.shippingCost;
    final next = ListingFormState(
      name: listing.titleEn.isNotEmpty ? listing.titleEn : listing.title,
      priceInput: _formatPriceInput(listing.price.toStringAsFixed(2)),
      compareAtPriceInput: (compareAt != null && compareAt > 0)
          ? _formatPriceInput(compareAt.toStringAsFixed(2))
          : '',
      description: listing.descriptionEn.isNotEmpty
          ? listing.descriptionEn
          : listing.description,
      categoryId: listing.categoryId?.toString() ?? '',
      subcategoryId: listing.subcategoryId?.toString() ?? '',
      condition:
          listing.condition != null ? listingConditionLabel(listing.condition!) : '',
      brand: listing.brand,
      quantity: listing.stockQuantity < 1 ? 1 : listing.stockQuantity,
      location: listing.location,
      shippingCostInput:
          shipping > 0 ? _formatPriceInput(shipping.toStringAsFixed(2)) : '',
      shippingAvailable: listing.shippingAvailable,
      attributes: [
        for (final entry in listing.attributes.entries)
          AttributeEntry(key: entry.key, value: entry.value),
      ],
      existingImageUrls: listing.imageUrls,
      editingListingId: listing.id,
      editingStatus: listing.status,
      draftRevision: state.draftRevision + 1,
    );
    _editSnapshot = _snapshotOf(next);
    state = next;
  }

  Future<void> _loadDraft() async {
    if (_pendingEditEntity != null) return;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      if (_disposed) return;
      final raw = prefs.getString(_draftKey);
      if (raw == null || raw.isEmpty) {
        return;
      }
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final next = _stateFromJson(map);
      state = next.copyWith(draftRevision: next.draftRevision + 1);
    } catch (_) {
      // ignore corrupt draft
    }
  }

  ListingFormState _stateFromJson(Map<String, dynamic> m) {
    final attrs = (m['attributes'] as List<dynamic>? ?? [])
        .map(
          (e) => AttributeEntry(
            key: (e as Map)['key'] as String? ?? '',
            value: e['value'] as String? ?? '',
          ),
        )
        .toList();
    return ListingFormState(
      // A draft saved by an older build (or a tampered blob) could carry
      // more than the cap — clamp on restore so the 5-photo limit holds
      // for every listing, not just ones built via addPhotoPath.
      photoPaths: (m['photoPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .take(_maxPhotos)
              .toList() ??
          [],
      name: m['name'] as String? ?? '',
      priceInput: m['priceInput'] as String? ?? '',
      compareAtPriceInput: m['compareAtPriceInput'] as String? ?? '',
      description: m['description'] as String? ?? '',
      categoryId: m['categoryId'] as String? ?? '',
      subcategoryId: m['subcategoryId'] as String? ?? '',
      condition: m['condition'] as String? ?? '',
      brand: m['brand'] as String? ?? '',
      quantity: (m['quantity'] as num?)?.toInt() ?? 1,
      location: m['location'] as String? ?? '',
      shippingCostInput: m['shippingCostInput'] as String? ?? '',
      shippingAvailable: m['shippingAvailable'] as bool? ?? false,
      attributes: attrs,
      draftRevision: m['draftRevision'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _stateToJson(ListingFormState s) {
    return {
      'photoPaths': s.photoPaths,
      'name': s.name,
      'priceInput': s.priceInput,
      'compareAtPriceInput': s.compareAtPriceInput,
      'description': s.description,
      'categoryId': s.categoryId,
      'subcategoryId': s.subcategoryId,
      'condition': s.condition,
      'brand': s.brand,
      'quantity': s.quantity,
      'location': s.location,
      'shippingCostInput': s.shippingCostInput,
      'shippingAvailable': s.shippingAvailable,
      'attributes': s.attributes
          .map((a) => {'key': a.key, 'value': a.value})
          .toList(),
    };
  }

  Future<void> saveDraft() async {
    // Snapshot before awaiting: reading `state` after dispose throws too.
    final snapshot = _stateToJson(state);
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_draftKey, jsonEncode(snapshot));
  }

  int get _remainingPhotoSlots =>
      _maxPhotos - state.photoPaths.length - state.existingImageUrls.length;

  void addPhotoPath(String path) => addPhotoPaths([path]);

  void addPhotoPaths(Iterable<String> paths) {
    final remaining = _remainingPhotoSlots;
    if (remaining <= 0) return;
    final extra = paths.take(remaining).toList();
    if (extra.isEmpty) return;
    state = state.copyWith(
      photoPaths: [...state.photoPaths, ...extra],
      errors: _clearKey(state.errors, 'photos'),
    );
  }

  /// Spec: `addPhoto(File)` — stored as a path in state.
  void addPhoto(File file) => addPhotoPath(file.path);

  void removePhoto(int index) {
    if (index < 0 || index >= state.photoPaths.length) return;
    final next = List<String>.from(state.photoPaths)..removeAt(index);
    state = state.copyWith(photoPaths: next);
  }

  void removeExistingPhoto(int index) {
    if (index < 0 || index >= state.existingImageUrls.length) return;
    final next = List<String>.from(state.existingImageUrls)..removeAt(index);
    state = state.copyWith(existingImageUrls: next);
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    final list = List<String>.from(state.photoPaths);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(photoPaths: list);
  }

  /// Compresses a picked photo before it enters form state. Falls back to
  /// the original path on any compression failure (unsupported format,
  /// codec issue on a specific device) — a listing photo should never be
  /// blocked by compression, only shrunk when possible.
  Future<String> _compressPhoto(String sourcePath) async {
    try {
      final targetPath = '$sourcePath-compressed.jpg';
      final compressed = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: 80,
        minWidth: 1600,
        minHeight: 1600,
      );
      return compressed?.path ?? sourcePath;
    } catch (_) {
      return sourcePath;
    }
  }

  Future<void> pickFromCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (_disposed || file == null) return;
    final path = await _compressPhoto(file.path);
    if (_disposed) return;
    addPhotoPath(path);
  }

  Future<void> pickFromGallery() async {
    final remaining = _remainingPhotoSlots;
    if (remaining <= 0) return;

    // pickMultiImage(limit:) throws ArgumentError when limit < 2, so a
    // single remaining slot has to use the one-image gallery picker.
    final List<XFile> files;
    if (remaining == 1) {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      files = file == null ? const [] : [file];
    } else {
      files = await _picker.pickMultiImage(limit: remaining);
    }
    if (_disposed || files.isEmpty) return;

    final compressed = <String>[];
    for (final file in files.take(remaining)) {
      final path = await _compressPhoto(file.path);
      if (_disposed) return;
      compressed.add(path);
    }
    addPhotoPaths(compressed);
  }

  void updateField(String field, Object? value) {
    final e = Map<String, String>.from(state.errors);
    e.remove(field);
    switch (field) {
      case 'name':
        state = state.copyWith(name: value as String, errors: e);
      case 'description':
        state = state.copyWith(description: value as String, errors: e);
      case 'priceInput':
        e.remove('price');
        e.remove('compareAt');
        state = state.copyWith(
          priceInput: _formatPriceInput(value as String),
          errors: e,
        );
      case 'compareAtPriceInput':
        e.remove('compareAt');
        state = state.copyWith(
          compareAtPriceInput: _formatPriceInput(value as String),
          errors: e,
        );
      case 'category':
      case 'categoryId':
        e.remove('subcategory');
        e.remove('subcategoryId');
        e.remove('brand');
        state = state.copyWith(
          categoryId: value as String,
          subcategoryId: '',
          attributes: const [],
          brand: '',
          errors: e,
        );
      case 'subcategory':
      case 'subcategoryId':
        e.remove('brand');
        state = state.copyWith(
          subcategoryId: value as String,
          brand: '',
          errors: e,
        );
      case 'condition':
        state = state.copyWith(condition: value as String, errors: e);
      case 'brand':
        state = state.copyWith(brand: value as String, errors: e);
      case 'quantity':
        state = state.copyWith(quantity: value as int, errors: e);
      case 'location':
        state = state.copyWith(location: value as String, errors: e);
      case 'shippingAvailable':
        state = state.copyWith(shippingAvailable: value as bool, errors: e);
      case 'shippingCostInput':
        state = state.copyWith(
          shippingCostInput: _formatPriceInput(value as String),
          errors: e,
        );
      default:
        break;
    }
  }

  String _formatPriceInput(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d.]'), '');
    if (digits.isEmpty) {
      return '';
    }
    final parts = digits.split('.');
    var whole = parts.first;
    var dec = parts.length > 1 ? parts.sublist(1).join() : '';
    if (dec.length > 2) {
      dec = dec.substring(0, 2);
    }
    if (whole.isEmpty) {
      whole = '0';
    }
    final buf = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final fromEnd = whole.length - i;
      if (i > 0 && fromEnd % 3 == 0) {
        buf.write(',');
      }
      buf.write(whole[i]);
    }
    if (parts.length > 1) {
      buf.write('.');
      buf.write(dec);
    }
    return buf.toString();
  }

  bool get showCompareAtWarning {
    final p = Validators.parseMoneyInput(state.priceInput);
    final c = Validators.parseMoneyInput(state.compareAtPriceInput);
    if (p == null || c == null) {
      return false;
    }
    if (state.compareAtPriceInput.trim().isEmpty) {
      return false;
    }
    // Backend: CompareAtPrice must be strictly greater than Price.
    return c <= p;
  }

  void addAttribute() {
    state = state.copyWith(
      attributes: [...state.attributes, const AttributeEntry()],
    );
  }

  void removeAttribute(int index) {
    final next = List<AttributeEntry>.from(state.attributes)..removeAt(index);
    state = state.copyWith(attributes: next);
  }

  /// Spec: `updateAttribute(index, key, value)` — pass only fields that change.
  void updateAttribute(int index, {String? key, String? value}) {
    final next = List<AttributeEntry>.from(state.attributes);
    if (index < 0 || index >= next.length) {
      return;
    }
    var row = next[index];
    if (key != null) {
      row = row.copyWith(key: key);
    }
    if (value != null) {
      row = row.copyWith(value: value);
    }
    next[index] = row;
    state = state.copyWith(attributes: next);
  }

  Map<String, String> _clearKey(Map<String, String> m, String k) {
    final n = Map<String, String>.from(m);
    n.remove(k);
    return n;
  }

  ListingFormValidationInput get _validationInput => ListingFormValidationInput(
        photoPaths: state.photoPaths,
        name: state.name,
        priceInput: state.priceInput,
        compareAtPriceInput: state.compareAtPriceInput,
        description: state.description,
        categoryId: state.categoryId,
        subcategoryId: state.subcategoryId,
        condition: state.condition,
        quantity: state.quantity,
        location: state.location,
        shippingAvailable: state.shippingAvailable,
        shippingCostInput: state.shippingCostInput,
        existingPhotoCount: state.existingImageUrls.length,
      );

  double? get _compareAtForSubmit {
    final compareAt = Validators.parseMoneyInput(state.compareAtPriceInput);
    final price = Validators.parseMoneyInput(state.priceInput);
    if (compareAt == null || compareAt <= 0 || price == null) return null;
    if (compareAt <= price) return null;
    return compareAt;
  }

  /// Whether all required fields satisfy validation (no errors written to state).
  /// Drafts skip the dirty-check: submitting a valid draft *is* the
  /// change (draft → pending), even if no field was edited.
  bool get canSubmit =>
      !state.isSubmitting &&
      !Validators.listingFormHasErrors(_validationInput) &&
      (state.editingListingId.isEmpty ||
          hasEditChanges ||
          state.editingStatus == ListingStatus.draft);

  /// Status sent on the edit PUT. Drafts publish as pending (admin
  /// approve is what sets Active — live catalog rows have `reviewedAt`).
  /// Every other edit resends the current status so pause/rejected are
  /// not silently rewritten.
  ListingStatus get statusForUpdate {
    final current = state.editingStatus;
    if (current == null || current == ListingStatus.draft) {
      return ListingStatus.pending;
    }
    return current;
  }

  /// True when editing and the vendor has actually changed something since
  /// loadForEdit() populated the form. Always true outside the edit flow
  /// (create has no "unchanged" concept) or before a snapshot exists.
  bool get hasEditChanges {
    final snapshot = _editSnapshot;
    if (snapshot == null) return true;
    return !_snapshotsEqual(snapshot, _snapshotOf(state));
  }

  bool validate(AppLocalizations l10n) {
    final err = Validators.listingFormErrors(l10n, _validationInput);
    state = state.copyWith(errors: err);
    return err.isEmpty;
  }

  // state.condition is a display token from ListingCategoriesData.conditions
  // via condition_selector.dart; the shared parser also accepts legacy
  // tokens from drafts saved before the 4-value backend alignment.
  ListingCondition? _conditionFromFormValue(String raw) =>
      listingConditionFromToken(raw);

  /// Publishes listing; on success clears form and draft. Returns `true` if published.
  Future<bool> submit(AppLocalizations l10n) async {
    if (!validate(l10n)) {
      return false;
    }

    // Fail-open on loading/error — a network hiccup shouldn't block a
    // vendor from listing. See vendor_commission_wallet_provider.dart.
    final wallet = ref.read(vendorCommissionWalletProvider).valueOrNull;
    if (wallet != null && wallet.isPaused) {
      state = state.copyWith(
        errors: {...state.errors, 'submit': l10n.commissionWalletBlockedSubmit},
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final price = Validators.parseMoneyInput(state.priceInput)!;
      final categoryId = int.tryParse(state.categoryId);
      final subcategoryId = int.tryParse(state.subcategoryId);
      final condition = _conditionFromFormValue(state.condition);
      final shippingCost = state.shippingAvailable ? (state.shippingCost ?? 0) : 0.0;
      final attributesMap = <String, String>{
        for (final a in state.attributes)
          if (a.key.trim().isNotEmpty) a.key.trim(): a.value.trim(),
      };

      if (categoryId == null || condition == null) {
        state = state.copyWith(
          isSubmitting: false,
          errors: {...state.errors, 'submit': l10n.listingValidationFixFields},
        );
        return false;
      }

      final compareAtPrice = _compareAtForSubmit;
      final isEditing = state.editingListingId.isNotEmpty;
      final result = isEditing
          ? await ref.read(updateListingUseCaseProvider).call(
                id: state.editingListingId,
                // ASSUMPTION: single-language form input for now — same
                // string sent for both En/Ar variants until the form gains
                // a dedicated Arabic title/description field.
                titleEn: state.name.trim(),
                titleAr: state.name.trim(),
                descriptionEn: state.description.trim(),
                descriptionAr: state.description.trim(),
                price: price,
                compareAtPrice: compareAtPrice,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                condition: condition,
                brand: state.brand.trim(),
                stockQuantity: state.quantity,
                shippingAvailable: state.shippingAvailable,
                shippingCost: shippingCost,
                location: state.location.trim(),
                attributes: attributesMap,
                // Remaining hosted URLs + any newly picked local files.
                // Status-only resume omits keepImageUrls so images stay
                // untouched; edit always sends the form's remaining set.
                imagePaths: state.photoPaths,
                keepImageUrls: state.existingImageUrls,
                status: statusForUpdate,
              )
          : await ref.read(createListingUseCaseProvider).call(
                // ASSUMPTION: single-language form input for now — same
                // string sent for both En/Ar variants until the form gains
                // a dedicated Arabic title/description field.
                titleEn: state.name.trim(),
                titleAr: state.name.trim(),
                descriptionEn: state.description.trim(),
                descriptionAr: state.description.trim(),
                price: price,
                compareAtPrice: compareAtPrice,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                condition: condition,
                brand: state.brand.trim(),
                stockQuantity: state.quantity,
                shippingAvailable: state.shippingAvailable,
                shippingCost: shippingCost,
                location: state.location.trim(),
                attributes: attributesMap,
                // CONFIRMED (Postman collection): images attach inline as
                // multipart `imageFiles` parts on the create request itself.
                imagePaths: state.photoPaths,
              );

      if (_disposed) return false;
      var success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            isSubmitting: false,
            errors: {
              ...state.errors,
              'submit': _listingSubmitErrorMessage(failure, l10n),
            },
          );
        },
        (listing) {
          success = true;
          ref.read(analyticsServiceProvider).track(
            isEditing
                ? AnalyticsEvents.listingUpdated
                : AnalyticsEvents.listingPublished,
            properties: {
              AnalyticsProps.itemId: listing.id,
              AnalyticsProps.category: listing.categoryLabel,
              AnalyticsProps.priceEgp: listing.price,
            },
          );
          unawaited(_completePublishSuccess());
        },
      );
      return success;
    } catch (e) {
      if (_disposed) return false;
      state = state.copyWith(
        isSubmitting: false,
        errors: {...state.errors, 'submit': e.toString()},
      );
      return false;
    }
  }

  String _listingSubmitErrorMessage(Failure failure, AppLocalizations l10n) {
    final raw = failure.toString();
    // Passed through as the stable code, not translated here — the screen
    // detects it to show an actionable CTA (set location / verify account)
    // instead of a plain Retry snackbar.
    if (raw == storeLocationRequiredErrorCode) return raw;
    if (raw == accountNotVerifiedErrorCode) return raw;
    if (raw.contains('could not save your changes') ||
        raw.contains('saving the entity changes')) {
      return l10n.listingPublishServerError;
    }
    return raw;
  }

  void reset() {
    if (_disposed) return;
    _editSnapshot = null;
    // Bump draftRevision so AddListingScreen's listen re-applies empty
    // text to its controllers. A bare `const ListingFormState()` keeps
    // revision 0, which looks like "no change" when the user typed into
    // the fields without ever loading a draft (the usual publish path).
    state = ListingFormState(draftRevision: state.draftRevision + 1);
  }

  Future<void> _completePublishSuccess() async {
    if (_disposed) return;
    // Reset first so the still-mounted shell tab clears immediately —
    // don't wait on SharedPreferences or the controllers stay filled.
    reset();
    ref.invalidate(myListingsNotifierProvider);
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_draftKey);
  }
}
