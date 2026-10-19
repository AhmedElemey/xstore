/// Shipping charged on a cart line.
///
/// Uses the listing's own [listingShippingCost] (what the vendor set on
/// create/edit). Pickup-only listings are 0. Do not invent a platform
/// flat fee or a free-shipping price cutoff — those disagreed with the
/// listing and with every later checkout/place-order total.
double cartLineShippingCost({
  required bool shippingAvailable,
  required double listingShippingCost,
}) {
  if (!shippingAvailable) return 0;
  if (listingShippingCost <= 0) return 0;
  return listingShippingCost;
}
