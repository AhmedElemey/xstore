import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/localization_provider.dart';
import '../../core/localization/localized_text.dart';
import '../../features/cities/presentation/providers/city_dependencies.dart';
import '../../features/governments/presentation/providers/government_dependencies.dart';
import '../../features/orders/domain/entities/order_entity.dart';

bool _matchesEither(LocalizedText name, String saved) {
  final s = saved.trim().toLowerCase();
  return name.en.trim().toLowerCase() == s || name.ar.trim().toLowerCase() == s;
}

/// Resolves an [OrderAddress]'s city/governorate names in the CURRENT app
/// locale, using [OrderAddress.cityId]/[OrderAddress.governorateId] (the ids
/// the picker resolved them from at save time) rather than the plain
/// [OrderAddress.city]/[OrderAddress.wilaya] strings, which are frozen in
/// whatever language was active when the address was saved and never
/// update on their own when the user switches language.
///
/// Addresses saved before the id fields existed have no id to look up by —
/// for those, falls back to matching the saved name (in either language)
/// against the reference lists, so an old address still re-translates
/// instead of staying frozen until the user re-saves it. Only when neither
/// an id nor a name match resolves (reference lists not loaded yet, or a
/// name that no longer exists in either list) does the frozen string show.
/// Call from a widget's `build` with `ref.watch` (not `ref.read`) so the
/// display updates immediately on a locale change.
({String city, String wilaya}) resolveAddressLocation(
  WidgetRef ref,
  OrderAddress address,
) {
  final isArabic = ref.watch(appIsArabicProvider);
  final cities = ref.watch(allCitiesProvider).valueOrNull;
  final governorates = ref.watch(allGovernmentsProvider).valueOrNull;

  final cityName =
      (address.cityId == null
              ? null
              : cities?.where((c) => c.id == address.cityId).firstOrNull)
          ?.name
          .resolve(isArabic) ??
      cities
          ?.where((c) => _matchesEither(c.name, address.city))
          .firstOrNull
          ?.name
          .resolve(isArabic);
  final governorateName =
      (address.governorateId == null
              ? null
              : governorates
                  ?.where((g) => g.id == address.governorateId)
                  .firstOrNull)
          ?.name
          .resolve(isArabic) ??
      governorates
          ?.where((g) => _matchesEither(g.name, address.wilaya))
          .firstOrNull
          ?.name
          .resolve(isArabic);
  return (city: cityName ?? address.city, wilaya: governorateName ?? address.wilaya);
}
