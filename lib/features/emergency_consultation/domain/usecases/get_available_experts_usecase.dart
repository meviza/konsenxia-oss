import '../entities/emergency_entity.dart';
import '../repositories/emergency_repository.dart';

class GetAvailableExpertsUseCase {
  final EmergencyRepository _repository;
  GetAvailableExpertsUseCase(this._repository);

  Future<List<AvailableExpert>> call(String specialty) =>
      _repository.getAvailableExperts(specialty);
}
