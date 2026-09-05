import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

void main() {
  group('OrderStatus wire mapping (backend C# enum, 0-based)', () {
    test('wire codes match the confirmed C# enum exactly', () {
      // public enum OrderStatus {
      //   Pending = 0, Confirmed = 1, Processing = 2,
      //   Shipped = 3, Delivered = 4, Cancelled = 5
      // }
      expect(orderStatusToWire(OrderStatus.pending), 0);
      expect(orderStatusToWire(OrderStatus.confirmed), 1);
      expect(orderStatusToWire(OrderStatus.processing), 2);
      expect(orderStatusToWire(OrderStatus.shipped), 3);
      expect(orderStatusToWire(OrderStatus.delivered), 4);
      expect(orderStatusToWire(OrderStatus.cancelled), 5);
    });

    test('every status round-trips wire → enum → wire', () {
      for (final s in OrderStatus.values) {
        final wire = orderStatusToWire(s);
        expect(orderStatusFromWire(wire), s,
            reason: 'int $wire should parse back to $s');
        expect(orderStatusFromWire('$wire'), s,
            reason: 'string "$wire" should parse back to $s');
      }
    });

    test('0 is Pending, not unset', () {
      expect(orderStatusFromWire(0), OrderStatus.pending);
      expect(orderStatusFromWire('0'), OrderStatus.pending);
    });

    test('name strings still parse (mocks / older payloads)', () {
      expect(orderStatusFromWire('pending'), OrderStatus.pending);
      expect(orderStatusFromWire('Pending'), OrderStatus.pending);
      expect(orderStatusFromWire('CONFIRMED'), OrderStatus.confirmed);
      expect(orderStatusFromWire('rejected'), OrderStatus.cancelled);
    });

    test('unknown values are null so the caller can fall back', () {
      expect(orderStatusFromWire(null), isNull);
      expect(orderStatusFromWire(''), isNull);
      expect(orderStatusFromWire(6), isNull);
      expect(orderStatusFromWire('refunded'), isNull);
    });
  });
}
