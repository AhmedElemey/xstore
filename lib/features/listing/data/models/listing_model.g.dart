// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ListingModelImpl _$$ListingModelImplFromJson(Map<String, dynamic> json) =>
    _$ListingModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String? ?? 'draft',
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      categoryLabel: json['categoryLabel'] as String? ?? '',
      conditionLabel: json['conditionLabel'] as String? ?? '',
      postedAt: json['postedAt'] == null
          ? null
          : DateTime.parse(json['postedAt'] as String),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      saveCount: (json['saveCount'] as num?)?.toInt() ?? 0,
      inquiryCount: (json['inquiryCount'] as num?)?.toInt() ?? 0,
      vendorId: json['vendorId'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      titleAr: json['titleAr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionAr: json['descriptionAr'] as String? ?? '',
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      categoryId: (json['categoryId'] as num?)?.toInt(),
      subcategoryId: (json['subcategoryId'] as num?)?.toInt(),
      condition: json['condition'] as String?,
      brand: json['brand'] as String? ?? '',
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
      shippingAvailable: json['shippingAvailable'] as bool? ?? false,
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      attributes: (json['attributes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
    );

Map<String, dynamic> _$$ListingModelImplToJson(_$ListingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'status': instance.status,
      'imageUrls': instance.imageUrls,
      'categoryLabel': instance.categoryLabel,
      'conditionLabel': instance.conditionLabel,
      'postedAt': instance.postedAt?.toIso8601String(),
      'viewCount': instance.viewCount,
      'saveCount': instance.saveCount,
      'inquiryCount': instance.inquiryCount,
      'vendorId': instance.vendorId,
      'titleEn': instance.titleEn,
      'titleAr': instance.titleAr,
      'descriptionEn': instance.descriptionEn,
      'descriptionAr': instance.descriptionAr,
      'compareAtPrice': instance.compareAtPrice,
      'categoryId': instance.categoryId,
      'subcategoryId': instance.subcategoryId,
      'condition': instance.condition,
      'brand': instance.brand,
      'stockQuantity': instance.stockQuantity,
      'shippingAvailable': instance.shippingAvailable,
      'shippingCost': instance.shippingCost,
      'location': instance.location,
      'attributes': instance.attributes,
    };
