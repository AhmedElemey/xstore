import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_write_params.freezed.dart';

/// Shared params for both create and update — the API bodies are identical
/// (`{rating, comment}`); only the HTTP verb + presence of a reviewId differ.
@freezed
class ReviewWriteParams with _$ReviewWriteParams {
  const factory ReviewWriteParams({
    required double rating,
    required String comment,
  }) = _ReviewWriteParams;
}
