import '../entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    String? specialtyFilter,
    int limit = 50,
  });
}
