import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_form_state.freezed.dart';

@freezed
class AttributeEntry with _$AttributeEntry {
  const factory AttributeEntry({
    @Default('') String key,
    @Default('') String value,
  }) = _AttributeEntry;
}

@freezed
class ListingFormState with _$ListingFormState {
  const factory ListingFormState({
    /// Persisted image paths (max 5). Use [ListingFormStateSpec.photos] for `List<File>`.
    @Default(<String>[]) List<String> photoPaths,
    @Default('') String name,
    @Default('') String priceInput,
    @Default('') String compareAtPriceInput,
    @Default('') String description,
    @Default('') String categoryId,
    @Default('') String subcategoryId,
    @Default('') String condition,
    @Default('') String brand,
    @Default(1) int quantity,
    @Default('') String location,
    @Default('') String shippingCostInput,
    @Default(false) bool shippingAvailable,
    @Default(<AttributeEntry>[]) List<AttributeEntry> attributes,
    @Default(false) bool isSubmitting,
    @Default(<String, String>{}) Map<String, String> errors,
    /// Incremented when a draft is loaded from storage (for controller sync).
    @Default(0) int draftRevision,
  }) = _ListingFormState;
}
