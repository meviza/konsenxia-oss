import 'package:equatable/equatable.dart';

/// Sıralama listesi öğesi
class LeaderboardEntry extends Equatable {
  final String userId;
  final String displayName;
  final String specialty;
  final String? location;
  final String? photoUrl;
  final int totalXp;
  final int level;
  final String levelTitle;
  final int caseCount;
  final int contributionCount;
  final bool isOnline;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.specialty,
    this.location,
    this.photoUrl,
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.caseCount,
    required this.contributionCount,
    this.isOnline = false,
    required this.rank,
  });

  @override
  List<Object?> get props => [userId, totalXp, rank];
}

enum LeaderboardPeriod { allTime, thisWeek, thisMonth }
