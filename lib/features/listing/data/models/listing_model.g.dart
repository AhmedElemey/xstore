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
    );

Map<String, dynamic> _$$ListingModelImplToJson(_$ListingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'status': instance.status,
      'imageUrls': instance.imageUrls,
    };
