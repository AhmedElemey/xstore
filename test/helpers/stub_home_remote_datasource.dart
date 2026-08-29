import 'package:xstore/features/home/data/datasources/home_remote_datasource.dart';
import 'package:xstore/features/home/data/models/banner_model.dart';
import 'package:xstore/features/home/data/models/category_model.dart';
import 'package:xstore/features/home/data/models/deal_model.dart';

/// Fake [HomeRemoteDataSource] for repository tests — same callback-per-
/// method, throw-if-unstubbed convention as StubWishlistRemoteDataSource.
class StubHomeRemoteDataSource implements HomeRemoteDataSource {
  StubHomeRemoteDataSource({
    Future<List<BannerModel>> Function()? onFetchBanners,
    Future<List<DealModel>> Function()? onFetchHotDeals,
    Future<List<CategoryModel>> Function()? onFetchCategories,
    Future<HomeAggregate?> Function()? onFetchHomeAggregate,
  })  : _onFetchBanners = onFetchBanners,
        _onFetchHotDeals = onFetchHotDeals,
        _onFetchCategories = onFetchCategories,
        _onFetchHomeAggregate = onFetchHomeAggregate;

  final Future<List<BannerModel>> Function()? _onFetchBanners;
  final Future<List<DealModel>> Function()? _onFetchHotDeals;
  final Future<List<CategoryModel>> Function()? _onFetchCategories;
  final Future<HomeAggregate?> Function()? _onFetchHomeAggregate;

  @override
  Future<List<BannerModel>> fetchBanners() {
    final cb = _onFetchBanners;
    if (cb == null) throw UnimplementedError('fetchBanners not stubbed');
    return cb();
  }

  @override
  Future<List<DealModel>> fetchHotDeals() {
    final cb = _onFetchHotDeals;
    if (cb == null) throw UnimplementedError('fetchHotDeals not stubbed');
    return cb();
  }

  @override
  Future<List<CategoryModel>> fetchCategories() {
    final cb = _onFetchCategories;
    if (cb == null) throw UnimplementedError('fetchCategories not stubbed');
    return cb();
  }

  @override
  Future<HomeAggregate?> fetchHomeAggregate() {
    final cb = _onFetchHomeAggregate;
    if (cb == null) {
      throw UnimplementedError('fetchHomeAggregate not stubbed');
    }
    return cb();
  }
}
