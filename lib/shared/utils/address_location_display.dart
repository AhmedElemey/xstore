import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/localization_provider.dart';
import '../../features/cities/presentation/providers/city_dependencies.dart';
import '../../features/governments/presentation/providers/government_dependencies.dart';
import '../../features/orders/domain/entities/order_entity.dart';

/// Resolves an [OrderAddress]'s city/governorate names in the CURRENT app
/// locale, using [OrderAddress.cityId]/[OrderAddress.governorateId] (the ids
/// the picker resolved them from at save time) rather than the plain
/// [OrderAddress.city]/[OrderAddress.wilaya] strings, which are frozen in
/// whatever language was active when the address was saved and never
/// update on their own when the user switches language.
///
/// Falls back to those frozen strings when the ids are missing (addresses
/// saved before this field existed) or the reference lists haven't
/// resolved yet / no longer contain that id. Call from a widget's `build`
/// with `ref.watch` (not `ref.read`) so the display updates immediately on
/// a locale change.
({String city, String wilaya}) resolveAddressLocation(
  WidgetRef ref,
  OrderAddress address,
) {
  final isArabic = ref.watch(appIsArabicProvider);
  final cityName = address.cityId == null
      ? null
      : ref
          .watch(allCitiesProvider)
          .valueOrNull
          ?.where((c) => c.id == address.cityId)
          .firstOrNull
          ?.name
          .resolve(isArabic);
  final governorateName = address.governorateId == null
      ? null
      : ref
          .watch(allGovernmentsProvider)
          .valueOrNull
          ?.where((g) => g.id == address.governorateId)
          .firstOrNull
          ?.name
          .resolve(isArabic);
  return (city: cityName ?? address.city, wilaya: governorateName ?? address.wilaya);
}
