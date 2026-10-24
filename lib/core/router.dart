import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'storage/local_storage.dart';
import 'widgets/shells/main_shell.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/cases/presentation/pages/cases_page.dart';
import '../features/cases/presentation/pages/case_detail_page.dart';
import '../features/cases/presentation/bloc/case_detail_bloc.dart';
import '../features/cases/presentation/pages/create_case_page.dart';
import '../features/leaderboard/presentation/pages/leaderboard_page.dart';
import '../features/ai_chat/presentation/pages/ai_chat_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/messaging/presentation/bloc/conversations_bloc.dart';
import '../features/messaging/presentation/bloc/messages_bloc.dart';
import '../features/messaging/presentation/pages/messaging_page.dart';
import '../features/messaging/presentation/pages/conversation_detail_page.dart';
import '../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/search/presentation/bloc/search_bloc.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
// Knowledge Hub
import '../features/knowledge_hub/presentation/pages/knowledge_hub_page.dart';
import '../features/knowledge_hub/presentation/pages/medical_case_detail_page.dart';
import '../features/knowledge_hub/presentation/pages/create_case_page.dart';
import '../features/knowledge_hub/presentation/bloc/hub_cases_bloc.dart';
import '../features/knowledge_hub/presentation/bloc/hub_case_detail_bloc.dart';
// Consensus
import '../features/collaboration/presentation/pages/consensus_page.dart';
import '../features/collaboration/presentation/bloc/consensus_bloc.dart';
// Health Records
import '../features/reports/presentation/pages/health_timeline_page.dart';
import '../features/reports/presentation/pages/report_detail_page.dart';
import '../features/reports/presentation/pages/report_upload_page.dart';
import '../features/reports/presentation/bloc/reports_bloc.dart';
import '../features/appointments/presentation/pages/appointments_page.dart';
import '../features/appointments/presentation/bloc/appointments_bloc.dart';
import '../features/prescriptions/presentation/pages/prescriptions_page.dart';
import '../features/prescriptions/presentation/bloc/prescriptions_bloc.dart';
// Other
import '../features/analytics/presentation/pages/drug_analytics_page.dart';
import '../features/dashboard/presentation/pages/health_overview_page.dart';
import '../features/system_status/presentation/pages/system_status_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/support_page.dart';
import '../features/settings/presentation/pages/kvkk_page.dart';
import '../features/settings/presentation/pages/privacy_policy_page.dart';
import '../features/settings/presentation/pages/terms_of_service_page.dart';
import '../features/settings/presentation/pages/cookie_policy_page.dart';
import '../features/ai_chat/presentation/pages/advanced_ai_chat_page.dart';
import '../features/ai_chat/presentation/pages/evidence_based_page.dart';
import '../features/ai_chat/presentation/pages/drug_analysis_page.dart';
import '../features/ai_chat/presentation/pages/case_review_page.dart';
// New features
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/case_simulation/presentation/pages/simulation_page.dart';
import '../features/case_simulation/presentation/bloc/simulation_bloc.dart';
import '../features/emergency_consultation/presentation/pages/emergency_consultation_page.dart';
import '../features/emergency_consultation/presentation/bloc/emergency_bloc.dart';
import '../features/differential_diagnosis/presentation/pages/differential_diagnosis_page.dart';
import '../features/differential_diagnosis/presentation/bloc/diagnosis_bloc.dart';
// Assistants
import '../features/assistants/presentation/pages/assistants_page.dart';
// Medical Files
import '../features/medical_files/presentation/pages/medical_files_page.dart';
import '../features/medical_files/presentation/bloc/medical_files_bloc.dart';
// Bookmarks
import '../features/bookmarks/presentation/pages/bookmarks_page.dart';
import '../design_system/tokens/app_colors.dart';
import '../design_system/tokens/app_typography.dart';
import '../design_system/animations/kx_page_transitions.dart';

