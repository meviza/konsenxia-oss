part of 'leaderboard_bloc.dart';

sealed class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadLeaderboardEvent extends LeaderboardEvent {
  const LoadLeaderboardEvent();
}

class RefreshLeaderboardEvent extends LeaderboardEvent {
  const RefreshLeaderboardEvent();
}

class FilterLeaderboardEvent extends LeaderboardEvent {
  final LeaderboardPeriod period;
  final String? specialty;

  const FilterLeaderboardEvent({
    this.period = LeaderboardPeriod.allTime,
    this.specialty,
  });

  @override
  List<Object?> get props => [period, specialty];
}
