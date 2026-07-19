import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/delivery_request.dart';
import 'delivery_request_dependencies.dart';

const _sentinel = Object();

class DeliveryRequestsState {
  const DeliveryRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  final List<DeliveryRequestEntity> requests;
  final bool isLoading;

  /// A create/confirm/cancel mutation is in flight.
  final bool isSubmitting;
  final String? error;

  DeliveryRequestsState copyWith({
    List<DeliveryRequestEntity>? requests,
    bool? isLoading,
    bool? isSubmitting,
    Object? error = _sentinel,
  }) {
    return DeliveryRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

/// Consumer-side package delivery requests (list + lifecycle actions).
class DeliveryRequestsNotifier extends StateNotifier<DeliveryRequestsState> {
  DeliveryRequestsNotifier(this.ref) : super(const DeliveryRequestsState());

  final Ref ref;

  UserEntity? get _consumer {
    final user = ref.read(authProvider).valueOrNull;
    return user?.role == UserRole.consumer ? user : null;
  }

  Future<void> fetchRequests() async {
    final consumer = _consumer;
    if (consumer == null) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref
        .read(deliveryRequestRepositoryProvider)
        .getMyRequests(consumer.id);
    if (!mounted) return;
    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, error: failure.toString()),
      (requests) =>
          state = state.copyWith(isLoading: false, requests: requests),
    );
  }

  Future<void> refreshRequests() => fetchRequests();

  /// Submits a new request; returns true on success (the created request is
  /// prepended to the list).
  Future<bool> createRequest({
    required OrderAddress pickup,
    required OrderAddress dropoff,
    required String packageNote,
  }) async {
    final consumer = _consumer;
    if (consumer == null) return false;
    state = state.copyWith(isSubmitting: true, error: null);
    final result =
        await ref.read(deliveryRequestRepositoryProvider).createRequest(
              consumerId: consumer.id,
              consumerName: consumer.name,
              consumerPhone: consumer.phoneNumber,
              pickup: pickup,
              dropoff: dropoff,
              packageNote: packageNote,
            );
    if (!mounted) return false;
    return result.fold((failure) {
      state =
          state.copyWith(isSubmitting: false, error: failure.toString());
      return false;
    }, (request) {
      state = state.copyWith(
        isSubmitting: false,
        requests: [request, ...state.requests],
      );
      return true;
    });
  }

  /// Consumer accepts the admin's price ("pay cash to courier at pickup").
  Future<bool> confirmRequest(String id) async {
    final snapshot = state.requests;
    final now = DateTime.now();
    _patchRequest(
      id,
      (r) => r.copyWith(
        status: DeliveryRequestStatus.confirmed,
        confirmedAt: now,
        updatedAt: now,
      ),
    );
    final result =
        await ref.read(deliveryRequestRepositoryProvider).confirmRequest(id);
    if (!mounted) return false;
    return result.fold((failure) {
      state = state.copyWith(requests: snapshot, error: failure.toString());
      return false;
    }, (request) {
      _mergeRequest(request);
      return true;
    });
  }

  Future<bool> cancelRequest(String id, String reason) async {
    final snapshot = state.requests;
    final now = DateTime.now();
    _patchRequest(
      id,
      (r) => r.copyWith(
        status: DeliveryRequestStatus.cancelled,
        cancelReason: reason,
        updatedAt: now,
      ),
    );
    final result = await ref
        .read(deliveryRequestRepositoryProvider)
        .cancelRequest(id, reason);
    if (!mounted) return false;
    return result.fold((failure) {
      state = state.copyWith(requests: snapshot, error: failure.toString());
      return false;
    }, (request) {
      _mergeRequest(request);
      return true;
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void _patchRequest(
    String id,
    DeliveryRequestEntity Function(DeliveryRequestEntity) patch,
  ) {
    state = state.copyWith(
      requests:
          state.requests.map((r) => r.id == id ? patch(r) : r).toList(),
    );
  }

  void _mergeRequest(DeliveryRequestEntity request) {
    final idx = state.requests.indexWhere((r) => r.id == request.id);
    if (idx < 0) {
      state = state.copyWith(requests: [request, ...state.requests]);
    } else {
      final next = [...state.requests]..[idx] = request;
      state = state.copyWith(requests: next);
    }
  }
}

/// Screen-scoped (autoDispose): the demo data itself lives in the
/// keepAlive datasource, so nothing is lost when the screen closes.
final deliveryRequestsProvider = StateNotifierProvider.autoDispose<
    DeliveryRequestsNotifier, DeliveryRequestsState>(
  (ref) => DeliveryRequestsNotifier(ref),
);
