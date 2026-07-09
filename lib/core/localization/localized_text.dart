import 'package:freezed_annotation/freezed_annotation.dart';

part 'localized_text.freezed.dart';

/// Bilingual (en/ar) text pair mirroring API fields like `nameEn`/`nameAr`.
/// Entities store both languages; the display layer resolves the active one
/// via [resolve], typically called with `ref.watch(appIsArabicProvider)`.
@Freezed(fromJson: false, toJson: false)
class LocalizedText with _$LocalizedText {
  const LocalizedText._();

  const factory LocalizedText({
    required String en,
    required String ar,
  }) = _LocalizedText;

  /// Resolve for the current app language, falling back to the other
  /// language when the preferred one is empty.
  String resolve(bool isArabic) {
    final value = isArabic ? ar : en;
    if (value.isNotEmpty) return value;
    return isArabic ? en : ar;
  }
}
