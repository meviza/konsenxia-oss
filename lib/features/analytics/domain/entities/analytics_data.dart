import 'package:equatable/equatable.dart';

/// Kullanıcı kişisel analytics verisi.
class AnalyticsData extends Equatable {
  final UserAnalytics personal;
  final CommunityAnalytics community;

  const AnalyticsData({
    required this.personal,
    required this.community,
  });

  @override
  List<Object?> get props => [personal, community];
}

/// Kişisel istatistikler
class UserAnalytics extends Equatable {
  final int totalXp;
  final int xpThisWeek;
  final int xpThisMonth;
  final int totalCases;
  final int casesThisMonth;
  final int totalComments;
  final int acceptedAnswers;
  final int totalLikesReceived;
  final int currentStreak;      // Consecutive active days
  final int longestStreak;
  final List<WeeklyActivity> weeklyActivity; // last 7 days
  final List<MonthlyXP> monthlyXP;          // last 6 months

  const UserAnalytics({
    required this.totalXp,
    required this.xpThisWeek,
    required this.xpThisMonth,
    required this.totalCases,
    required this.casesThisMonth,
    required this.totalComments,
    required this.acceptedAnswers,
    required this.totalLikesReceived,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.weeklyActivity = const [],
    this.monthlyXP = const [],
  });

  @override
  List<Object?> get props => [totalXp, totalCases, currentStreak];
}

class WeeklyActivity extends Equatable {
  final String day;     // "Pzt", "Sal" vb
  final int cases;
  final int comments;
  final int xp;

  const WeeklyActivity({
    required this.day,
    required this.cases,
    required this.comments,
    required this.xp,
  });

  @override
  List<Object?> get props => [day, xp];
}

class MonthlyXP extends Equatable {
  final String month;  // "Oca", "Şub" vb
  final int xp;

  const MonthlyXP({required this.month, required this.xp});

  @override
  List<Object?> get props => [month, xp];
}

/// Topluluk istatistikleri
class CommunityAnalytics extends Equatable {
  final int totalDoctors;
  final int activeTodayCount;
  final int casesThisWeek;
  final int totalCasesAllTime;
  final int solvedCasesPercent;
  final List<SpecialtyActivity> topSpecialties;

  const CommunityAnalytics({
    this.totalDoctors = 0,
    this.activeTodayCount = 0,
    this.casesThisWeek = 0,
    this.totalCasesAllTime = 0,
    this.solvedCasesPercent = 0,
    this.topSpecialties = const [],
  });

  @override
  List<Object?> get props => [totalDoctors, casesThisWeek];
}

class SpecialtyActivity extends Equatable {
  final String specialty;
  final int caseCount;
  final double percentage;

  const SpecialtyActivity({
    required this.specialty,
    required this.caseCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [specialty, caseCount];
}
