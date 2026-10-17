import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/commission_payment_method.dart';
import '../../domain/repositories/commission_payment_repository.dart';
import '../datasources/commission_payment_remote_datasource.dart';

class CommissionPaymentRepositoryImpl implements CommissionPaymentRepository {
  CommissionPaymentRepositoryImpl(this._remote);

  final CommissionPaymentRemoteDataSource _remote;

  @override
  Future<Either<Failure, Map<CommissionPaymentMethod, String>>>
  getPayToAccounts() async {
    try {
      return Right(await _remote.getPayToAccounts());
    } catch (e) {
      return Left(_failure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitPayment({
    required CommissionPaymentMethod method,
    required double amountEgp,
    required String receiptImagePath,
  }) async {
    try {
      await _remote.submitPayment(
        method: method,
        amountEgp: amountEgp,
        receiptImagePath: receiptImagePath,
      );
      return const Right(unit);
    } catch (e) {
      return Left(_failure(e));
    }
  }

  /// Datasource errors carry user-facing text; anything else (a parse
  /// error, a FileSystemException) gets no message so the screen falls back
  /// to its localized generic error instead of showing `e.toString()`.
  Failure _failure(Object e) =>
      Failure.server(e is AppException ? e.message : null);
}
