abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final email = value.trim();
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    return ok ? null : 'Enter a valid email';
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Use at least 8 characters';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}

abstract final class AppValidators {
  static String normalizeEgyptLocal(String value) {
    var cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('20') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }
    // Users may type without leading zero because +20 is visible.
    if (cleaned.length == 10 && cleaned.startsWith('1')) {
      cleaned = '0$cleaned';
    }
    return cleaned;
  }

  static String? egyptPhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = normalizeEgyptLocal(value);
    if (!RegExp(r'^\d{11}$').hasMatch(cleaned)) return 'Must be 11 digits';
    if (!RegExp(r'^01[0125]\d{8}$').hasMatch(cleaned)) {
      return 'Must start with 010, 011, 012, or 015';
    }
    return null;
  }

  static String toE164Egypt(String localNumber) {
    final cleaned = normalizeEgyptLocal(localNumber);
    if (cleaned.startsWith('0')) return '+20${cleaned.substring(1)}';
    return '+20$cleaned';
  }

  static String formatEgyptPhone(String e164) {
    final local = toLocalEgypt(e164);
    if (local.length == 11) {
      return '${local.substring(0, 4)} ${local.substring(4, 7)} ${local.substring(7)}';
    }
    return local;
  }

  static String toLocalEgypt(String e164) {
    return e164.startsWith('+20') ? '0${e164.substring(3)}' : e164;
  }
}
