import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../data/listing_categories_data.dart';

String listingLocalizedCategoryName(BuildContext context, String categoryId) {
  if (categoryId.isEmpty) {
    return '';
  }
  final l = context.l10n;
  final mapped = switch (categoryId) {
    'electronics' => l.listingCatElectronics,
    'fashion' => l.listingCatFashion,
    'home' => l.listingCatHomeGarden,
    'beauty' => l.listingCatBeauty,
    'sports' => l.listingCatSports,
    'toys' => l.listingCatToys,
    'automotive' => l.listingCatAutomotive,
    'food' => l.listingCatFoodDrinks,
    'books' => l.listingCatBooks,
    'other' => l.listingCatOther,
    _ => null,
  };
  if (mapped != null) {
    return mapped;
  }
  return ListingCategoriesData.categoryById(categoryId)?.name ?? categoryId;
}

String listingLocalizedSubcategoryName(
  BuildContext context,
  String categoryId,
  String subcategoryId,
) {
  if (subcategoryId.isEmpty) {
    return '';
  }
  final l = context.l10n;
  final mapped = switch ((categoryId, subcategoryId)) {
    ('electronics', 'phones') => l.listingSubElectronicsPhones,
    ('electronics', 'laptops') => l.listingSubElectronicsLaptops,
    ('electronics', 'audio') => l.listingSubElectronicsAudio,
    ('electronics', 'accessories') => l.listingSubElectronicsAccessories,
    ('fashion', 'mens') => l.listingSubFashionMens,
    ('fashion', 'womens') => l.listingSubFashionWomens,
    ('fashion', 'kids') => l.listingSubFashionKids,
    ('fashion', 'shoes') => l.listingSubFashionShoes,
    ('home', 'furniture') => l.listingSubHomeFurniture,
    ('home', 'decor') => l.listingSubHomeDecor,
    ('home', 'kitchen') => l.listingSubHomeKitchen,
    ('home', 'garden') => l.listingSubHomeGarden,
    ('beauty', 'skincare') => l.listingSubBeautySkincare,
    ('beauty', 'makeup') => l.listingSubBeautyMakeup,
    ('beauty', 'hair') => l.listingSubBeautyHair,
    ('sports', 'fitness') => l.listingSubSportsFitness,
    ('sports', 'outdoor') => l.listingSubSportsOutdoor,
    ('sports', 'team') => l.listingSubSportsTeam,
    ('toys', 'games') => l.listingSubToysGames,
    ('toys', 'dolls') => l.listingSubToysDolls,
    ('toys', 'educational') => l.listingSubToysEducational,
    ('automotive', 'parts') => l.listingSubAutoParts,
    ('automotive', 'accessories') => l.listingSubAutoAccessories,
    ('automotive', 'care') => l.listingSubAutoCare,
    ('food', 'beverages') => l.listingSubFoodBeverages,
    ('food', 'snacks') => l.listingSubFoodSnacks,
    ('food', 'grocery') => l.listingSubFoodGrocery,
    ('books', 'fiction') => l.listingSubBooksFiction,
    ('books', 'nonfiction') => l.listingSubBooksNonfiction,
    ('books', 'textbooks') => l.listingSubBooksTextbooks,
    ('other', 'misc') => l.listingSubOtherMisc,
    _ => null,
  };
  if (mapped != null) {
    return mapped;
  }
  final cat = ListingCategoriesData.categoryById(categoryId);
  if (cat == null) {
    return subcategoryId;
  }
  for (final s in cat.subcategories) {
    if (s.id == subcategoryId) {
      return s.name;
    }
  }
  return subcategoryId;
}

String listingLocalizedCondition(BuildContext context, String condition) {
  final l = context.l10n;
  return switch (condition) {
    'New' => l.listingCondNew,
    'Like New' => l.listingCondLikeNew,
    'Good' => l.listingCondGood,
    'Used' => l.listingCondUsed,
    'For Parts' => l.listingCondForParts,
    _ => condition,
  };
}
