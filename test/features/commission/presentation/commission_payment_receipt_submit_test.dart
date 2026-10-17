import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/commission/domain/entities/commission_payment_method.dart';
import 'package:xstore/features/commission/domain/repositories/commission_payment_repository.dart';
import 'package:xstore/features/commission/presentation/providers/commission_config_provider.dart';
import 'package:xstore/features/commission/presentation/providers/commission_payment_providers.dart';
import 'package:xstore/features/commission/presentation/providers/vendor_commission_wallet_provider.dart';
import 'package:xstore/features/commission/presentation/screens/commission_payment_receipt_screen.dart';
import 'package:xstore/features/commission/domain/entities/vendor_commission_wallet.dart';
import 'package:xstore/shared/widgets/xstore_button.dart';

class _FakeRepository implements CommissionPaymentRepository {
  _FakeRepository(this.result);

  /// Completes the pending submit; null result answers immediately.
  final Completer<Either<Failure, Unit>> result;
  final submittedPaths = <String>[];

  @override
  Future<Either<Failure, Map<CommissionPaymentMethod, String>>>
  getPayToAccounts() async =>
      const Right({CommissionPaymentMethod.vodafoneCash: '01000000000'});

  @override
  Future<Either<Failure, Unit>> submitPayment({
    required CommissionPaymentMethod method,
    required double amountEgp,
    required String receiptImagePath,
  }) {
    submittedPaths.add(receiptImagePath);
    return result.future;
  }
}

const _pickerChannel = MethodChannel('plugins.flutter.io/image_picker');

/// Stands in for the native compressor: writes [targetPath] and returns it.
class _FakeCompressor extends Fake implements FlutterImageCompressPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    assert(invocation.memberName == #compressAndGetFile);
    final target = invocation.positionalArguments[1] as String;
    File(target).writeAsBytesSync(const [1, 2]);
    return Future<XFile?>.value(XFile(target));
  }
}

