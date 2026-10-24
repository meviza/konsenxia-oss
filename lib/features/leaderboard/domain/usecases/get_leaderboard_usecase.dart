import '../entities/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';

class GetLeaderboardUseCase {
  final LeaderboardRepository repository;
  const GetLeaderboardUseCase(this.repository);

  Future<List<LeaderboardEntry>> call({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    String? specialtyFilter,
    int limit = 50,
  }) =>
      repository.getLeaderboard(
        period: period,
        specialtyFilter: specialtyFilter,
        limit: limit,
      );
}
