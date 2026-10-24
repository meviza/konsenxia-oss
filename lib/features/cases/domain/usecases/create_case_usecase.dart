import '../entities/case_entity.dart';
import '../repositories/case_repository.dart';

class CreateCaseParams {
  final String title;
  final String description;
  final String clinicalPresentation;
  final String patientSummary;
  final CaseUrgency urgency;
  final List<String> specialties;
  final List<String> tags;
  final List<VitalSign> vitals;

  const CreateCaseParams({
    required this.title,
    required this.description,
    required this.clinicalPresentation,
    required this.patientSummary,
    required this.urgency,
    this.specialties = const [],
    this.tags = const [],
    this.vitals = const [],
  });
}

/// Yeni vaka oluşturur ve oluşturulan vaka ID'sini döner.
class CreateCaseUseCase {
  final CaseRepository repository;
  const CreateCaseUseCase(this.repository);

  Future<String> call(CreateCaseParams params) => repository.createCase(
        title: params.title,
        description: params.description,
        clinicalPresentation: params.clinicalPresentation,
        patientSummary: params.patientSummary,
        urgency: params.urgency,
        specialties: params.specialties,
        tags: params.tags,
        vitals: params.vitals,
      );
}