void main() {
  late Directory tmpDir;
  late _FakeRepository repository;
  var snapshotLoads = 0;
  var walletLoads = 0;
  var pickCalls = 0;
  Completer<void>? pickGate;
  late String pickedPath;
  late GoRouter router;
  late FlutterImageCompressPlatform compressor;

  setUp(() async {
    tmpDir = await Directory.systemTemp.createTemp('receipt_screen');
    snapshotLoads = 0;
    walletLoads = 0;
    pickCalls = 0;
    pickGate = null;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_pickerChannel, (call) async {
      pickCalls++;
      await pickGate?.future;
      return pickedPath;
    });
    // Compression is unsupported by default, so the original path is kept.
    compressor = FlutterImageCompressPlatform.instance;
    router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SizedBox()),
        GoRoute(
          path: '/receipt',
          builder: (_, __) => const CommissionPaymentReceiptScreen(
            method: CommissionPaymentMethod.vodafoneCash,
          ),
        ),
        GoRoute(
          path: AppRoutes.vendorWallet,
          builder: (_, __) => const Text('wallet screen'),
        ),
      ],
    );
  });

  tearDown(() async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_pickerChannel, null);
    FlutterImageCompressPlatform.instance = compressor;
    router.dispose();
    if (tmpDir.existsSync()) await tmpDir.delete(recursive: true);
  });

  Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
    // Created here, not in setUp: the fake-async zone must own the Completer.
    repository = _FakeRepository(Completer());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          commissionPaymentRepositoryProvider.overrideWithValue(repository),
          vendorCommissionSnapshotProvider.overrideWith((ref) async {
            snapshotLoads++;
            return null;
          }),
          vendorCommissionWalletProvider.overrideWith((ref) async {
            walletLoads++;
            return const VendorCommissionWallet(
              exceedsWarnThreshold: false,
              exceedsPauseThreshold: false,
              warnThresholdEgp: 1,
              pauseThresholdEgp: 2,
            );
          }),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    // The wallet tab keeps these alive; mirror that.
    container
      ..listen(vendorCommissionSnapshotProvider, (_, __) {})
      ..listen(vendorCommissionWalletProvider, (_, __) {});
    router.push('/receipt');
    await tester.pumpAndSettle();
    return container;
  }

  File writeFile(String name, {int bytes = 4}) =>
      File('${tmpDir.path}/$name')..writeAsBytesSync(List.filled(bytes, 1));

  Future<void> pick(WidgetTester tester, File file) async {
    pickedPath = file.path;
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();
  }

  Future<void> fillAmount(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), '100');
    await tester.pump();
  }

  testWidgets('rejects a receipt whose extension the backend does not take', (
    tester,
  ) async {
    await pumpScreen(tester);

    await pick(tester, writeFile('receipt.heic'));

    expect(
      find.text('Use a JPG, PNG or WebP image under 5 MB.'),
      findsOneWidget,
    );
    // Still on the empty pick state.
    expect(find.text('Gallery'), findsOneWidget);
    await fillAmount(tester);
    expect(
      tester.widget<XstoreButton>(find.byType(XstoreButton)).onPressed,
      isNull,
    );
  });

  testWidgets('rejects a receipt over 5 MB', (tester) async {
    await pumpScreen(tester);

    await pick(tester, writeFile('big.jpg', bytes: 5 * 1024 * 1024 + 1));

    expect(
      find.text('Use a JPG, PNG or WebP image under 5 MB.'),
      findsOneWidget,
    );
    expect(find.text('Gallery'), findsOneWidget);
  });

  testWidgets('accepts a png and ignores a second pick while one is running', (
    tester,
  ) async {
    await pumpScreen(tester);
    pickGate = Completer<void>();
    pickedPath = writeFile('receipt.PNG').path;

    await tester.tap(find.text('Gallery'));
    await tester.pump();
    await tester.tap(find.text('Camera'));
    await tester.pump();
    expect(pickCalls, 1);

    pickGate!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Gallery'), findsNothing);
    expect(find.byTooltip('Remove receipt'), findsOneWidget);
  });

  testWidgets('shows an icon when the preview file cannot be decoded', (
    tester,
  ) async {
    await pumpScreen(tester);
    await pick(tester, writeFile('receipt.png'));
    // File reads and image decoding run on real time, not fake time.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  testWidgets('submit success refetches the wallet and opens it', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect((snapshotLoads, walletLoads), (1, 1));
    final file = writeFile('receipt.jpg');
    await pick(tester, file);
    await fillAmount(tester);

    await tester.tap(find.byType(XstoreButton));
    await tester.pump();
    repository.result.complete(const Right(unit));
    await tester.pumpAndSettle();

    expect(repository.submittedPaths, [file.path]);
    expect(snapshotLoads, 2);
    expect(walletLoads, 2);
    expect(find.text('wallet screen'), findsOneWidget);
    // The picker's original is never deleted.
    expect(file.existsSync(), isTrue);
  });

  testWidgets('deletes only our compressed copy after a successful submit', (
    tester,
  ) async {
    final original = writeFile('photo.jpg');
    final compressed = File('${original.path}-compressed.jpg');
    FlutterImageCompressPlatform.instance = _FakeCompressor();
    await pumpScreen(tester);
    await pick(tester, original);
    await fillAmount(tester);
    expect(compressed.existsSync(), isTrue);

    await tester.tap(find.byType(XstoreButton));
    await tester.pump();
    repository.result.complete(const Right(unit));
    await tester.pumpAndSettle();

    expect(repository.submittedPaths, [compressed.path]);
    expect(compressed.existsSync(), isFalse);
    expect(original.existsSync(), isTrue);
  });

  testWidgets('a receipt evicted before submit shows the localized message', (
    tester,
  ) async {
    await pumpScreen(tester);
    final file = writeFile('receipt.jpg');
    await pick(tester, file);
    await fillAmount(tester);
    file.deleteSync();

    await tester.tap(find.byType(XstoreButton));
    await tester.pumpAndSettle();

    expect(repository.submittedPaths, isEmpty);
    expect(
      find.text(
        'The receipt image is no longer available. Please add it again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Gallery'), findsOneWidget);
  });

  testWidgets('back is blocked while submitting and works afterwards', (
    tester,
  ) async {
    await pumpScreen(tester);
    await pick(tester, writeFile('receipt.jpg'));
    await fillAmount(tester);

    await tester.tap(find.byType(XstoreButton));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CommissionPaymentReceiptScreen), findsOneWidget);

    repository.result.complete(const Left(Failure.network('offline')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(CommissionPaymentReceiptScreen), findsNothing);
  });
}