/// KONSENXIA AppRouter
///
/// GoRouter tabanlı navigasyon. Auth durumuna göre yönlendirme yapar.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      // ── Splash ──────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // ── Onboarding ────────────────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => KxTransitions.fade(
          key: state.pageKey,
          child: OnboardingPage(
            onComplete: () {
              GetIt.instance<LocalStorage>().setBool('has_seen_onboarding', true);
              GoRouter.of(context).go('/login');
            },
          ),
        ),
      ),

      // ── Auth ────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Ana Uygulama (ShellRoute — bottom nav için) ──────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/cases',
            name: 'cases',
            builder: (context, state) => const CasesPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'create-case',
                builder: (context, state) => const CreateCasePage(),
              ),
              GoRoute(
                path: ':id',
                name: 'case-detail',
                builder: (context, state) {
                  final caseId = state.pathParameters['id']!;
                  return BlocProvider(
                    create: (_) => GetIt.instance<CaseDetailBloc>(),
                    child: CaseDetailPage(caseId: caseId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/ai-chat',
            name: 'ai-chat',
            builder: (context, state) => const AIChatPage(),
          ),
          GoRoute(
            path: '/knowledge-hub',
            name: 'knowledge-hub',
            builder: (context, state) => BlocProvider.value(
              value: GetIt.instance<HubCasesBloc>(),
              child: const KnowledgeHubPage(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: 'knowledge-hub-new',
                builder: (context, state) => const CreateKnowledgeHubCasePage(),
              ),
              GoRoute(
                path: ':id',
                name: 'knowledge-hub-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return BlocProvider(
                    create: (_) => GetIt.instance<HubCaseDetailBloc>(),
                    child: MedicalCaseDetailPage(caseId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => BlocProvider.value(
              value: GetIt.instance<ProfileBloc>(),
              child: const ProfilePage(),
            ),
          ),
        ],
      ),

      // ── Diğer ana rotalar ─────────────────────────────────────────
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardPage(),
      ),

      // ── Assistants (Professor/Specialist) ──────────────────────────
      GoRoute(
        path: '/assistants',
        name: 'assistants',
        builder: (context, state) => const AssistantsPage(),
      ),

      // ── Messaging ────────────────────────────────────────────────
      GoRoute(
        path: '/messages',
        name: 'messages',
        builder: (context, state) => BlocProvider.value(
          value: GetIt.instance<ConversationsBloc>(),
          child: const MessagingPage(),
        ),
      ),
      GoRoute(
        path: '/messages/:convId',
        name: 'conversation-detail',
        builder: (context, state) {
          final convId = state.pathParameters['convId']!;
          final extra = state.extra as Map<String, String>? ?? {};
          return BlocProvider(
            create: (_) => GetIt.instance<MessagesBloc>(),
            child: ConversationDetailPage(
              conversationId: convId,
              otherUserId: extra['otherUserId'] ?? '',
              otherUserName: extra['otherUserName'] ?? 'Doktor',
            ),
          );
        },
      ),

      // ── Notifications ─────────────────────────────────────────────
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => BlocProvider.value(
          value: GetIt.instance<NotificationsBloc>(),
          child: const NotificationsPage(),
        ),
      ),

      // ── Search ───────────────────────────────────────────────────
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => BlocProvider.value(
          value: GetIt.instance<SearchBloc>(),
          child: const SearchPage(),
        ),
      ),

      // ── Analytics ─────────────────────────────────────────────────
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => BlocProvider.value(
          value: GetIt.instance<AnalyticsBloc>(),
          child: const AnalyticsPage(),
        ),
      ),

      // ── Consensus ─────────────────────────────────────────────────
      GoRoute(
        path: '/consensus',
        name: 'consensus',
        builder: (context, state) => BlocProvider.value(
          value: GetIt.instance<ConsensusBloc>(),
          child: const ConsensusPage(),
        ),
      ),

      // ── Health Timeline (Reports) ──────────────────────────────────
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.instance<ReportsBloc>(),
          child: const HealthTimelinePage(),
        ),
      ),
      GoRoute(
        path: '/reports/upload',
        name: 'reports-upload',
        builder: (context, state) => const ReportUploadPage(),
      ),
      GoRoute(
        path: '/reports/:id',
        name: 'report-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReportDetailPage(reportId: id);
        },
      ),

      // ── Appointments ───────────────────────────────────────────────
      GoRoute(
        path: '/appointments',
        name: 'appointments',
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.instance<AppointmentsBloc>(),
          child: const AppointmentsPage(),
        ),
      ),

      // ── Prescriptions ──────────────────────────────────────────────
      GoRoute(
        path: '/prescriptions',
        name: 'prescriptions',
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.instance<PrescriptionsBloc>(),
          child: const PrescriptionsPage(),
        ),
      ),

      // ── Drug Analytics ─────────────────────────────────────────────
      GoRoute(
        path: '/drug-analytics',
        name: 'drug-analytics',
        builder: (context, state) => const DrugAnalyticsPage(),
      ),

      // ── Health Overview ────────────────────────────────────────────
      GoRoute(
        path: '/health-overview',
        name: 'health-overview',
        builder: (context, state) => const HealthOverviewPage(),
      ),

      // ── System Status ──────────────────────────────────────────────
      GoRoute(
        path: '/system-status',
        name: 'system-status',
        builder: (context, state) => const SystemStatusPage(),
      ),

      // ── Settings ───────────────────────────────────────────────────
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) => const SupportPage(),
      ),
      GoRoute(
        path: '/kvkk',
        name: 'kvkk',
        builder: (context, state) => const KvkkPage(),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsOfServicePage(),
      ),
      GoRoute(
        path: '/cookie-policy',
        name: 'cookie-policy',
        builder: (context, state) => const CookiePolicyPage(),
      ),

      // ── Advanced AI Chat ───────────────────────────────────────────
      GoRoute(
        path: '/advanced-ai-chat',
        name: 'advanced-ai-chat',
        builder: (context, state) => const AdvancedAiChatPage(),
      ),

      // ── Evidence-Based (Kanıta Dayalı) ──────────────────────────────
      GoRoute(
        path: '/evidence-based',
        name: 'evidence-based',
        pageBuilder: (context, state) => KxTransitions.scaleUp(
          key: state.pageKey,
          child: const EvidenceBasedPage(),
        ),
      ),

      // ── Drug Analysis (İlaç Analizi) ────────────────────────────────
      GoRoute(
        path: '/drug-analysis',
        name: 'drug-analysis',
        pageBuilder: (context, state) => KxTransitions.scaleUp(
          key: state.pageKey,
          child: const DrugAnalysisPage(),
        ),
      ),

      // ── Case Review (Vaka İnceleme) ─────────────────────────────────
      GoRoute(
        path: '/case-review',
        name: 'case-review',
        pageBuilder: (context, state) => KxTransitions.scaleUp(
          key: state.pageKey,
          child: const CaseReviewPage(),
        ),
      ),

      // ── Case Simulation ─────────────────────────────────────────────
      GoRoute(
        path: '/simulation',
        name: 'simulation',
        pageBuilder: (context, state) => KxTransitions.scaleUp(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => GetIt.instance<SimulationBloc>(),
            child: const SimulationPage(),
          ),
        ),
      ),

      // ── Emergency Consultation ──────────────────────────────────────
      GoRoute(
        path: '/emergency',
        name: 'emergency',
        pageBuilder: (context, state) => KxTransitions.slideUp(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => GetIt.instance<EmergencyBloc>(),
            child: const EmergencyConsultationPage(),
          ),
        ),
      ),

      // ── Differential Diagnosis ──────────────────────────────────────
      GoRoute(
        path: '/differential-diagnosis',
        name: 'differential-diagnosis',
        pageBuilder: (context, state) => KxTransitions.scaleUp(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => GetIt.instance<DiagnosisBloc>(),
            child: const DifferentialDiagnosisPage(),
          ),
        ),
      ),

      // ── Medical Files ─────────────────────────────────────────────────
      GoRoute(
        path: '/medical-files',
        name: 'medical-files',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return BlocProvider(
            create: (_) => GetIt.instance<MedicalFilesBloc>(),
            child: MedicalFilesPage(caseId: extra['caseId']),
          );
        },
      ),

      // ── Bookmarks ──────────────────────────────────────────────────────
      GoRoute(
        path: '/bookmarks',
        name: 'bookmarks',
        builder: (context, state) => const BookmarksPage(),
      ),
    ],

    // ── Auth redirect ──────────────────────────────────────────────
    redirect: (context, state) {
      final localStorage = GetIt.instance<LocalStorage>();
      final isAuthenticated = localStorage.isAuthenticated();
      final path = state.uri.path;

      if (path == '/splash') return null;

      final isAuthRoute = path == '/login' || path == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';

      return null;
    },

    // ── Error sayfası ──────────────────────────────────────────────
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
  );
}

class _ErrorPage extends StatelessWidget {
  final Exception? error;
  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: KxColors.crimson400),
            const SizedBox(height: 16),
            Text('Sayfa bulunamadı', style: KxTypography.headingMd),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Beklenmeyen bir hata oluştu.',
              style: KxTypography.bodyMd
                  .copyWith(color: KxColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/dashboard'),
              child: Text('Ana sayfaya dön',
                  style: KxTypography.labelMd
                      .copyWith(color: KxColors.teal400)),
            ),
          ],
        ),
      ),
    );
  }
}
