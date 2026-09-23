// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeFeedHash() => r'0f9d68022a66bf9563d60526493c9a6bac43e7de';

/// The single GET /api/home per load. Banners, hot deals, new arrivals and
/// recommended all watch this, so invalidating it refreshes every section
/// with one request.
///
/// Copied from [homeFeed].
@ProviderFor(homeFeed)
final homeFeedProvider = AutoDisposeFutureProvider<HomeFeed?>.internal(
  homeFeed,
  name: r'homeFeedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$homeFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HomeFeedRef = AutoDisposeFutureProviderRef<HomeFeed?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
