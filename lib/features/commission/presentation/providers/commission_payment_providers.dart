import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/commission_payment_remote_datasource.dart';
import '../../data/repositories/commission_payment_repository_impl.dart';
import '../../domain/entities/commission_payment_method.dart';
import '../../domain/repositories/commission_payment_repository.dart';

part 'commission_payment_providers.g.dart';

@Riverpod(keepAlive: true)
CommissionPaymentRepository commissionPaymentRepository(
  CommissionPaymentRepositoryRef ref,
) {
  return CommissionPaymentRepositoryImpl(
    CommissionPaymentRemoteDataSource(ref.watch(dioProvider)),
  );
}

/// Pay-to accounts for the payment screens. A failed or missing setting
/// reads as "none configured" — the screen then tells the vendor to contact
/// support rather than blocking on an error state.
@riverpod
Future<Map<CommissionPaymentMethod, String>> commissionPayToAccounts(
  CommissionPayToAccountsRef ref,
) async {
  final result = await ref
      .watch(commissionPaymentRepositoryProvider)
      .getPayToAccounts();
  return result.getOrElse((_) => const {});
}
