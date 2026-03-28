import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/banner_entity.dart';
import 'home_dependencies.dart';

part 'banners_provider.g.dart';

@riverpod
class Banners extends _$Banners {
  @override
  Future<List<BannerEntity>> build() async {
    final result = await ref.watch(getBannersUseCaseProvider).call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
