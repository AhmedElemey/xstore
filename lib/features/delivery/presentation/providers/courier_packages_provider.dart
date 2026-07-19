import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/delivery_request_flow.dart';
import '../../domain/entities/delivery_request.dart';
import 'delivery_request_dependencies.dart';

const _sentinel = Object();

class CourierPackagesState {
  const CourierPackagesState({
    this.packages = const [],
    this.isLoading = false,
    this.error,
  });

  final List<DeliveryRequestEntity> packages;
  final bool isLoading;
  final String? error;

  /// Needs cash-collection/pick-up or drop-off, deliveries first (mirrors
  /// `CourierDeliveriesState.activeOrders`).
  List<DeliveryRequestEntity> get activePackages {
    final active = packages.where(isActivePackageTask).toList();
    int rank(DeliveryRequestStatus s) =>
        courierPackageNextAction(s) == CourierPackageAction.deliver ? 0 : 1;
    active.sort((a, b) {
      final r = rank(a.status).compareTo(rank(b.status));
      if (r != 0) return r;
      return b.createdAt.compareTo(a.createdAt);
    });
    return active;
  }

  List<DeliveryRequestEntity> get finishedPackages => packages
      .where((p) => !isActivePackageTask(p))
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  CourierPackagesState copyWith({
    List<DeliveryRequestEntity>? packages,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return CourierPackagesState(
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

/// Courier-side package tasks (assigned requests + pick-up/deliver actions).
class CourierPackagesNotifier extends StateNotifier<CourierPackagesState> {
  CourierPackagesNotifier(this.ref) : super(const CourierPackagesState());

  final Ref ref;

  String? get _courierId {
    final user = ref.read(authProvider).valueOrNull;
    return user?.role == UserRole.courier ? user?.id : null;
  }

  Future<void> fetchPackages() async {
    final courierId = _courierId;
    if (courierId == null) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref
        .read(deliveryRequestRepositoryProvider)
        .getCourierPackages(courierId);
    if (!mounted) return;
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, error: failure.toString()),
      (packages) =>
          state = state.copyWith(isLoading: false, packages: packages),
    );
  }

  Future<void> refreshPackages() => fetchPackages();

  /// Cash collected from the sender + parcel picked up → `pickedUp`.
  Future<bool> markPickedUp(String id) async {
    final snapshot = state.packages;
    final now = DateTime.now();
    _patchPackage(
      id,
      (p) => p.copyWith(
        status: DeliveryRequestStatus.pickedUp,
        pickedUpAt: now,
        updatedAt: now,
      ),
    );
    final result =
        await ref.read(deliveryRequestRepositoryProvider).markPickedUp(id);
    if (!mounted) return false;
    return result.fold((failure) {
      state = state.copyWith(packages: snapshot, error: failure.toString());
      return false;
    }, (package) {
      _mergePackage(package);
      return true;
    });
  }

  /// Parcel handed to the recipient → `delivered`.
  Future<bool> markDelivered(String id) async {
    final snapshot = state.packages;
    final now = DateTime.now();
    _patchPackage(
      id,
      (p) => p.copyWith(
        status: DeliveryRequestStatus.delivered,
        deliveredAt: now,
        updatedAt: now,
      ),
    );
    final result =
        await ref.read(deliveryRequestRepositoryProvider).markDelivered(id);
    if (!mounted) return false;
    return result.fold((failure) {
      state = state.copyWith(packages: snapshot, error: failure.toString());
      return false;
    }, (package) {
      _mergePackage(package);
      return true;
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void _patchPackage(
    String id,
    DeliveryRequestEntity Function(DeliveryRequestEntity) patch,
  ) {
    state = state.copyWith(
      packages:
          state.packages.map((p) => p.id == id ? patch(p) : p).toList(),
    );
  }

  void _mergePackage(DeliveryRequestEntity package) {
    final idx = state.packages.indexWhere((p) => p.id == package.id);
    if (idx < 0) {
      state = state.copyWith(packages: [package, ...state.packages]);
    } else {
      final next = [...state.packages]..[idx] = package;
      state = state.copyWith(packages: next);
    }
  }
}

/// Screen-scoped (autoDispose): the demo data itself lives in the
/// keepAlive datasource, so nothing is lost when the screen closes.
final courierPackagesProvider = StateNotifierProvider.autoDispose<
    CourierPackagesNotifier, CourierPackagesState>(
  (ref) => CourierPackagesNotifier(ref),
);
