import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_entity.freezed.dart';

@freezed
class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    required String id,
    required String name,
    String? iconUrl,
  }) = _CategoryEntity;
}
