part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  /// Kullanıcının toplam XP'si
  final int totalXp;

  /// Mevcut level numarası
  final int level;

  /// Level başlığı
  final String levelTitle;

  /// Bu level için XP (mevcut / toplam)
  final int xpCurrent;
  final int xpTotal;

  /// İstatistikler
  final int totalCases;
  final int totalContributions;
  final int totalCountries;

  /// Sıralama (leaderboard)
  final int? rank;

  /// Son vakalar (feed)
  final List<DashboardCase> recentCases;

  /// Online doktor sayısı (topluluk stats)
  final int onlineDoctors;

  /// Kullanıcı rolü (rol bazlı içerik için)
  final String userRole;

  /// Kullanıcı adı
  final String userName;

  /// İntern/resident için: atanan vakalar
  final List<DashboardAssignment> assignedCases;

  /// Son bildirimler (3 adet preview)
  final List<DashboardNotificationPreview> recentNotifications;

  const DashboardLoaded({
    required this.totalXp,
    required this.level,
    required this.levelTitle,
    required this.xpCurrent,
    required this.xpTotal,
    required this.totalCases,
    required this.totalContributions,
    required this.totalCountries,
    this.rank,
    this.recentCases = const [],
    this.onlineDoctors = 0,
    this.userRole = 'RESIDENT',
    this.userName = '',
    this.assignedCases = const [],
    this.recentNotifications = const [],
  });

  DashboardLoaded copyWith({
    int? totalXp,
    int? level,
    String? levelTitle,
    int? xpCurrent,
    int? xpTotal,
    int? totalCases,
    int? totalContributions,
    int? totalCountries,
    int? rank,
    List<DashboardCase>? recentCases,
    int? onlineDoctors,
    String? userRole,
    String? userName,
    List<DashboardAssignment>? assignedCases,
    List<DashboardNotificationPreview>? recentNotifications,
  }) {
    return DashboardLoaded(
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      xpCurrent: xpCurrent ?? this.xpCurrent,
      xpTotal: xpTotal ?? this.xpTotal,
      totalCases: totalCases ?? this.totalCases,
      totalContributions: totalContributions ?? this.totalContributions,
      totalCountries: totalCountries ?? this.totalCountries,
      rank: rank ?? this.rank,
      recentCases: recentCases ?? this.recentCases,
      onlineDoctors: onlineDoctors ?? this.onlineDoctors,
      userRole: userRole ?? this.userRole,
      userName: userName ?? this.userName,
      assignedCases: assignedCases ?? this.assignedCases,
      recentNotifications: recentNotifications ?? this.recentNotifications,
    );
  }

  factory DashboardLoaded.fromSummary(DashboardSummary summary) {
    return DashboardLoaded(
      totalXp:             summary.stats.totalXp,
      level:               summary.stats.level,
      levelTitle:          summary.stats.levelTitle,
      xpCurrent:           summary.stats.xpCurrent,
      xpTotal:             summary.stats.xpTotal,
      totalCases:          summary.stats.totalCases,
      totalContributions:  summary.stats.totalContributions,
      totalCountries:      summary.stats.totalCountries,
      rank:                summary.stats.rank,
      onlineDoctors:       summary.community.onlineDoctors,
      recentCases: summary.recentCases.map((c) => DashboardCase(
        id:           c.id,
        title:        c.title,
        specialty:    c.specialty,
        authorName:   c.authorName,
        commentCount: c.commentCount,
        postedAt:     c.createdAt,
        isSolved:     c.isSolved,
      )).toList(),
    );
  }

  /// Kullanıcı öğrenen rolünde mi? (intern veya resident)
  bool get isLearner => userRole == 'INTERN' || userRole == 'RESIDENT';

  /// Kullanıcı atama yapabilir mi? (specialist veya professor)
  bool get canAssign => userRole == 'SPECIALIST' || userRole == 'PROFESSOR';

  @override
  List<Object?> get props => [
        totalXp,
        level,
        xpCurrent,
        xpTotal,
        totalCases,
        totalContributions,
        totalCountries,
        rank,
        recentCases,
        onlineDoctors,
        userRole,
        userName,
        assignedCases,
        recentNotifications,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Data models (basit, gerçek backend'e kadar) ────────────────

class DashboardCase {
  final String id;
  final String title;
  final String specialty;
  final String authorName;
  final int commentCount;
  final DateTime postedAt;
  final bool isSolved;

  const DashboardCase({
    required this.id,
    required this.title,
    required this.specialty,
    required this.authorName,
    required this.commentCount,
    required this.postedAt,
    this.isSolved = false,
  });
}

/// Atanan vaka özeti — intern/resident dashboard'u için
class DashboardAssignment {
  final String assignmentId;
  final String caseId;
  final String caseTitle;
  final String specialty;
  final String assignedByName;
  final String assignedByTitle;
  final DateTime assignedAt;
  final DateTime? dueDate;
  final String status; // pending | in_progress | completed

  const DashboardAssignment({
    required this.assignmentId,
    required this.caseId,
    required this.caseTitle,
    required this.specialty,
    required this.assignedByName,
    required this.assignedByTitle,
    required this.assignedAt,
    this.dueDate,
    this.status = 'pending',
  });

  bool get isPending    => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted  => status == 'completed';
}

/// Bildirim önizlemesi — dashboard'da 3 adet gösterim için
class DashboardNotificationPreview {
  final String id;
  final String type; // case_assigned | comment | like | system
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  const DashboardNotificationPreview({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
}
