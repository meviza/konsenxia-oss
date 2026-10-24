import '../entities/dashboard_summary.dart';

/// Dashboard repository arayüzü.
/// Data katmanı bu sözleşmeyi Firestore üzerinden implement eder.
abstract class DashboardRepository {
  /// Giriş yapmış kullanıcının dashboard özetini getirir.
  Future<DashboardSummary> getDashboardSummary();
}
