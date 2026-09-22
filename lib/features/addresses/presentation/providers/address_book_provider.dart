import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/providers/shared_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';

part 'address_book_provider.g.dart';

/// Single source of truth for a consumer's saved delivery addresses,
/// shared by the Profile "My Addresses" screen and checkout's address step
/// (`checkout_provider.dart`) so an edit made from either place is
/// immediately visible from the other without waiting for a fresh app
/// launch. No backend address book exists yet (order placement only ever
/// takes GPS coordinates), so this stays local, persisted to
/// SharedPreferences per signed-in consumer — the exact mechanism checkout
/// used before this provider existed, kept under the same storage key so
/// addresses saved before this feature shipped are not lost.
@Riverpod(keepAlive: true)
class AddressBook extends _$AddressBook {
  static const _keyPrefix = 'checkout_addresses_v1_';

  /// A saved address book holds at most this many entries — matches the
  /// product limit surfaced by the "Add New Address" affordance in both
  /// the Profile screen and checkout's address step.
  static const maxAddresses = 5;

  // Bumped on logout/user-switch and on dispose, so an in-flight load from
  // a previous session never writes into the next one (mirrors
  // WishlistNotifier._sessionEpoch — keepAlive reuses this instance across
  // invalidation, so a plain flag reset in build() would reopen the gate).
  var _sessionEpoch = 0;
  Future<void>? _loadFuture;
  String? _loadedConsumerId;

  @override
  List<OrderAddress> build() {
    _sessionEpoch++;
    ref.onDispose(() => _sessionEpoch++);
    ref.listen(authProvider, (prev, next) {
      if (next.isLoading) return;
      // `prev` is whatever authProvider's state happened to be at the
      // moment this listener was registered — almost always AsyncLoading,
      // since build() runs before auth's own async restore resolves. That
      // first loading→data resolution is not a user switch; comparing
      // prev/next ids unconditionally treated it as one (prev's id reads
      // as null while loading), wiping and restarting the load on every
      // single cold build. Only react once prev has itself resolved.
      if (prev == null || prev.isLoading) return;
      final prevId = prev.valueOrNull?.id;
      final nextId = next.valueOrNull?.id;
      if (prevId == nextId) return;
      _sessionEpoch++;
      _loadFuture = null;
      _loadedConsumerId = null;
      state = const [];
      unawaited(ensureLoaded());
    });
    unawaited(ensureLoaded());
    return const [];
  }

  /// Idempotent: safe to call from any screen that needs the list loaded
  /// before reading it (e.g. checkout seeding its initial selection) — the
  /// underlying read only ever runs once per signed-in session.
  Future<void> ensureLoaded() => _loadFuture ??= _load();

  Future<void> _load() async {
    final epoch = _sessionEpoch;
    try {
      final consumerId = (await ref.read(authProvider.future))?.id;
      if (epoch != _sessionEpoch || consumerId == null || consumerId.isEmpty) {
        return;
      }
      _loadedConsumerId = consumerId;
      final prefs = await ref.read(sharedPreferencesProvider.future);
      if (epoch != _sessionEpoch) return;
      final raw = prefs.getString('$_keyPrefix$consumerId');
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      final addresses = decoded
          .whereType<Map<String, dynamic>>()
          .map(_addressFromJson)
          .toList();
      if (epoch == _sessionEpoch) state = _normalizeDefault(addresses);
    } catch (_) {
      // Corrupt/unreadable local data, or a failed auth/prefs read — fall
      // back to the honest empty state rather than throwing into whichever
      // screen (or unawaited caller) triggered the load.
    }
  }

  Future<void> _persist() async {
    final consumerId = _loadedConsumerId ?? ref.read(authProvider).valueOrNull?.id;
    if (consumerId == null || consumerId.isEmpty) return;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(
      '$_keyPrefix$consumerId',
      jsonEncode(state.map(_addressToJson).toList()),
    );
  }

  bool get isAtCapacity => state.length >= maxAddresses;

