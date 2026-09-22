import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/vendor_report_reason.dart';
import '../repositories/vendor_reports_repository.dart';

class SubmitVendorReportUseCase {
  const SubmitVendorReportUseCase(this._repository);

  final VendorReportsRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String vendorId,
    required String orderId,
    required VendorReportReason reason,
    String? comment,
  }) => _repository.submitReport(
    vendorId: vendorId,
    orderId: orderId,
    reason: reason,
    comment: comment,
  );
}
