import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../orders/presentation/providers/orders_dependencies.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_or_update_cart_item_usecase.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/apply_coupon_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../../domain/usecases/remove_coupon_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_quantity_usecase.dart';

part 'cart_dependencies.g.dart';

@Riverpod(keepAlive: true)
CartRemoteDataSource cartRemoteDataSource(CartRemoteDataSourceRef ref) {
  return CartRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
CartRepository cartRepository(CartRepositoryRef ref) {
  return CartRepositoryImpl(
    ref.watch(cartRemoteDataSourceProvider),
    ref.watch(ordersRepositoryProvider),
  );
}

@riverpod
GetCartUseCase getCartUseCase(GetCartUseCaseRef ref) {
  return GetCartUseCase(ref.watch(cartRepositoryProvider));
}

@riverpod
AddToCartUseCase addToCartUseCase(AddToCartUseCaseRef ref) {
  return AddToCartUseCase(ref.watch(cartRepositoryProvider));
}

@riverpod
AddOrUpdateCartItemUseCase addOrUpdateCartItemUseCase(
  AddOrUpdateCartItemUseCaseRef ref,
) {
  return AddOrUpdateCartItemUseCase(ref.watch(cartRepositoryProvider));
}

@riverpod
RemoveFromCartUseCase removeFromCartUseCase(RemoveFromCartUseCaseRef ref) {
  return RemoveFromCartUseCase(ref.watch(cartRepositoryProvider));
}

@riverpod
UpdateQuantityUseCase updateQuantityUseCase(UpdateQuantityUseCaseRef ref) {
  return UpdateQuantityUseCase(ref.watch(cartRepositoryProvider));
}

@riverpod
ClearCartUseCase clearCartUseCase(ClearCartUseCaseRef ref) {
  return ClearCartUseCase(ref.watch(cartRepositoryProvider));
}

@riverpod
ApplyCouponUseCase applyCouponUseCase(ApplyCouponUseCaseRef ref) {
  return ApplyCouponUseCase(ref.watch(cartRepositoryProvider));
}

@riverpod
RemoveCouponUseCase removeCouponUseCase(RemoveCouponUseCaseRef ref) {
  return RemoveCouponUseCase(ref.watch(cartRepositoryProvider));
}

@riverpod
PlaceOrderUseCase placeOrderUseCase(PlaceOrderUseCaseRef ref) {
  return PlaceOrderUseCase(ref.watch(cartRepositoryProvider));
}
