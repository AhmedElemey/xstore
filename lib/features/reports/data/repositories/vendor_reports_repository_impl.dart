import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/vendor_report_reason.dart';
import '../../domain/repositories/vendor_reports_repository.dart';
import '../datasources/vendor_reports_remote_datasource.dart';

class VendorReportsRepositoryImpl implements VendorReportsRepository {
  VendorReportsRepositoryImpl({required VendorReportsRemoteDataSource remote})
    : _remote = remote;

  final VendorReportsRemoteDataSource _remote;

  @override
  Future<Either<Failure, Unit>> submitReport({
    required String vendorId,
    required String orderId,
    required VendorReportReason reason,
    String? comment,
  }) async {
    try {
      await _remote.submitReport(
        vendorId: vendorId,
        orderId: orderId,
        reason: reason,
        comment: comment,
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}
