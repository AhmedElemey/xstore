abstract final class Formatters {
  static String currency(num amount, {String symbol = r'$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}
