import '../models/search_result_model.dart';

abstract interface class ExploreRemoteDataSource {
  Future<List<SearchResultModel>> searchListings(
    String query,
    int page,
  );

  Future<List<String>> getSuggestions(String query);
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  @override
  Future<List<SearchResultModel>> searchListings(String query, int page) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final base = query.isEmpty ? 'item' : query.toLowerCase();
    return List.generate(6, (i) {
      final idx = (page - 1) * 6 + i;
      return SearchResultModel(
        id: 'ex_$idx',
        name: '$base ${idx + 1}',
        price: 29.99 + idx * 3,
        compareAtPrice: idx.isEven ? 49.99 + idx : null,
        imageUrl: 'https://picsum.photos/seed/ex$idx/400/400',
        condition: idx.isEven ? 'New' : 'Like New',
        category: 'Electronics',
        rating: 4.2 + (idx % 3) * 0.2,
        reviewCount: 12 + idx,
        sellerName: 'Seller $idx',
        isSellerVerified: idx.isEven,
        location: 'Algiers',
        hasShipping: true,
      );
    });
  }

  @override
  Future<List<String>> getSuggestions(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (query.isEmpty) return [];
    return [
      '$query phone',
      '$query case',
      '$query charger',
    ];
  }
}
