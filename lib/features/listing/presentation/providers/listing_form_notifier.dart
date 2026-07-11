import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../../commission/presentation/providers/vendor_commission_wallet_provider.dart';
import '../../domain/entities/listing_entity.dart';
import '../data/listing_categories_data.dart';
import 'listing_dependencies.dart';
import 'listing_form_state.dart';
import 'listing_form_state_extensions.dart';
import 'my_listings_notifier.dart';

part 'listing_form_notifier.g.dart';

const _draftKey = 'xstore_listing_form_draft';
const _maxPhotos = 5;
const _currencyCode = 'EGP';

@riverpod
class ListingFormNotifier extends _$ListingFormNotifier {
  final ImagePicker _picker = ImagePicker();

  String get currencyCode => _currencyCode;

  @override
  ListingFormState build() {
    Future.microtask(_loadDraft);
    return const ListingFormState();
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
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
      photoPaths: (m['photoPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
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
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_draftKey, jsonEncode(_stateToJson(state)));
  }

  void addPhotoPath(String path) {
    if (state.photoPaths.length >= _maxPhotos) {
      return;
    }
    final next = [...state.photoPaths, path];
    state = state.copyWith(photoPaths: next, errors: _clearKey(state.errors, 'photos'));
  }

  /// Spec: `addPhoto(File)` — stored as a path in state.
  void addPhoto(File file) => addPhotoPath(file.path);

  void removePhoto(int index) {
    final next = List<String>.from(state.photoPaths)..removeAt(index);
    state = state.copyWith(photoPaths: next);
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

  Future<void> pickFromCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      addPhoto(File(file.path));
    }
  }

  Future<void> pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      addPhoto(File(file.path));
    }
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
        state = state.copyWith(
          priceInput: _formatPriceInput(value as String),
          errors: e,
        );
      case 'compareAtPriceInput':
        state = state.copyWith(
          compareAtPriceInput: _formatPriceInput(value as String),
          errors: e,
        );
      case 'category':
      case 'categoryId':
        final id = value as String;
        final cat = ListingCategoriesData.categoryById(id);
        final hints = cat?.attributeHints ?? [];
        final newAttrs = hints
            .map((h) => AttributeEntry(key: h, value: ''))
            .toList();
        state = state.copyWith(
          categoryId: id,
          subcategoryId: '',
          attributes: newAttrs,
          errors: e,
        );
      case 'subcategory':
      case 'subcategoryId':
        state = state.copyWith(subcategoryId: value as String, errors: e);
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
    return c < p;
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

  void updateAttributeKey(int index, String key) =>
      updateAttribute(index, key: key);

  void updateAttributeValue(int index, String value) =>
      updateAttribute(index, value: value);

  Map<String, String> _clearKey(Map<String, String> m, String k) {
    final n = Map<String, String>.from(m);
    n.remove(k);
    return n;
  }

  ListingFormValidationInput get _validationInput => ListingFormValidationInput(
        photoPaths: state.photoPaths,
        name: state.name,
        priceInput: state.priceInput,
        description: state.description,
        categoryId: state.categoryId,
        subcategoryId: state.subcategoryId,
        condition: state.condition,
        quantity: state.quantity,
        location: state.location,
        shippingAvailable: state.shippingAvailable,
        shippingCostInput: state.shippingCostInput,
      );

  /// Whether all required fields satisfy validation (no errors written to state).
  bool get canSubmit =>
      !state.isSubmitting && !Validators.listingFormHasErrors(_validationInput);

  bool validate(AppLocalizations l10n) {
    final err = Validators.listingFormErrors(l10n, _validationInput);
    state = state.copyWith(errors: err);
    return err.isEmpty;
  }

  ListingCondition? _conditionFromFormValue(String raw) {
    // state.condition is a free display string sourced from
    // ListingCategoriesData.conditions ('New','Like New','Good','Used',
    // 'For Parts') via condition_selector.dart — map it to the enum here
    // rather than changing the selector widget's value domain.
    switch (raw) {
      case 'New':
        return ListingCondition.newItem;
      case 'Like New':
        return ListingCondition.likeNew;
      case 'Good':
        return ListingCondition.good;
      case 'Used':
        return ListingCondition.used;
      case 'For Parts':
        return ListingCondition.forParts;
      default:
        return null;
    }
  }

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
      final compareAt = Validators.parseMoneyInput(state.compareAtPrice);
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

      final useCase = ref.read(createListingUseCaseProvider);
      final result = await useCase(
        // ASSUMPTION: single-language form input for now — same string sent
        // for both En/Ar variants until the form gains a dedicated Arabic
        // title/description field.
        titleEn: state.name.trim(),
        titleAr: state.name.trim(),
        descriptionEn: state.description.trim(),
        descriptionAr: state.description.trim(),
        price: price,
        compareAtPrice: (compareAt != null && compareAt > 0) ? compareAt : null,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        condition: condition,
        brand: state.brand.trim(),
        stockQuantity: state.quantity,
        shippingAvailable: state.shippingAvailable,
        shippingCost: shippingCost,
        location: state.location.trim(),
        attributes: attributesMap,
        // NOTE (known gap): no image-upload endpoint exists in the backend
        // yet. photoPaths remain local-only for in-form preview; imageUrls
        // is sent empty until an upload endpoint is confirmed and wired.
        imageUrls: const [],
      );

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
        (_) {
          success = true;
          unawaited(_completePublishSuccess());
        },
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errors: {...state.errors, 'submit': e.toString()},
      );
      return false;
    }
  }

  /// Spec: `submit` as [AsyncValue] — use with `ref.listen` / UI that expects `AsyncValue<void>`.
  Future<AsyncValue<void>> submitAsync(AppLocalizations l10n) async {
    return AsyncValue.guard(() async {
      final ok = await submit(l10n);
      if (!ok) {
        final msg = state.errors['submit'] ??
            (state.errors.isNotEmpty ? state.errors.values.first : null) ??
            l10n.listingValidationFixFields;
        throw Exception(msg);
      }
    });
  }

  List<String> brandSuggestionsFor(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return ListingCategoriesData.brandSuggestions.take(8).toList();
    }
    return ListingCategoriesData.brandSuggestions
        .where((b) => b.toLowerCase().contains(q))
        .take(8)
        .toList();
  }

  void clearSubmitError() {
    state = state.copyWith(
      errors: _clearKey(state.errors, 'submit'),
    );
  }

  String _listingSubmitErrorMessage(Failure failure, AppLocalizations l10n) {
    final raw = failure.toString();
    if (raw.contains('could not save your changes') ||
        raw.contains('saving the entity changes')) {
      return l10n.listingPublishServerError;
    }
    return raw;
  }

  void reset() {
    state = const ListingFormState();
  }

  Future<void> _completePublishSuccess() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_draftKey);
    state = const ListingFormState();
    ref.invalidate(myListingsNotifierProvider);
  }
}
