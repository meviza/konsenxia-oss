import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../../../design_system/molecules/kx_xp_bar.dart';

/// Paginated leaderboard result for cursor-based pagination.
class PaginatedLeaderboardResult {
  final List<LeaderboardEntry> entries;
  final DocumentSnapshot? lastDocument;

  const PaginatedLeaderboardResult({
    required this.entries,
    this.lastDocument,
  });

  bool get hasMore => lastDocument != null && entries.isNotEmpty;
}

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final FirebaseFirestore _firestore;

  LeaderboardRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    String? specialtyFilter,
    int limit = 50,
  }) async {
    final xpField = _xpFieldForPeriod(period);

    Query<Map<String, dynamic>> q = _firestore
        .collection('users')
        .orderBy(xpField, descending: true)
        .limit(limit);

    if (specialtyFilter != null) {
      q = q.where('specialty', isEqualTo: specialtyFilter);
    }

    final snapshot = await q.get();

    return snapshot.docs.asMap().entries.map((entry) {
      final rank = entry.key + 1;
      final doc = entry.value;
      final d = doc.data();

      final xp    = (d[xpField] as num?)?.toInt() ?? 0;
      final level = _levelFromXp(xp);

      return LeaderboardEntry(
        userId:             doc.id,
        displayName:        d['displayName'] as String? ?? 'Doktor',
        specialty:          d['specialty'] as String? ?? '',
        location:           d['country'] as String?,
        photoUrl:           d['photoUrl'] as String?,
        totalXp:            xp,
        level:              level,
        levelTitle:         KxLevelSystem.titleForLevel(level),
        caseCount:          (d['caseCount'] as num?)?.toInt() ?? 0,
        contributionCount:  (d['contributionCount'] as num?)?.toInt() ?? 0,
        isOnline:           d['isOnline'] as bool? ?? false,
        rank:               rank,
      );
    }).toList();
  }

  /// Cursor-based paginated leaderboard fetching.
  ///
  /// Usage:
  /// ```dart
  /// final page1 = await repo.getLeaderboardPaginated();
  /// final page2 = await repo.getLeaderboardPaginated(
  ///   lastDocument: page1.lastDocument,
  ///   startRank: page1.entries.length + 1,
  /// );
  /// ```
  Future<PaginatedLeaderboardResult> getLeaderboardPaginated({
    LeaderboardPeriod period = LeaderboardPeriod.allTime,
    String? specialtyFilter,
    int limit = 50,
    DocumentSnapshot? lastDocument,
    int startRank = 1,
  }) async {
    final xpField = _xpFieldForPeriod(period);

    Query<Map<String, dynamic>> q = _firestore
        .collection('users')
        .orderBy(xpField, descending: true)
        .limit(limit);

    if (specialtyFilter != null) {
      q = q.where('specialty', isEqualTo: specialtyFilter);
    }

    // Cursor-based pagination
    if (lastDocument != null) {
      q = q.startAfterDocument(lastDocument);
    }

    final snapshot = await q.get();

    final DocumentSnapshot? newCursor =
        snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    final entries = snapshot.docs.asMap().entries.map((entry) {
      final rank = startRank + entry.key;
      final doc = entry.value;
      final d = doc.data();

      final xp    = (d[xpField] as num?)?.toInt() ?? 0;
      final level = _levelFromXp(xp);

      return LeaderboardEntry(
        userId:             doc.id,
        displayName:        d['displayName'] as String? ?? 'Doktor',
        specialty:          d['specialty'] as String? ?? '',
        location:           d['country'] as String?,
        photoUrl:           d['photoUrl'] as String?,
        totalXp:            xp,
        level:              level,
        levelTitle:         KxLevelSystem.titleForLevel(level),
        caseCount:          (d['caseCount'] as num?)?.toInt() ?? 0,
        contributionCount:  (d['contributionCount'] as num?)?.toInt() ?? 0,
        isOnline:           d['isOnline'] as bool? ?? false,
        rank:               rank,
      );
    }).toList();

    return PaginatedLeaderboardResult(
      entries: entries,
      lastDocument: newCursor,
    );
  }

  /// Maps the period enum to the correct Firestore field name.
  String _xpFieldForPeriod(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.thisWeek:
        return 'xpThisWeek';
      case LeaderboardPeriod.thisMonth:
        return 'xpThisMonth';
      case LeaderboardPeriod.allTime:
        return 'xp';
    }
  }

  int _levelFromXp(int xp) {
    int level = 1;
    while (level < 10 && xp >= KxLevelSystem.xpForLevel(level)) {
      level++;
    }
    return level;
  }
}
