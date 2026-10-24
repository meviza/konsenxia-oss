part of 'leaderboard_bloc.dart';

sealed class LeaderboardState extends Equatable {
  const LeaderboardState();
  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  final LeaderboardPeriod activePeriod;
  final String? activeSpecialty;

  const LeaderboardLoaded({
    required this.entries,
    this.activePeriod = LeaderboardPeriod.allTime,
    this.activeSpecialty,
  });

  LeaderboardLoaded copyWith({
    List<LeaderboardEntry>? entries,
    LeaderboardPeriod? activePeriod,
    String? activeSpecialty,
  }) =>
      LeaderboardLoaded(
        entries: entries ?? this.entries,
        activePeriod: activePeriod ?? this.activePeriod,
        activeSpecialty: activeSpecialty ?? this.activeSpecialty,
      );

  @override
  List<Object?> get props => [entries, activePeriod, activeSpecialty];
}

class LeaderboardError extends LeaderboardState {
  final String message;
  const LeaderboardError(this.message);
  @override
  List<Object?> get props => [message];
}
