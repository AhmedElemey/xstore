import '../localization/app_localizations.dart';

/// Shared form validation helpers. Return localized user-facing strings via [AppLocalizations].
abstract final class Validators {
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  static final RegExp _fullNameLetters = RegExp(r'^[a-zA-Z\s]+$');
  static final RegExp _egyptMobileLocal = RegExp(r'^01[0125]\d{8}$');

  static String? loginPassword(AppLocalizations l10n, String value) {
    if (value.isEmpty) return l10n.validationLoginPasswordRequired;
    if (value.length < 6) return l10n.minSixChars;
    return null;
  }

  static String? registerEmail(AppLocalizations l10n, String raw) {
    final t = raw.trim();
    if (!_emailRegex.hasMatch(t)) return l10n.validationEmailInvalid;
    return null;
  }

  static String? registerPhoneEgypt(
    AppLocalizations l10n, {
    required String rawInput,
    String? normalizedLocal,
  }) {
    final local = normalizedLocal ?? AppValidators.normalizeEgyptLocal(rawInput);
    if (local.isEmpty) return l10n.validationRegisterPhoneInvalid;
    if (!RegExp(r'^\d{11}$').hasMatch(local)) return l10n.phoneInvalidLength;
    if (!_egyptMobileLocal.hasMatch(local)) return l10n.phoneInvalidPrefix;
    return null;
  }

  /// Egyptian phone sheet + OTP flow (local digits, 11 chars after normalize).
  static String? egyptPhone(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) return l10n.phoneRequired;
    final cleaned = AppValidators.normalizeEgyptLocal(value);
    if (cleaned.isEmpty) return l10n.phoneRequired;
    if (!RegExp(r'^\d{11}$').hasMatch(cleaned)) return l10n.phoneInvalidLength;
    if (!_egyptMobileLocal.hasMatch(cleaned)) return l10n.phoneInvalidPrefix;
    return null;
  }

  static String? personFullName(AppLocalizations l10n, String raw) {
    final t = raw.trim();
    if (t.length < 3 || !_fullNameLetters.hasMatch(t)) {
      return l10n.validationFullNameInvalid;
    }
    return null;
  }

  /// Password rules for registration (min 8 characters).
  static String? registerPassword(AppLocalizations l10n, String password) {
    if (password.length < 8) return l10n.validationPasswordMinEight;
    return null;
  }

  static String? confirmPasswordMatches(
    AppLocalizations l10n,
    String password,
    String confirm,
  ) {
    if (password != confirm) return l10n.validationPasswordsMismatch;
    return null;
  }

  static String? nonEmptyLine(
    AppLocalizations l10n,
    String raw,
    String Function(AppLocalizations l10n) ifEmpty,
  ) {
    if (raw.trim().isEmpty) return ifEmpty(l10n);
    return null;
  }

  static double? parseMoneyInput(String raw) =>
      double.tryParse(raw.replaceAll(RegExp(r','), ''));

  static bool listingFormHasErrors(ListingFormValidationInput input) {
    if (input.photoPaths.isEmpty) return true;
    final name = input.name.trim();
    if (name.isEmpty || name.length > 100) return true;
    final price = parseMoneyInput(input.priceInput);
    if (price == null || price <= 0) return true;
    final desc = input.description.trim();
    if (desc.isEmpty || desc.length > 1000) return true;
    if (input.categoryId.isEmpty) return true;
    if (input.subcategoryId.isEmpty && input.categoryId.isNotEmpty) return true;
    if (input.condition.isEmpty) return true;
    if (input.quantity < 1) return true;
    if (input.location.trim().isEmpty) return true;
    if (input.shippingAvailable) {
      final sc = parseMoneyInput(input.shippingCostInput);
      if (sc == null || sc < 0) return true;
    }
    return false;
  }

  /// Field keys match [ListingFormState.errors] usages in the add-listing UI.
  static Map<String, String> listingFormErrors(
    AppLocalizations l10n,
    ListingFormValidationInput input,
  ) {
    final err = <String, String>{};
    if (input.photoPaths.isEmpty) {
      err['photos'] = l10n.listingValidationPhotosRequired;
    }
    final name = input.name.trim();
    if (name.isEmpty) {
      err['name'] = l10n.listingValidationNameRequired;
    } else if (name.length > 100) {
      err['name'] = l10n.listingValidationNameMax;
    }

    final price = parseMoneyInput(input.priceInput);
    if (price == null || price <= 0) {
      err['price'] = l10n.listingValidationPriceInvalid;
    }

    final desc = input.description.trim();
    if (desc.isEmpty) {
      err['description'] = l10n.listingValidationDescriptionRequired;
    } else if (desc.length > 1000) {
      err['description'] = l10n.listingValidationDescriptionMax;
    }

    if (input.categoryId.isEmpty) {
      err['category'] = l10n.listingValidationCategoryRequired;
    }
    if (input.subcategoryId.isEmpty && input.categoryId.isNotEmpty) {
      err['subcategory'] = l10n.listingValidationSubcategoryRequired;
    }
    if (input.condition.isEmpty) {
      err['condition'] = l10n.listingValidationConditionRequired;
    }
    if (input.quantity < 1) {
      err['quantity'] = l10n.listingValidationQuantityMin;
    }
    if (input.location.trim().isEmpty) {
      err['location'] = l10n.listingValidationLocationRequired;
    }
    if (input.shippingAvailable) {
      final sc = parseMoneyInput(input.shippingCostInput);
      if (sc == null || sc < 0) {
        err['shippingCost'] = l10n.listingValidationShippingCost;
      }
    }
    return err;
  }
}

/// Inputs for listing publish validation (mirrors [ListingFormState] fields used in checks).
class ListingFormValidationInput {
  const ListingFormValidationInput({
    required this.photoPaths,
    required this.name,
    required this.priceInput,
    required this.description,
    required this.categoryId,
    required this.subcategoryId,
    required this.condition,
    required this.quantity,
    required this.location,
    required this.shippingAvailable,
    required this.shippingCostInput,
  });

  final List<String> photoPaths;
  final String name;
  final String priceInput;
  final String description;
  final String categoryId;
  final String subcategoryId;
  final String condition;
  final int quantity;
  final String location;
  final bool shippingAvailable;
  final String shippingCostInput;
}

/// Egypt phone normalization and E.164 helpers (non-UI).
abstract final class AppValidators {
  static String normalizeEgyptLocal(String value) {
    var cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('20') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    }
    if (cleaned.length == 10 && cleaned.startsWith('1')) {
      cleaned = '0$cleaned';
    }
    return cleaned;
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
