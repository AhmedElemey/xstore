import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/vendor_report_reason.dart';

abstract class VendorReportsRepository {
  Future<Either<Failure, Unit>> submitReport({
    required String vendorId,
    required String orderId,
    required VendorReportReason reason,
    String? comment,
  });
}
