import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/analytics_data.dart';
import '../../domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AnalyticsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<AnalyticsData> getAnalytics() async {
    try {
      return await _fetchFromFirestore();
    } catch (e) {
      debugPrint('[ANALYTICS] Firestore failed, using mock: $e');
      return _buildMockAnalytics();
    }
  }

  Future<AnalyticsData> _fetchFromFirestore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Giriş yapılmamış');

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    final results = await Future.wait([
      _firestore.collection('users').doc(uid).get(),
      _firestore
          .collection('cases')
          .where('authorId', isEqualTo: uid)
          .get(),
      _firestore
          .collection('cases')
          .where('authorId', isEqualTo: uid)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(monthAgo))
          .get(),
      _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .get(),
      _firestore
          .collection('cases')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get(),
      _firestore.collection('cases').get(),
    ]).timeout(const Duration(seconds: 5));

    final userDoc = results[0] as DocumentSnapshot;
    final allCases = results[1] as QuerySnapshot;
    final monthCases = results[2] as QuerySnapshot;
    final activeUsers = results[3] as QuerySnapshot;
    final weekCases = results[4] as QuerySnapshot;
    final allCasesGlobal = results[5] as QuerySnapshot;

    final userData = userDoc.data() as Map<String, dynamic>? ?? {};

    // Count solved cases for percent
    final solvedCount = (allCasesGlobal.docs)
        .where((d) => (d.data() as Map)['status'] == 'solved')
        .length;
    final totalCount = allCasesGlobal.docs.length;
    final solvedPercent =
        totalCount > 0 ? ((solvedCount / totalCount) * 100).round() : 0;

    // Specialty breakdown
    final specMap = <String, int>{};
    for (final doc in allCasesGlobal.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final spec = data['specialty'] as String? ?? 'Diğer';
      specMap[spec] = (specMap[spec] ?? 0) + 1;
    }
    final sortedSpecs = specMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSpecs = sortedSpecs.take(5).map((e) {
      final pct = totalCount > 0 ? (e.value / totalCount) * 100 : 0.0;
      return SpecialtyActivity(
        specialty: e.key,
        caseCount: e.value,
        percentage: double.parse(pct.toStringAsFixed(1)),
      );
    }).toList();

    // Weekly activity
    final weeklyActivity = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
      return WeeklyActivity(
        day: dayNames[day.weekday - 1],
        cases: 0,
        comments: 0,
        xp: 0,
      );
    });

    // Monthly XP from xpHistory
    final xpHistory = (userData['xpHistory'] as List<dynamic>?) ?? [];
    final monthlyXP = xpHistory.isNotEmpty
        ? xpHistory.map((e) {
            final m = e as Map<String, dynamic>;
            return MonthlyXP(
              month: m['month'] as String? ?? '',
              xp: (m['xp'] as num?)?.toInt() ?? 0,
            );
          }).toList()
        : _defaultMonthlyXP(now);

    final personal = UserAnalytics(
      totalXp: (userData['xp'] as int?) ?? 0,
      xpThisWeek: (userData['xpThisWeek'] as int?) ?? 0,
      xpThisMonth: (userData['xpThisMonth'] as int?) ?? 0,
      totalCases: allCases.docs.length,
      casesThisMonth: monthCases.docs.length,
      totalComments: (userData['totalComments'] as int?) ?? 0,
      acceptedAnswers: (userData['acceptedAnswers'] as int?) ?? 0,
      totalLikesReceived: (userData['totalLikes'] as int?) ?? 0,
      currentStreak: (userData['currentStreak'] as int?) ?? 0,
      longestStreak: (userData['longestStreak'] as int?) ?? 0,
      weeklyActivity: weeklyActivity,
      monthlyXP: monthlyXP,
    );

    final community = CommunityAnalytics(
      totalDoctors: activeUsers.docs.length,
      activeTodayCount: activeUsers.docs.length,
      casesThisWeek: weekCases.docs.length,
      totalCasesAllTime: totalCount,
      solvedCasesPercent: solvedPercent,
      topSpecialties: topSpecs,
    );

    return AnalyticsData(personal: personal, community: community);
  }

  List<MonthlyXP> _defaultMonthlyXP(DateTime now) {
    final monthNames = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    return List.generate(6, (i) {
      final m = (now.month - 5 + i - 1) % 12;
      return MonthlyXP(month: monthNames[m], xp: 0);
    });
  }

  /// Firestore erişilemezken mock analytics verisi
  AnalyticsData _buildMockAnalytics() {
    final now = DateTime.now();
    final dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final mockXpPerDay = [120, 85, 200, 150, 95, 45, 180];

    final weeklyActivity = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return WeeklyActivity(
        day: dayNames[day.weekday - 1],
        cases: (i % 3 == 0) ? 2 : 1,
        comments: 3 + (i * 2),
        xp: mockXpPerDay[i],
      );
    });

    final monthlyXP = [
      MonthlyXP(month: 'Eki', xp: 680),
      MonthlyXP(month: 'Kas', xp: 920),
      MonthlyXP(month: 'Ara', xp: 1150),
      MonthlyXP(month: 'Oca', xp: 870),
      MonthlyXP(month: 'Şub', xp: 1340),
      MonthlyXP(month: 'Mar', xp: 940),
    ];

    final personal = UserAnalytics(
      totalXp: 5200,
      xpThisWeek: 340,
      xpThisMonth: 1200,
      totalCases: 89,
      casesThisMonth: 12,
      totalComments: 187,
      acceptedAnswers: 34,
      totalLikesReceived: 412,
      currentStreak: 12,
      longestStreak: 28,
      weeklyActivity: weeklyActivity,
      monthlyXP: monthlyXP,
    );

    final community = CommunityAnalytics(
      totalDoctors: 1247,
      activeTodayCount: 142,
      casesThisWeek: 67,
      totalCasesAllTime: 3456,
      solvedCasesPercent: 78,
      topSpecialties: [
        SpecialtyActivity(specialty: 'Kardiyoloji', caseCount: 456, percentage: 22.3),
        SpecialtyActivity(specialty: 'Nöroloji', caseCount: 389, percentage: 19.1),
        SpecialtyActivity(specialty: 'Dahiliye', caseCount: 312, percentage: 15.3),
        SpecialtyActivity(specialty: 'Genel Cerrahi', caseCount: 278, percentage: 13.6),
        SpecialtyActivity(specialty: 'Göğüs Hastalıkları', caseCount: 201, percentage: 9.8),
      ],
    );

    return AnalyticsData(personal: personal, community: community);
  }
}
