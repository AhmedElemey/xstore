// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DealModelImpl _$$DealModelImplFromJson(Map<String, dynamic> json) =>
    _$DealModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$DealModelImplToJson(_$DealModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'discountPercent': instance.discountPercent,
    };
