import 'listing_form_state.dart';

/// Spec-aligned accessors: storage uses paths/ids/inputs; these mirror naming in requirements.
extension ListingFormStateSpec on ListingFormState {
  double? get shippingCost {
    if (!shippingAvailable || shippingCostInput.trim().isEmpty) {
      return null;
    }
    return double.tryParse(shippingCostInput.replaceAll(',', ''));
  }
}
