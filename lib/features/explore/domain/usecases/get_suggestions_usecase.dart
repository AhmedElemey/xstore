import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/explore_repository.dart';

class GetSuggestionsUseCase {
  const GetSuggestionsUseCase(this._repository);

  final ExploreRepository _repository;

  Future<Either<Failure, List<String>>> call(String query) =>
      _repository.getSuggestions(query);
}
