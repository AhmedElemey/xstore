import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../cart/presentation/providers/cart_dependencies.dart';
import '../../data/datasources/wishlist_remote_datasource.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/clear_wishlist_usecase.dart';
import '../../domain/usecases/get_wishlist_usecase.dart';
import '../../domain/usecases/move_to_cart_usecase.dart';
import '../../domain/usecases/remove_from_wishlist_usecase.dart';

part 'wishlist_dependencies.g.dart';

@Riverpod(keepAlive: true)
WishlistRemoteDataSource wishlistRemoteDataSource(WishlistRemoteDataSourceRef ref) {
  return WishlistRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
WishlistRepository wishlistRepository(WishlistRepositoryRef ref) {
  return WishlistRepositoryImpl(
    ref.watch(wishlistRemoteDataSourceProvider),
    ref.watch(cartRepositoryProvider),
  );
}

@riverpod
GetWishlistUseCase getWishlistUseCase(GetWishlistUseCaseRef ref) {
  return GetWishlistUseCase(ref.watch(wishlistRepositoryProvider));
}

@riverpod
AddToWishlistUseCase addToWishlistUseCase(AddToWishlistUseCaseRef ref) {
  return AddToWishlistUseCase(ref.watch(wishlistRepositoryProvider));
}

@riverpod
RemoveFromWishlistUseCase removeFromWishlistUseCase(
  RemoveFromWishlistUseCaseRef ref,
) {
  return RemoveFromWishlistUseCase(ref.watch(wishlistRepositoryProvider));
}

@riverpod
MoveToCartUseCase moveToCartUseCase(MoveToCartUseCaseRef ref) {
  return MoveToCartUseCase(ref.watch(wishlistRepositoryProvider));
}

@riverpod
ClearWishlistUseCase clearWishlistUseCase(ClearWishlistUseCaseRef ref) {
  return ClearWishlistUseCase(ref.watch(wishlistRepositoryProvider));
}
