import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_form_state.freezed.dart';

@freezed
class ListingFormState with _$ListingFormState {
  const factory ListingFormState({
    @Default('') String title,
    @Default('') String description,
    @Default(0.0) double price,
    @Default(<String>[]) List<String> photoPaths,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _ListingFormState;
}
