import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/network/json_list_unwrap.dart';

void main() {
  test('unwraps a bare JSON array', () {
    final rows = unwrapJsonObjectList([
      {'id': 16, 'nameEn': 'Cairo'},
      {'id': 15, 'nameEn': 'Alexandria'},
    ]);
    expect(rows.map((e) => e['id']), [16, 15]);
  });

  test('unwraps the older items envelope', () {
    final rows = unwrapJsonObjectList({
      'items': [
        {'id': 1},
      ],
      'totalCount': 1,
    });
    expect(rows.single['id'], 1);
  });

  test('returns empty for null or unknown shapes', () {
    expect(unwrapJsonObjectList(null), isEmpty);
    expect(unwrapJsonObjectList(''), isEmpty);
    expect(unwrapJsonObjectList({'totalCount': 0}), isEmpty);
  });
}
