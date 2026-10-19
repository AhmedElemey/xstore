import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/features/reports/data/datasources/vendor_reports_remote_datasource.dart';
import 'package:xstore/features/reports/domain/entities/vendor_report_reason.dart';
import 'package:xstore/features/reports/domain/repositories/vendor_reports_repository.dart';
import 'package:xstore/features/reports/domain/usecases/submit_vendor_report_usecase.dart';

class _FakeVendorReportsRepository implements VendorReportsRepository {
  _FakeVendorReportsRepository({this.failWith});

  final Failure? failWith;
  String? lastVendorId;
  String? lastOrderId;
  VendorReportReason? lastReason;
  String? lastComment;

  @override
  Future<Either<Failure, Unit>> submitReport({
    required String vendorId,
    required String orderId,
    required VendorReportReason reason,
    String? comment,
  }) async {
    lastVendorId = vendorId;
    lastOrderId = orderId;
    lastReason = reason;
    lastComment = comment;
    if (failWith != null) return Left(failWith!);
    return const Right(unit);
  }
}

void main() {
  group('VendorReportReason.wireName', () {
    test('maps every reason to its proposed PascalCase wire value', () {
      expect(VendorReportReason.fraud.wireName, 'Fraud');
      expect(
        VendorReportReason.poorProductQuality.wireName,
        'PoorProductQuality',
      );
      expect(
        VendorReportReason.itemNotAsDescribed.wireName,
        'ItemNotAsDescribed',
      );
      expect(
        VendorReportReason.noResponseFromSeller.wireName,
        'NoResponseFromSeller',
      );
      expect(VendorReportReason.harassment.wireName, 'Harassment');
      expect(VendorReportReason.other.wireName, 'Other');
    });
  });

  group('SubmitVendorReportUseCase', () {
    test('forwards all fields to the repository and returns success', () async {
      final repo = _FakeVendorReportsRepository();
      final useCase = SubmitVendorReportUseCase(repo);

      final result = await useCase(
        vendorId: 'vendor_1',
        orderId: 'order_1',
        reason: VendorReportReason.noResponseFromSeller,
        comment: 'No reply for a week',
      );

      expect(result.isRight(), isTrue);
      expect(repo.lastVendorId, 'vendor_1');
      expect(repo.lastOrderId, 'order_1');
      expect(repo.lastReason, VendorReportReason.noResponseFromSeller);
      expect(repo.lastComment, 'No reply for a week');
    });

    test('propagates a repository failure', () async {
      final repo = _FakeVendorReportsRepository(
        failWith: const Failure.server('not implemented'),
      );
      final useCase = SubmitVendorReportUseCase(repo);

      final result = await useCase(
        vendorId: 'vendor_1',
        orderId: 'order_1',
        reason: VendorReportReason.other,
        comment: 'edge case',
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('VendorReportsRemoteDataSourceImpl', () {
    test('POSTs /api/reports/vendor with the Postman body shape', () async {
      RequestOptions? sent;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (o, h) {
              sent = o;
              h.resolve(Response(requestOptions: o, statusCode: 201));
            },
          ),
        );

      await VendorReportsRemoteDataSourceImpl(dio).submitReport(
        vendorId: '7',
        orderId: '42',
        reason: VendorReportReason.fraud,
        comment: '  Took payment, never shipped  ',
      );

      expect(sent!.method, 'POST');
      expect(sent!.path, '/api/reports/vendor');
      expect(sent!.data, {
        'vendorId': 7,
        'orderId': 42,
        'reason': 'Fraud',
        'comment': 'Took payment, never shipped',
      });
    });
  }, skip: MockConfig.useMock ? 'Requires MOCK=false — live wire path' : false);
}
