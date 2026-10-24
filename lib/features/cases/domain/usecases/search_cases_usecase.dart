import '../entities/case_entity.dart';
import '../repositories/case_repository.dart';

/// Vakalar içinde metin arama.
class SearchCasesUseCase {
  final CaseRepository repository;
  const SearchCasesUseCase(this.repository);

  Future<List<CaseEntity>> call(String query) => repository.searchCases(query);
}
