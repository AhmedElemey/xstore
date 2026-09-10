/// Per-item flat shipping rule: a listing priced at or above this
/// threshold ships free; anything cheaper pays the flat shipping fee
/// below. This is a per-listing price cutoff, not a cart-subtotal
/// "spend X, ship free" threshold.
///
/// The backend has no delivery-fee/shipping-rate endpoint, so this is
/// computed client-side — kept in one place so the cart summary's
/// free-shipping note always matches what the datasource actually
/// charges, instead of two independent copies of the same number
/// drifting apart.
const double kFreeShippingPriceThresholdEgp = 20000.0;

/// Flat shipping fee (EGP) charged on a listing priced below
/// [kFreeShippingPriceThresholdEgp].
const double kFlatShippingFeeEgp = 500.0;
