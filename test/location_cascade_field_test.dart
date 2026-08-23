import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/localization/localized_text.dart';
import 'package:xstore/features/cities/domain/entities/city_entity.dart';
import 'package:xstore/features/cities/presentation/providers/city_dependencies.dart';
import 'package:xstore/features/governments/domain/entities/government_entity.dart';
import 'package:xstore/features/governments/presentation/providers/government_dependencies.dart';
import 'package:xstore/shared/widgets/location_cascade_field.dart';

const _cairoGov = GovernmentEntity(
  id: 16,
  name: LocalizedText(en: 'Cairo', ar: 'القاهرة'),
);
const _alexGov = GovernmentEntity(
  id: 15,
  name: LocalizedText(en: 'Alexandria', ar: 'الإسكندرية'),
);
const _cairoCity = CityEntity(
  id: 1,
  name: LocalizedText(en: 'Cairo City', ar: 'مدينة القاهرة'),
  governorateId: 16,
);
const _alexCity = CityEntity(
  id: 2,
  name: LocalizedText(en: 'Alexandria City', ar: 'مدينة الإسكندرية'),
  governorateId: 15,
);

Widget _app({
  required int? cityId,
  required int? governmentId,
  required void Function(int? cityId, int? governmentId) onChanged,
  Duration? delay,
  Object? error,
}) {
  return ProviderScope(
    overrides: [
      allGovernmentsProvider.overrideWith((ref) async {
        if (error != null) throw error;
        if (delay != null) await Future<void>.delayed(delay);
        return const [_cairoGov, _alexGov];
      }),
      allCitiesProvider.overrideWith((ref) async {
        if (error != null) throw error;
        if (delay != null) await Future<void>.delayed(delay);
        return const [_cairoCity, _alexCity];
      }),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: LocationCascadeField(
            cityId: cityId,
            governmentId: governmentId,
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('government sheet loads API names after a spinner', (tester) async {
    await tester.pumpWidget(
      _app(
        cityId: null,
        governmentId: null,
        delay: const Duration(milliseconds: 80),
        onChanged: (_, __) {},
      ),
    );

    await tester.tap(find.byKey(const ValueKey('locationGovernmentPicker')));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Cairo'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.text('Alexandria'), findsOneWidget);
  });

  testWidgets('selecting a government saves governmentId and clears city',
      (tester) async {
    int? city;
    int? government;
    await tester.pumpWidget(
      _app(
        cityId: 1,
        governmentId: 16,
        onChanged: (c, g) {
          city = c;
          government = g;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('locationGovernmentPicker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alexandria'));
    await tester.pumpAndSettle();

    expect(government, 15);
    expect(city, isNull);
  });

  testWidgets('city sheet only lists cities for the selected government',
      (tester) async {
    int? city;
    int? government;
    await tester.pumpWidget(
      _app(
        cityId: null,
        governmentId: 16,
        onChanged: (c, g) {
          city = c;
          government = g;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('locationCityPicker')));
    await tester.pumpAndSettle();

    expect(find.text('Cairo City'), findsOneWidget);
    expect(find.text('Alexandria City'), findsNothing);

    await tester.tap(find.text('Cairo City'));
    await tester.pumpAndSettle();
    expect(city, 1);
    expect(government, 16);
  });
}
