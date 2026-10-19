import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

void main() {
  group('OrderStatus wire mapping (backend C# enum, 0-based)', () {
    test('wire codes match the confirmed C# enum exactly', () {
      // public enum OrderStatus {
      //   Pending = 0, Confirmed = 1, Processing = 2,
      //   Shipped = 3, Delivered = 4, Cancelled = 5
      // }
      expect(orderStatusFromWire(0), OrderStatus.pending);
      expect(orderStatusFromWire(1), OrderStatus.confirmed);
      expect(orderStatusFromWire(2), OrderStatus.processing);
      expect(orderStatusFromWire(3), OrderStatus.shipped);
      expect(orderStatusFromWire(4), OrderStatus.delivered);
      expect(orderStatusFromWire(5), OrderStatus.cancelled);
    });

    test('PUT /vendor/orders/status sends the C# enum name', () {
      expect(orderStatusToWireName(OrderStatus.pending), 'Pending');
      expect(orderStatusToWireName(OrderStatus.confirmed), 'Confirmed');
      expect(orderStatusToWireName(OrderStatus.processing), 'Processing');
      expect(orderStatusToWireName(OrderStatus.shipped), 'Shipped');
      expect(orderStatusToWireName(OrderStatus.delivered), 'Delivered');
      expect(orderStatusToWireName(OrderStatus.cancelled), 'Cancelled');
    });

    test('every status parses from its int and string wire code', () {
      for (final s in OrderStatus.values) {
        final wire = s.index; // C# declaration order matches the enum.
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