  int get mainIndex => state.indexWhere((a) => a.isDefault);

  /// A non-empty address book always has exactly one entry marked
  /// [OrderAddress.isDefault] — the "main" address checkout preselects for
  /// a new order. Every mutation below routes its result through this so
  /// that invariant can never drift, regardless of what the caller passed.
  List<OrderAddress> _normalizeDefault(
    List<OrderAddress> list, {
    int fallbackIndex = 0,
  }) {
    if (list.isEmpty) return list;
    final defaultIdx = list.indexWhere((a) => a.isDefault);
    if (defaultIdx == -1) {
      final idx = fallbackIndex.clamp(0, list.length - 1);
      return [
        for (var i = 0; i < list.length; i++)
          list[i].copyWith(isDefault: i == idx),
      ];
    }
    final extra = list.indexWhere((a) => a.isDefault, defaultIdx + 1);
    if (extra == -1) return list;
    // More than one entry somehow ended up marked default — keep only the
    // first (shouldn't happen through this notifier's own methods, but
    // guards against a corrupt local-storage read).
    return [
      for (var i = 0; i < list.length; i++)
        list[i].copyWith(isDefault: i == defaultIdx),
    ];
  }

  /// Returns false (and does nothing) once [maxAddresses] is reached — the
  /// "Add New Address" affordance is hidden at capacity in both screens,
  /// this is the defense-in-depth backstop.
  bool addAddress(OrderAddress a) {
    if (isAtCapacity) return false;
    var list = [...state];
    if (a.isDefault) {
      list = list.map((e) => e.copyWith(isDefault: false)).toList();
    }
    list.add(a);
    state = _normalizeDefault(list, fallbackIndex: list.length - 1);
    unawaited(_persist());
    return true;
  }

  void updateAddress(int index, OrderAddress a) {
    if (index < 0 || index >= state.length) return;
    var list = [...state];
    if (a.isDefault) {
      list = list.map((e) => e.copyWith(isDefault: false)).toList();
    }
    list[index] = a;
    state = _normalizeDefault(list, fallbackIndex: index);
    unawaited(_persist());
  }

  void removeAddress(int index) {
    if (index < 0 || index >= state.length) return;
    final list = [...state]..removeAt(index);
    state = _normalizeDefault(list, fallbackIndex: 0);
    unawaited(_persist());
  }

  /// Sets the address at [index] as the main/default one — the entry point
  /// for the Profile "My Addresses" screen; checkout only ever changes the
  /// per-order selection (`checkoutProvider.selectAddress`), never this.
  void setMainAddress(int index) {
    if (index < 0 || index >= state.length) return;
    state = [
      for (var i = 0; i < state.length; i++)
        state[i].copyWith(isDefault: i == index),
    ];
    unawaited(_persist());
  }
}

/// No `OrderAddress` JSON codec exists (the entity is a plain `@freezed`
/// class, not `@JsonSerializable`) — mapped by hand, matching the manual
/// entity<->wire mapping already used throughout the data layer.
Map<String, dynamic> _addressToJson(OrderAddress a) => {
  'fullName': a.fullName,
  'phone': a.phone,
  'street': a.street,
  'city': a.city,
  'wilaya': a.wilaya,
  'postalCode': a.postalCode,
  'isDefault': a.isDefault,
  'latitude': a.latitude,
  'longitude': a.longitude,
  'cityId': a.cityId,
  'governorateId': a.governorateId,
};

OrderAddress _addressFromJson(Map<String, dynamic> json) => OrderAddress(
  fullName: (json['fullName'] ?? '').toString(),
  phone: (json['phone'] ?? '').toString(),
  street: (json['street'] ?? '').toString(),
  city: (json['city'] ?? '').toString(),
  wilaya: (json['wilaya'] ?? '').toString(),
  postalCode: json['postalCode'] as String?,
  isDefault: json['isDefault'] == true,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  cityId: (json['cityId'] as num?)?.toInt(),
  governorateId: (json['governorateId'] as num?)?.toInt(),
);
