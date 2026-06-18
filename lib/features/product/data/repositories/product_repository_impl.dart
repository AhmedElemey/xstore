import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/mock/mock_config.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../home/domain/entities/deal_entity.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../datasources/product_remote_datasource.dart';
import '../../domain/entities/product_detail_entity.dart';
import '../../domain/entities/product_review_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/entities/product_seller_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(
    this._homeRepository, {
    required ProductRemoteDataSource remote,
  }) : _remote = remote;

  final HomeRepository _homeRepository;
  final ProductRemoteDataSource _remote;

  @override
  Future<Either<Failure, ProductDetailEntity>> getProductDetail(String id) async {
    if (!MockConfig.useMock) {
      try {
        return Right(await _remote.fetchProductDetail(id));
      } catch (e) {
        return Left(Failure.server(e.toString()));
      }
    }
    final dealsResult = await _homeRepository.getHotDeals();
    return dealsResult.fold(Left.new, (deals) {
      DealEntity? match;
      for (final d in deals) {
        if (d.id == id) {
          match = d;
          break;
        }
      }
      if (match != null) {
        return Right(_fromDeal(match, deals));
      }
      return Right(_fallbackDetail(id, deals));
    });
  }

  ProductDetailEntity _fromDeal(DealEntity deal, List<DealEntity> allDeals) {
    final price = deal.price;
    final discount = deal.discountPercent;
    final compare = discount > 0 ? price / (1 - discount / 100) : null;
    final stock = deal.id == 'd1' ? 3 : 24;
    final listing = ListingEntity(
      id: deal.id,
      title: deal.title,
      description: _longDescription(deal.title),
      price: price,
      status: ListingStatus.active,
      imageUrls: _galleryFor(deal.id, deal.imageUrl),
      categoryLabel: 'Electronics',
      conditionLabel: deal.id == 'd1' ? 'Like New' : 'New',
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
      viewCount: 420,
      saveCount: 88,
      inquiryCount: 12,
    );

    return ProductDetailEntity(
      listing: listing,
      compareAtPrice: compare,
      stockQuantity: stock,
      locationLine: '📍 Algiers, Egypt',
      seller: _sellerFor(deal.id),
      specifications: _specsFor(deal.id),
      reviewSummary: _summary,
      reviews: _reviewsFor(deal.id),
      similarProducts: allDeals.where((d) => d.id != deal.id).toList(),
    );
  }

  ProductDetailEntity _fallbackDetail(String id, List<DealEntity> allDeals) {
    final listing = ListingEntity(
      id: id,
      title: 'Product $id',
      description: _longDescription('Product'),
      price: 99.99,
      status: ListingStatus.active,
      imageUrls: _galleryFor(id, null),
      categoryLabel: 'General',
      conditionLabel: 'New',
      postedAt: DateTime.now(),
      viewCount: 10,
      saveCount: 1,
      inquiryCount: 0,
    );
    return ProductDetailEntity(
      listing: listing,
      compareAtPrice: 129.99,
      stockQuantity: 12,
      locationLine: '📍 Algiers, Egypt',
      seller: _sellerFor(id),
      specifications: _specsFor('default'),
      reviewSummary: _summary,
      reviews: _reviewsFor('default'),
      similarProducts: allDeals,
    );
  }

  List<String> _galleryFor(String id, String? primary) {
    final base = primary ?? 'https://picsum.photos/seed/${id}x/800/800';
    return [
      base,
      'https://picsum.photos/seed/${id}g2/800/800',
      'https://picsum.photos/seed/${id}g3/800/800',
    ];
  }

  ProductSellerEntity _sellerFor(String id) {
    if (MockConfig.useMock) {
      return ProductSellerEntity(
        id: mockVendorUser.id,
        name: mockVendorUser.storeName ?? mockVendorUser.name,
        avatarUrl: mockVendorUserModel().avatarUrl ?? '',
        rating: mockVendorUser.rating ?? 4.8,
        salesCount: mockVendorUser.totalSales ?? 142,
        verified: mockVendorUser.isVerified,
      );
    }
    return ProductSellerEntity(
      id: 'seller_${id.hashCode}',
      name: 'TechCorner Store',
      avatarUrl: '',
      rating: 4.9,
      salesCount: 230,
      verified: true,
    );
  }

  Map<String, String> _specsFor(String id) {
    final isPhone = id == 'd1' || id == 'default';
    if (isPhone) {
      return const {
        'Brand': 'Apple',
        'Model': 'iPhone 15 Pro',
        'Storage': '256GB',
        'Color': 'Natural Titanium',
        'Condition': 'Like New',
      };
    }
    return const {
      'Brand': 'FitGear',
      'Model': 'Series 7',
        'Display': '1.8" AMOLED',
      'Battery': '7 days',
      'Condition': 'New',
    };
  }

  List<ProductReviewEntity> _reviewsFor(String id) {
    final av =
        'https://picsum.photos/seed/u$id${id.hashCode}/64/64';
    return [
      ProductReviewEntity(
        id: 'r1',
        userName: 'Samir K.',
        userAvatarUrl: av,
        date: DateTime.now().subtract(const Duration(days: 4)),
        stars: 5,
        text:
            'Arrived quickly and exactly as described. Packaging was great and the item looks pristine.',
        helpfulCount: 24,
      ),
      ProductReviewEntity(
        id: 'r2',
        userName: 'Lina M.',
        userAvatarUrl: av,
        date: DateTime.now().subtract(const Duration(days: 18)),
        stars: 4,
        text:
            'Very satisfied overall. Minor scuff on the box but product itself is flawless.',
        helpfulCount: 11,
      ),
      ProductReviewEntity(
        id: 'r3',
        userName: 'Omar B.',
        userAvatarUrl: av,
        date: DateTime.now().subtract(const Duration(days: 40)),
        stars: 5,
        text: 'Great seller, fast replies. Would buy again.',
        helpfulCount: 6,
      ),
    ];
  }

  static final ReviewSummaryEntity _summary = ReviewSummaryEntity(
    average: 4.7,
    totalCount: 1230,
    starCounts: const [820, 210, 120, 50, 30],
  );

  String _longDescription(String title) {
    return '$title — premium quality with trusted warranty and support. '
        'Designed for everyday use with reliable performance and modern finishes. '
        'This description is intentionally long so the product page can demonstrate '
        'a collapsible “Read more” area before expanding the full text for buyers '
        'who want every detail before they purchase.';
  }

  @override
  Future<Either<Failure, List<ProductDetailEntity>>> getSimilarProducts({
    required String productId,
    required String category,
  }) async {
    if (!MockConfig.useMock) {
      try {
        return Right(
          await _remote.fetchSimilarProducts(
            productId: productId,
            category: category,
          ),
        );
      } catch (e) {
        return Left(Failure.server(e.toString()));
      }
    }
    final dealsResult = await _homeRepository.getHotDeals();
    return dealsResult.fold(Left.new, (deals) {
      final filtered = deals.where((d) => d.id != productId).take(5);
      return Right(
        filtered
            .map(
              (d) => _fromDeal(d, deals).copyWith(
                similarProducts: const [],
                reviews: const [],
                reviewSummary: null,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(String productId) async {
    if (!MockConfig.useMock) {
      try {
        return Right(await _remote.fetchProductReviews(productId));
      } catch (e) {
        return Left(Failure.server(e.toString()));
      }
    }
    final reviews = _reviewsFor(productId);
    return Right(
      reviews
          .map(
            (r) => ReviewEntity(
              id: r.id,
              userId: 'user_${r.id}',
              userName: r.userName,
              userAvatar: r.userAvatarUrl,
              rating: r.stars,
              comment: r.text,
              helpfulCount: r.helpfulCount,
              createdAt: r.date,
            ),
          )
          .toList(),
    );
  }
}
