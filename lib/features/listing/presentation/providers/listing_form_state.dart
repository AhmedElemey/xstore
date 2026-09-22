import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/listing_entity.dart';

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
    /// Bumped when a draft is loaded, the form is reset, or publish
    /// succeeds — Add Listing listens for this to re-sync its
    /// TextEditingControllers (the tab stays mounted in the vendor shell).
    @Default(0) int draftRevision,
    /// Remote photo URLs already on the listing being edited (empty when
    /// creating). Removable in the photo strip; remaining URLs are sent on
    /// update as keepers (`imageUrls[i]`).
    @Default(<String>[]) List<String> existingImageUrls,
    /// Non-empty when this form is editing an existing listing rather than
    /// creating a new one; drives `submit()`'s create-vs-update branch.
    @Default('') String editingListingId,
    /// The listing's current status when editing. Resent unchanged on
    /// update except for drafts, which publish as [ListingStatus.pending]
    /// — Update on a draft is the submit-for-review action, not a
    /// status-preserving edit. Active is set by admin approve.
    ListingStatus? editingStatus,
  }) = _ListingFormState;
}
