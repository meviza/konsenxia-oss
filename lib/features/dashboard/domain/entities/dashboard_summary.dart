import 'package:equatable/equatable.dart';

/// KONSENXIA — Dashboard domain entity
///
/// Bir doktorun dashboard'unda gösterilecek tüm özet bilgiler:
/// XP/level, istatistikler, son vakalar, topluluk stats.
class DashboardSummary extends Equatable {
  final UserStats stats;
  final List<RecentCasePreview> recentCases;
  final CommunityStats community;

  const DashboardSummary({
    required this.stats,
    this.recentCases = const [],
    required this.community,
  });

  @override
  List<Object?> get props => [stats, recentCases, community];
}

class UserStats extends Equatable {
  final String userId;
  final String displayName;
  final String specialty;
  final String? photoUrl;
  final int totalXp;
  final int xpCurrent;   // bu level icin kazanilan XP
  final int xpTotal;     // bu leveli tamamlamak icin gereken XP
  final int level;
  final String levelTitle;
  final int totalCases;
  final int totalContributions;
  final int totalCountries;
  final int? rank;
  final String role;     // Firestore role: PROFESSOR, SPECIALIST, RESIDENT, INTERN
  final String? institution;

  const UserStats({
    required this.userId,
    required this.displayName,
    required this.specialty,
    this.photoUrl,
    required this.totalXp,
    required this.xpCurrent,
    required this.xpTotal,
    required this.level,
    required this.levelTitle,
    required this.totalCases,
    required this.totalContributions,
    this.totalCountries = 0,
    this.rank,
    this.role = '',
    this.institution,
  });

  @override
  List<Object?> get props => [userId, totalXp, level, rank];
}

class RecentCasePreview extends Equatable {
  final String id;
  final String title;
  final String specialty;
  final String authorName;
  final String? authorImageUrl;
  final int commentCount;
  final int likeCount;
  final DateTime createdAt;
  final bool isSolved;
  final String urgency;

  const RecentCasePreview({
    required this.id,
    required this.title,
    required this.specialty,
    required this.authorName,
    this.authorImageUrl,
    required this.commentCount,
    this.likeCount = 0,
    required this.createdAt,
    this.isSolved = false,
    this.urgency = 'routine',
  });

  @override
  List<Object?> get props => [id, title, commentCount, createdAt];
}

class CommunityStats extends Equatable {
  final int onlineDoctors;
  final int totalDoctors;
  final int casesThisWeek;

  const CommunityStats({
    this.onlineDoctors = 0,
    this.totalDoctors = 0,
    this.casesThisWeek = 0,
  });

  @override
  List<Object?> get props => [onlineDoctors, totalDoctors, casesThisWeek];
}
