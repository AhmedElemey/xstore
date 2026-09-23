import '../repositories/home_repository.dart';

class GetHomeFeedUseCase {
  const GetHomeFeedUseCase(this._repository);

  final HomeRepository _repository;

  Future<HomeFeed?> call() => _repository.getHomeFeed();
}
