import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xstore/features/commission/domain/entities/commission_payment_method.dart';
import 'package:xstore/features/commission/presentation/providers/commission_payment_providers.dart';
import 'package:xstore/features/general_settings/domain/entities/app_settings.dart';
import 'package:xstore/features/general_settings/presentation/providers/general_settings_provider.dart';

import '../../helpers/fake_general_settings.dart';

Future<Map<CommissionPaymentMethod, String>> _accounts(
  AppSettings settings,
) async {
  final c = ProviderContainer(overrides: [readyGeneralSettings(settings)]);
  addTearDown(c.dispose);
  await c.read(generalSettingsProvider.future);
  return c.read(commissionPayToAccountsProvider).requireValue;
}

void main() {
  test('the live settings map all four methods', () async {
    final accounts = await _accounts(
      AppSettings.fromItems(generalSettingsSampleBody['items']! as List),
    );
    expect(accounts, {
      for (final m in CommissionPaymentMethod.values) m: '01019816854',
    });
  });

  test('blank or missing handles are not configured', () async {
    final accounts = await _accounts(
      AppSettings.fromItems(const [
        {'key': 'instapay_handle', 'value': '   ', 'dataType': 'String'},
        {
          'key': 'vodafone_cash_handle',
          'value': ' 0100 ',
          'dataType': 'String',
        },
        {'key': 'orange_cash_handle', 'value': '', 'dataType': 'String'},
      ]),
    );
    expect(accounts, {CommissionPaymentMethod.vodafoneCash: '0100'});
  });
}
