import '../../features/product/domain/entities/product_review_entity.dart';
import 'mock_images.dart';

/// Reviews + [ReviewSummaryEntity] for a listing id (product detail mocks / tests).
class MockReviewBundle {
  const MockReviewBundle({
    required this.reviews,
    required this.summary,
  });

  final List<ProductReviewEntity> reviews;
  final ReviewSummaryEntity summary;
}

ReviewSummaryEntity _buildSummary(List<ProductReviewEntity> reviews) {
  final counts = [0, 0, 0, 0, 0];
  var sum = 0.0;
  for (final r in reviews) {
    final bucket = r.stars.round().clamp(1, 5);
    counts[5 - bucket] += 1;
    sum += r.stars;
  }
  final avg = reviews.isEmpty ? 0.0 : sum / reviews.length;
  return ReviewSummaryEntity(
    average: double.parse(avg.toStringAsFixed(2)),
    totalCount: reviews.length,
    starCounts: counts,
  );
}

ProductReviewEntity _r({
  required String id,
  required String userName,
  required int userSeed,
  required DateTime date,
  required double stars,
  required String text,
  int helpful = 0,
}) {
  return ProductReviewEntity(
    id: id,
    userName: userName,
    userAvatarUrl: MockImages.avatar(userSeed),
    date: date,
    stars: stars,
    text: text,
    helpfulCount: helpful,
  );
}

