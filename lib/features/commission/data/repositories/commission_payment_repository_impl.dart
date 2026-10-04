import 'package:fpdart/fpdart.dart';

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
      return Left(Failure.server(e.toString()));
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
      return Left(Failure.server(e.toString()));
    }
  }
}
