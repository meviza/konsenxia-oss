import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

/// Doktorun dashboard özetini getirir.
class GetDashboardSummaryUseCase {
  final DashboardRepository repository;
  const GetDashboardSummaryUseCase(this.repository);

  Future<DashboardSummary> call() => repository.getDashboardSummary();
}