final Map<String, MockReviewBundle> mockReviewBundlesByListingId = () {
  final now = DateTime.now();
  final out = <String, MockReviewBundle>{};

  final r001 = [
    _r(
      id: 'listing_001_r1',
      userName: 'Karim B.',
      userSeed: 101,
      date: now.subtract(const Duration(days: 15)),
      stars: 5.0,
      text:
          'Excellent condition, exactly as described. Fast shipping and great '
          'packaging. Highly recommend this seller!',
      helpful: 24,
    ),
    _r(
      id: 'listing_001_r2',
      userName: 'Nadia M.',
      userSeed: 102,
      date: now.subtract(const Duration(days: 22)),
      stars: 4.5,
      text:
          'Great phone, minor scratches not visible in photos but overall very '
          'happy with the purchase.',
      helpful: 12,
    ),
    _r(
      id: 'listing_001_r3',
      userName: 'Youcef T.',
      userSeed: 103,
      date: now.subtract(const Duration(days: 31)),
      stars: 4.0,
      text:
          'Good deal for the price. Battery health is at 91% which is acceptable '
          'for a used device.',
      helpful: 8,
    ),
    _r(
      id: 'listing_001_r4',
      userName: 'Amira S.',
      userSeed: 104,
      date: now.subtract(const Duration(days: 45)),
      stars: 5.0,
      text:
          'Seller was very responsive and honest. Product is in perfect '
          'condition. Will buy again!',
      helpful: 19,
    ),
    _r(
      id: 'listing_001_r5',
      userName: 'Riad K.',
      userSeed: 105,
      date: now.subtract(const Duration(days: 60)),
      stars: 3.5,
      text:
          'Decent phone but took longer to arrive than expected. Quality matches '
          'the description.',
      helpful: 5,
    ),
  ];
  out['listing_001'] = MockReviewBundle(
    reviews: r001,
    summary: _buildSummary(r001),
  );

  // listing_002 … listing_010 — five varied reviews each
  final sets = <String, List<List<dynamic>>>{
    'listing_002': [
      ['Samir L.', 5.0, 17, 'Stunning picture quality; install was quick.', 20],
      ['Hela R.', 4.5, 24, 'Slight bezel glow in dark scenes, otherwise great.', 9],
      ['Amine F.', 4.0, 33, 'Packaging was huge, plan space for unboxing.', 6],
      ['Yousra D.', 5.0, 41, 'Seller coordinated delivery timing clearly.', 15],
      ['Khaled Z.', 3.5, 52, 'Good TV; remote feels a bit cheap.', 4],
    ],
    'listing_003': [
      ['Rania B.', 5.0, 11, 'True to size and very comfortable for long walks.', 30],
      ['Sofiane M.', 4.0, 22, 'Minor glue line visible up close; still solid.', 7],
      ['Lydia K.', 4.5, 33, 'Arrived fast, authentic box and tags.', 11],
      ['Hichem A.', 5.0, 44, 'Love the Air bubble cushioning.', 18],
      ['Imene S.', 3.0, 55, 'Stiffer than expected at first; breaking in now.', 3],
    ],
    'listing_004': [
      ['Yacine P.', 4.5, 12, 'Beautiful leather smell and sturdy frame.', 14],
      ['Meriem Q.', 4.0, 23, 'A few scuffs on the legs as described.', 8],
      ['Walid H.', 4.5, 34, 'Perfect size for our living room.', 10],
      ['Nabil E.', 5.0, 45, 'Seller helped load into the van — appreciated.', 22],
      ['Sabrina T.', 3.5, 56, 'Heavier than expected; worth it for quality.', 5],
    ],
    'listing_005': [
      ['Djamel O.', 5.0, 13, 'Blazing fast for Xcode builds and video edits.', 28],
      ['Fatma Z.', 4.5, 24, 'Battery life is excellent on Sonoma.', 12],
      ['Issam C.', 5.0, 35, 'Display is gorgeous; no dead pixels.', 19],
      ['Dalila N.', 4.0, 46, 'Included charger was third-party, not Apple.', 7],
      ['Reda V.', 4.5, 57, 'Pricey but condition matched listing photos.', 9],
    ],
    'listing_006': [
      ['Amina J.', 5.0, 14, 'Laser head is useful on dusty tiles.', 16],
      ['Selim G.', 4.5, 25, 'A bit loud on max but cleans deeply.', 11],
      ['Lamia I.', 4.0, 36, 'Battery meets the advertised runtime here.', 6],
      ['Tarik U.', 5.0, 47, 'Registered warranty without issues.', 13],
      ['Hayat Y.', 3.5, 58, 'Heavier than older V8; performance wins.', 5],
    ],
    'listing_007': [
      ['Ikram W.', 5.0, 15, 'Boost midsole feels springy on long runs.', 21],
      ['Farid X.', 4.0, 26, 'Narrow toe box — size up if unsure.', 8],
      ['Souhila A.', 4.5, 37, 'Authentic pair; barcode checked.', 14],
      ['Mounir B.', 4.5, 48, 'Great for treadmill sessions.', 10],
      ['Celia D.', 3.5, 59, 'Upper creased quickly but still comfy.', 4],
    ],
    'listing_008': [
      ['Anis E.', 5.0, 16, 'Perfect travel camera; AF snaps faces fast.', 17],
      ['Nesrine F.', 4.5, 27, 'Kit lens is sharp enough for beginners.', 9],
      ['Adel G.', 4.0, 38, 'Menu takes a day to learn; worth it.', 6],
      ['Yasmine H.', 5.0, 49, 'Seller included screen protectors.', 15],
      ['Bilal I.', 3.5, 60, '4K overheats sooner than expected in sun.', 5],
    ],
    'listing_009': [
      ['Othman J.', 5.0, 17, 'Quiet fan, loads Demon’s Souls in seconds.', 40],
      ['Ines K.', 5.0, 28, 'Controllers feel brand new.', 32],
      ['Mehdi L.', 4.5, 39, 'Disc drive whisper-quiet.', 18],
      ['Sara M.', 4.0, 50, 'Packaging was reused but console pristine.', 7],
      ['Fouad N.', 3.5, 61, 'Had to update firmware before first game.', 4],
    ],
    'listing_010': [
      ['Leila O.', 4.5, 18, 'Print is vibrant and fabric breathable.', 12],
      ['Rachid P.', 4.0, 29, 'Fits true for Zara size M.', 9],
      ['Hania Q.', 5.0, 40, 'Great for weekend brunches outdoors.', 20],
      ['Tahar R.', 4.0, 51, 'Needs ironing after washing cold.', 6],
      ['Cyrine S.', 3.5, 62, 'Hem sits slightly long on me.', 5],
    ],
  };

  sets.forEach((listingId, rows) {
    final reviews = <ProductReviewEntity>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      reviews.add(
        _r(
          id: '${listingId}_r${i + 1}',
          userName: row[0] as String,
          userSeed: row[2] as int,
          date: now.subtract(Duration(days: 12 + i * 9)),
          stars: (row[1] as num).toDouble(),
          text: row[3] as String,
          helpful: row[4] as int,
        ),
      );
    }
    out[listingId] = MockReviewBundle(
      reviews: reviews,
      summary: _buildSummary(reviews),
    );
  });

  return out;
}();

MockReviewBundle? mockReviewsForListing(String listingId) =>
    mockReviewBundlesByListingId[listingId];
