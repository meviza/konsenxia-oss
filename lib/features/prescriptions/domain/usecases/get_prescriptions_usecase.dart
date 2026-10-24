import '../../../../core/usecase/usecase.dart';
import '../entities/prescription_entity.dart';
import '../repositories/prescriptions_repository.dart';

class GetPrescriptionsUseCase
    implements UseCase<List<PrescriptionEntity>, NoParams> {
  final PrescriptionsRepository repository;
  const GetPrescriptionsUseCase(this.repository);

  @override
  Future<List<PrescriptionEntity>> call(NoParams params) =>
      repository.getPrescriptions();
}
