// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchResultModelImpl _$$SearchResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchResultModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      condition: json['condition'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      sellerName: json['sellerName'] as String,
      isSellerVerified: json['isSellerVerified'] as bool,
      location: json['location'] as String,
      hasShipping: json['hasShipping'] as bool,
    );

Map<String, dynamic> _$$SearchResultModelImplToJson(
        _$SearchResultModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'compareAtPrice': instance.compareAtPrice,
      'imageUrl': instance.imageUrl,
      'condition': instance.condition,
      'category': instance.category,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'sellerName': instance.sellerName,
      'isSellerVerified': instance.isSellerVerified,
      'location': instance.location,
      'hasShipping': instance.hasShipping,
    };
