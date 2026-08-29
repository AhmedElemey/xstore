import 'package:xstore/features/store_categories/data/datasources/store_category_remote_datasource.dart';
import 'package:xstore/features/store_categories/data/models/store_category_model.dart';

/// Fake [StoreCategoryRemoteDataSource] for repository tests — no mocking
/// library is used in this repo, so this mirrors
/// [StubWishlistRemoteDataSource]: each method is backed by an optional
/// callback, and calling an unstubbed method throws so a test never
/// silently exercises behavior it didn't configure.
class StubStoreCategoryRemoteDataSource
    implements StoreCategoryRemoteDataSource {
  StubStoreCategoryRemoteDataSource({
    Future<({List<StoreCategoryModel> items, int totalCount})> Function({
      required int page,
      required int pageSize,
    })? onGetStoreCategories,
  }) : _onGetStoreCategories = onGetStoreCategories;

  final Future<({List<StoreCategoryModel> items, int totalCount})> Function({
    required int page,
    required int pageSize,
  })? _onGetStoreCategories;

  @override
  Future<({List<StoreCategoryModel> items, int totalCount})>
      getStoreCategories({
    required int page,
    required int pageSize,
  }) {
    final cb = _onGetStoreCategories;
    if (cb == null) {
      throw UnimplementedError('getStoreCategories not stubbed');
    }
    return cb(page: page, pageSize: pageSize);
  }
}
