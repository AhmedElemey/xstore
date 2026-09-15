import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/vendor_reports_remote_datasource.dart';
import '../../data/repositories/vendor_reports_repository_impl.dart';
import '../../domain/repositories/vendor_reports_repository.dart';
import '../../domain/usecases/submit_vendor_report_usecase.dart';

part 'vendor_reports_dependencies.g.dart';

@Riverpod(keepAlive: true)
VendorReportsRemoteDataSource vendorReportsRemoteDataSource(
  VendorReportsRemoteDataSourceRef ref,
) {
  return VendorReportsRemoteDataSourceImpl(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
VendorReportsRepository vendorReportsRepository(
  VendorReportsRepositoryRef ref,
) {
  return VendorReportsRepositoryImpl(
    remote: ref.watch(vendorReportsRemoteDataSourceProvider),
  );
}

@riverpod
SubmitVendorReportUseCase submitVendorReportUseCase(
  SubmitVendorReportUseCaseRef ref,
) {
  return SubmitVendorReportUseCase(ref.watch(vendorReportsRepositoryProvider));
}
