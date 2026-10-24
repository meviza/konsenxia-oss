import '../entities/analytics_data.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsData> getAnalytics();
}
