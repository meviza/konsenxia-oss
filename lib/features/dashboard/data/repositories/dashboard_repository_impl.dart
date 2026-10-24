import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../design_system/molecules/kx_xp_bar.dart';

/// Dashboard Firestore implementasyonu.
///
/// Veriler:
///   - `users/{uid}` — kullanıcı stats (xp, level, caseCount vb.)
///   - `cases` koleksiyonu — son 5 vaka
///   - `meta/stats` dökümanı — topluluk istatistikleri (opsiyonel)
class DashboardRepositoryImpl implements DashboardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DashboardRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Giriş yapılmamış');

    // ── User stats (Firestore hatası olursa varsayılan değerler) ──
    Map<String, dynamic> u = {};
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get()
          .timeout(const Duration(seconds: 5));
      if (userDoc.exists) u = userDoc.data()!;
    } catch (_) {
      // permission hatası, network hatası vb. — boş map ile devam
    }

    // ── Recent cases (index yoksa veya permission hatası → boş liste) ──
    List<RecentCasePreview> recentCases = [];
    try {
      final casesSnap = await _firestore
          .collection('cases')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get()
          .timeout(const Duration(seconds: 5));
      recentCases = casesSnap.docs.map((doc) {
        final d = doc.data();
        return RecentCasePreview(
          id:            doc.id,
          title:         d['title'] as String? ?? '',
          specialty:     (d['specialties'] as List?)?.firstOrNull?.toString() ?? '',
          authorName:    d['authorName'] as String? ?? '',
          authorImageUrl: d['authorImageUrl'] as String?,
          commentCount:  (d['commentCount'] as num?)?.toInt() ?? 0,
          likeCount:     (d['likeCount'] as num?)?.toInt() ?? 0,
          createdAt:     _parseTs(d['createdAt']),
          isSolved:      d['status'] == 'solved',
          urgency:       d['urgency'] as String? ?? 'routine',
        );
      }).toList();
    } catch (_) {
      // index hatası veya permission hatası — boş liste döner
    }

    // ── XP / level ──────────────────────────────────────────────
    final totalXp    = (u['xp'] as num?)?.toInt() ?? 0;
    final level      = _levelFromXp(totalXp);
    final levelTitle = KxLevelSystem.titleForLevel(level);
    final xpForThis  = KxLevelSystem.xpForLevel(level);
    final xpForPrev  = level > 1 ? KxLevelSystem.xpForLevel(level - 1) : 0;
    final xpCurrent  = (totalXp - xpForPrev).clamp(0, xpForThis);

    final stats = UserStats(
      userId:              user.uid,
      displayName:         u['displayName'] as String? ?? user.displayName ?? 'Doktor',
      specialty:           u['specialty'] as String? ?? '',
      photoUrl:            u['photoUrl'] as String? ?? user.photoURL,
      totalXp:             totalXp,
      xpCurrent:           xpCurrent,
      xpTotal:             xpForThis,
      level:               level,
      levelTitle:          levelTitle,
      totalCases:          (u['caseCount'] as num?)?.toInt() ?? 0,
      totalContributions:  (u['contributionCount'] as num?)?.toInt() ?? 0,
      totalCountries:      (u['countryCount'] as num?)?.toInt() ?? 0,
      rank:                (u['rank'] as num?)?.toInt(),
      role:                u['role'] as String? ?? '',
      institution:         u['institution'] as String?,
    );

    return DashboardSummary(
      stats: stats,
      recentCases: recentCases,
      community: const CommunityStats(
        onlineDoctors: 0,
        totalDoctors: 0,
        casesThisWeek: 0,
      ),
    );
  }

  // XP → level hesabı (KxLevelSystem ile senkron)
  int _levelFromXp(int xp) {
    int level = 1;
    while (level < 10 && xp >= KxLevelSystem.xpForLevel(level)) {
      level++;
    }
    return level;
  }

  DateTime _parseTs(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    return DateTime.now();
  }
}
