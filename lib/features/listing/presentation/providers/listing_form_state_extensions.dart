import 'dart:io';

import 'listing_form_state.dart';

/// Spec-aligned accessors: storage uses paths/ids/inputs; these mirror naming in requirements.
extension ListingFormStateSpec on ListingFormState {
  /// Same as [photoPaths], as [File] instances (paths may be invalid after restart).
  List<File> get photos => photoPaths.map(File.new).toList();

  String get price => priceInput;

  String get compareAtPrice => compareAtPriceInput;

  String get category => categoryId;

  String get subcategory => subcategoryId;

  double? get shippingCost {
    if (!shippingAvailable || shippingCostInput.trim().isEmpty) {
      return null;
    }
    return double.tryParse(shippingCostInput.replaceAll(',', ''));
  }
}
