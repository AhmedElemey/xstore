import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/commission_payment_method.dart';

abstract class CommissionPaymentRepository {
  /// Where the vendor sends each payment method's money (InstaPay address
  /// or wallet number). Methods the admin hasn't configured are absent.
  Future<Either<Failure, Map<CommissionPaymentMethod, String>>>
  getPayToAccounts();

  /// Files a payment request for admin review. Approval (dashboard) is what
  /// reduces the vendor's owed balance — not this call.
  Future<Either<Failure, Unit>> submitPayment({
    required CommissionPaymentMethod method,
    required double amountEgp,
    required String receiptImagePath,
  });
}
