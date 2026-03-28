import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// API/auth DTO (`fromJson` / generated `toJson`). Domain uses [UserEntity];
/// map with [UserModelX.toEntity] (spec: model ↔ entity, never the reverse).
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    @Default(false) bool isVendor,
    String? token,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        isVendor: isVendor,
      );
}
