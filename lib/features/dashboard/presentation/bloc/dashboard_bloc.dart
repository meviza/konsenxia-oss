import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Dashboard BLoC — KONSENXIA doktor platformu ana ekranı
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase _getSummary;
  final SharedPreferences _prefs;

  DashboardBloc({
    required GetDashboardSummaryUseCase getSummary,
    required SharedPreferences prefs,
  })  : _getSummary = getSummary,
        _prefs = prefs,
        super(const DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoad);
    on<RefreshDashboardEvent>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefresh(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    await _fetchAndEmit(emit);
  }

  /// Kullanıcı bilgilerini SharedPreferences'tan oku
  Map<String, dynamic>? _getUserData() {
    final userJson = _prefs.getString('auth_user');
    if (userJson == null) return null;
    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchAndEmit(Emitter<DashboardState> emit) async {
    // Küçük gecikme — AuthBloc SharedPreferences'a yazsın
    await Future.delayed(const Duration(milliseconds: 100));

    final userData = _getUserData();
    final userRole = userData?['role'] as String? ?? 'RESIDENT';
    final firstName = userData?['firstName'] as String? ?? 'Kullanıcı';
    final lastName = userData?['lastName'] as String? ?? '';

    debugPrint('[DASHBOARD] role=$userRole, name=$firstName $lastName');

    try {
      final summary = await _getSummary();

      // Use Firestore role if available, otherwise use SharedPreferences role
      final firestoreRole = summary.stats.role.isNotEmpty
          ? summary.stats.role
          : userRole;

      // If Firestore role differs from local, update SharedPreferences
      if (firestoreRole != userRole && firestoreRole.isNotEmpty) {
        _syncRoleToLocal(firestoreRole);
      }

      // Fetch real assigned cases from Firestore
      final assignedCases = await _fetchAssignedCases();

      emit(DashboardLoaded.fromSummary(summary).copyWith(
        userRole: firestoreRole,
        userName: '$firstName $lastName',
        assignedCases: assignedCases,
      ));
    } catch (e) {
      // Backend erisilemez -- rol-bazli mock data ile yukle
      emit(_buildMockDashboard(userRole, firstName, lastName));
    }
  }

  /// Sync Firestore role to SharedPreferences auth_user JSON
  void _syncRoleToLocal(String firestoreRole) {
    try {
      final userJson = _prefs.getString('auth_user');
      if (userJson == null) return;
      final data = jsonDecode(userJson) as Map<String, dynamic>;
      data['role'] = firestoreRole;
      _prefs.setString('auth_user', jsonEncode(data));
    } catch (_) {}
  }

  /// Fetch assigned cases from Firestore for current user
  Future<List<DashboardAssignment>> _fetchAssignedCases() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      final uid = currentUser.uid;
      final firestore = FirebaseFirestore.instance;

      // Query case_assignments where userId == currentUser.uid OR assignedTo == currentUser.uid
      final snap = await firestore
          .collection('case_assignments')
          .where('assignedTo', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 5));

      if (snap.docs.isEmpty) {
        // Also try userId field (used by _takeCaseInFirestore)
        final snap2 = await firestore
            .collection('case_assignments')
            .where('userId', isEqualTo: uid)
            .limit(20)
            .get()
            .timeout(const Duration(seconds: 5));

        return snap2.docs.map((doc) => _assignmentFromDoc(doc)).toList();
      }

      return snap.docs.map((doc) => _assignmentFromDoc(doc)).toList();
    } catch (e) {
      debugPrint('[DASHBOARD] Failed to fetch assigned cases: $e');
      return [];
    }
  }

  DashboardAssignment _assignmentFromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return DashboardAssignment(
      assignmentId: doc.id,
      caseId: d['caseId'] as String? ?? '',
      caseTitle: d['caseTitle'] as String? ?? 'Vaka',
      specialty: d['caseSpecialty'] as String? ?? '',
      assignedByName: d['assignedByName'] as String? ?? '',
      assignedByTitle: d['assignedByTitle'] as String? ?? 'Dr.',
      assignedAt: (d['createdAt'] as Timestamp?)?.toDate() ??
          (d['assignedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
      status: d['status'] as String? ?? 'pending',
    );
  }

  /// Backend yokken rol-bazli mock dashboard verisi
  DashboardLoaded _buildMockDashboard(
      String role, String firstName, String lastName) {
    final now = DateTime.now();

    // Rol-bazlı XP ve seviye hesapla
    final (level, levelTitle, xp, xpTotal) = switch (role) {
      'INTERN' => (1, 'Stajyer', 120, 500),
      'RESIDENT' => (3, 'Asistan', 1450, 3000),
      'SPECIALIST' => (7, 'Uzman', 5200, 8000),
      'PROFESSOR' => (12, 'Akademisyen', 15000, 20000),
      _ => (3, 'Asistan', 1450, 3000),
    };

    // Rol-bazlı istatistikler
    final (cases, contributions) = switch (role) {
      'INTERN' => (8, 15),
      'RESIDENT' => (24, 67),
      'SPECIALIST' => (89, 234),
      'PROFESSOR' => (156, 512),
      _ => (24, 67),
    };

    // Intern/Resident için atanmış vakalar
    final assignments = (role == 'INTERN' || role == 'RESIDENT')
        ? [
            DashboardAssignment(
              assignmentId: 'a1',
              caseId: 'case_001',
              caseTitle: '45Y/E — Akut karın ağrısı, defans pozitif',
              specialty: 'Genel Cerrahi',
              assignedByName: 'Prof. Dr. Ayşe Yılmaz',
              assignedByTitle: 'Prof. Dr.',
              assignedAt: now.subtract(const Duration(hours: 3)),
              dueDate: now.add(const Duration(days: 2)),
              status: 'pending',
            ),
            DashboardAssignment(
              assignmentId: 'a2',
              caseId: 'case_002',
              caseTitle: '62Y/K — Dispne, bilateral ral, BNP yüksek',
              specialty: 'Kardiyoloji',
              assignedByName: 'Uzm. Dr. Mehmet Kara',
              assignedByTitle: 'Uzm. Dr.',
              assignedAt: now.subtract(const Duration(days: 1)),
              dueDate: now.add(const Duration(days: 3)),
              status: 'in_progress',
            ),
            DashboardAssignment(
              assignmentId: 'a3',
              caseId: 'case_003',
              caseTitle: '28Y/K — Tekrarlayan baş ağrısı, papil ödem',
              specialty: 'Nöroloji',
              assignedByName: 'Prof. Dr. Ali Demir',
              assignedByTitle: 'Prof. Dr.',
              assignedAt: now.subtract(const Duration(days: 3)),
              status: 'completed',
            ),
          ]
        : <DashboardAssignment>[];

    return DashboardLoaded(
      totalXp: xp,
      level: level,
      levelTitle: levelTitle,
      xpCurrent: xp % xpTotal,
      xpTotal: xpTotal,
      totalCases: cases,
      totalContributions: contributions,
      totalCountries: 12,
      rank: switch (role) {
        'INTERN' => 847,
        'RESIDENT' => 234,
        'SPECIALIST' => 45,
        'PROFESSOR' => 8,
        _ => 234,
      },
      onlineDoctors: 142,
      userRole: role,
      userName: '$firstName $lastName',
      assignedCases: assignments,
      recentCases: [
        DashboardCase(
          id: 'rc1',
          title: '55Y/E — STEMI şüphesi, anterior ST elevasyonu',
          specialty: 'Kardiyoloji',
          authorName: 'Dr. Ahmet Yılmaz',
          commentCount: 12,
          postedAt: now.subtract(const Duration(hours: 2)),
        ),
        DashboardCase(
          id: 'rc2',
          title: '38Y/K — Ateş, öksürük, bilateral infiltrasyon',
          specialty: 'Göğüs Hastalıkları',
          authorName: 'Uzm. Dr. Fatma Kaya',
          commentCount: 8,
          postedAt: now.subtract(const Duration(hours: 5)),
        ),
        DashboardCase(
          id: 'rc3',
          title: '72Y/E — Ani bilinç kaybı, fokal nörolojik defisit',
          specialty: 'Nöroloji',
          authorName: 'Prof. Dr. Mustafa Öz',
          commentCount: 23,
          postedAt: now.subtract(const Duration(hours: 8)),
          isSolved: true,
        ),
      ],
      recentNotifications: [
        DashboardNotificationPreview(
          id: 'n1',
          type: role == 'INTERN' || role == 'RESIDENT'
              ? 'case_assigned'
              : 'comment',
          title: role == 'INTERN' || role == 'RESIDENT'
              ? 'Yeni vaka atandı'
              : 'Vakanıza yorum geldi',
          body: role == 'INTERN' || role == 'RESIDENT'
              ? 'Prof. Dr. Ayşe Yılmaz size yeni bir vaka atadı'
              : 'Dr. Kerem vakanıza differansiyel tanı önerisi ekledi',
          createdAt: now.subtract(const Duration(minutes: 30)),
        ),
      ],
    );
  }
}
