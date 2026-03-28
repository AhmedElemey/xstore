import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/category_entity.dart';
import 'home_dependencies.dart';

part 'categories_provider.g.dart';

@riverpod
class Categories extends _$Categories {
  @override
  Future<List<CategoryEntity>> build() async {
    final result = await ref.watch(getCategoriesUseCaseProvider).call();
    return result.fold(
      (failure) => throw failure,
      (data) => data,
    );
  }
}
