import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'listing_dependencies.dart';
import 'listing_form_state.dart';
import 'my_listings_provider.dart';

part 'listing_form_provider.g.dart';

@riverpod
class ListingForm extends _$ListingForm {
  final ImagePicker _picker = ImagePicker();

  @override
  ListingFormState build() => const ListingFormState();

  void setTitle(String value) {
    state = state.copyWith(title: value, errorMessage: null);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value, errorMessage: null);
  }

  void setPrice(double value) {
    state = state.copyWith(price: value, errorMessage: null);
  }

  void removePhotoAt(int index) {
    final next = List<String>.from(state.photoPaths)..removeAt(index);
    state = state.copyWith(photoPaths: next);
  }

  Future<void> pickPhotos() async {
    final files = await _picker.pickMultiImage();
    if (files.isEmpty) {
      return;
    }
    final paths = files.map((f) => f.path).toList();
    state = state.copyWith(
      photoPaths: [...state.photoPaths, ...paths],
    );
  }

  Future<bool> submit() async {
    if (state.title.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Title is required');
      return false;
    }
    if (state.price <= 0) {
      state = state.copyWith(errorMessage: 'Enter a valid price');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final useCase = ref.read(createListingUseCaseProvider);
    final result = await useCase(
      title: state.title.trim(),
      description: state.description.trim(),
      price: state.price,
      imagePaths: state.photoPaths,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.toString(),
        );
        return false;
      },
      (_) {
        state = const ListingFormState();
        ref.invalidate(myListingsProvider);
        return true;
      },
    );
  }

  void reset() {
    state = const ListingFormState();
  }
}
