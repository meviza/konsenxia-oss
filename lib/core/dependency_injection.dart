import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'network/network_info.dart';
import 'storage/local_storage.dart';
import 'constants/app_constants.dart';

// Auth
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_user.dart';
import '../features/auth/domain/usecases/register_user.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

// Cases
import '../features/cases/data/repositories/case_repository_impl.dart';
import '../features/cases/data/repositories/case_assignment_repository_impl.dart';
import '../features/cases/domain/repositories/case_repository.dart';
import '../features/cases/domain/repositories/case_assignment_repository.dart';
import '../features/cases/domain/usecases/get_cases_usecase.dart';
import '../features/cases/domain/usecases/get_case_by_id_usecase.dart';
import '../features/cases/domain/usecases/create_case_usecase.dart';
import '../features/cases/domain/usecases/contribute_to_case_usecase.dart';
import '../features/cases/domain/usecases/search_cases_usecase.dart';
import '../features/cases/domain/usecases/watch_recent_cases_usecase.dart';
import '../features/cases/presentation/bloc/cases_bloc.dart';
import '../features/cases/presentation/bloc/case_detail_bloc.dart';

// Dashboard
import '../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';

// AI Chat
import '../features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import 'services/claude_ai_service.dart';
import 'services/ai_case_generator_service.dart';

// Leaderboard
import '../features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import '../features/leaderboard/domain/repositories/leaderboard_repository.dart';
import '../features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import '../features/leaderboard/presentation/bloc/leaderboard_bloc.dart';

// Messaging
import '../features/messaging/data/repositories/messaging_repository_impl.dart';
import '../features/messaging/domain/repositories/messaging_repository.dart';
import '../features/messaging/domain/usecases/watch_conversations_usecase.dart';
import '../features/messaging/domain/usecases/watch_messages_usecase.dart';
import '../features/messaging/domain/usecases/send_message_usecase.dart';
import '../features/messaging/domain/usecases/mark_as_read_usecase.dart';
import '../features/messaging/presentation/bloc/conversations_bloc.dart';
import '../features/messaging/presentation/bloc/messages_bloc.dart';

// Notifications
import '../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../features/notifications/domain/repositories/notifications_repository.dart';
import '../features/notifications/presentation/bloc/notifications_bloc.dart';

// Profile
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/update_profile_usecase.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';

// Search
import '../features/search/data/repositories/search_repository_impl.dart';
import '../features/search/domain/repositories/search_repository.dart';
import '../features/search/presentation/bloc/search_bloc.dart';

// Analytics
import '../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../features/analytics/domain/repositories/analytics_repository.dart';
import '../features/analytics/presentation/bloc/analytics_bloc.dart';

// Knowledge Hub
import '../features/knowledge_hub/data/repositories/hub_case_repository_impl.dart';
import '../features/knowledge_hub/domain/repositories/hub_case_repository.dart';
import '../features/knowledge_hub/domain/usecases/get_hub_cases_usecase.dart';
import '../features/knowledge_hub/domain/usecases/get_hub_case_detail_usecase.dart';
import '../features/knowledge_hub/domain/usecases/create_hub_case_usecase.dart';
import '../features/knowledge_hub/domain/usecases/like_hub_case_usecase.dart';
import '../features/knowledge_hub/presentation/bloc/hub_cases_bloc.dart';
import '../features/knowledge_hub/presentation/bloc/hub_case_detail_bloc.dart';

// Consensus
import '../features/collaboration/data/repositories/consensus_repository_impl.dart';
import '../features/collaboration/domain/repositories/consensus_repository.dart';
import '../features/collaboration/domain/usecases/get_polls_usecase.dart';
import '../features/collaboration/domain/usecases/vote_on_poll_usecase.dart';
import '../features/collaboration/presentation/bloc/consensus_bloc.dart';

// Appointments
import '../features/appointments/data/repositories/appointments_repository_impl.dart';
import '../features/appointments/domain/repositories/appointments_repository.dart';
import '../features/appointments/domain/usecases/get_appointments_usecase.dart';
import '../features/appointments/domain/usecases/cancel_appointment_usecase.dart';
import '../features/appointments/presentation/bloc/appointments_bloc.dart';

// Prescriptions
import '../features/prescriptions/data/repositories/prescriptions_repository_impl.dart';
import '../features/prescriptions/domain/repositories/prescriptions_repository.dart';
import '../features/prescriptions/domain/usecases/get_prescriptions_usecase.dart';
import '../features/prescriptions/presentation/bloc/prescriptions_bloc.dart';

// Reports
import '../features/reports/data/repositories/reports_repository_impl.dart';
import '../features/reports/domain/repositories/reports_repository.dart';
import '../features/reports/domain/usecases/get_reports_usecase.dart';
import '../features/reports/domain/usecases/upload_report_usecase.dart';
import '../features/reports/presentation/bloc/reports_bloc.dart';

// Case Simulation
import '../features/case_simulation/data/repositories/simulation_repository_impl.dart';
import '../features/case_simulation/domain/repositories/simulation_repository.dart';
import '../features/case_simulation/domain/usecases/get_scenarios_usecase.dart';
import '../features/case_simulation/domain/usecases/start_simulation_usecase.dart';
import '../features/case_simulation/domain/usecases/send_simulation_message_usecase.dart';
import '../features/case_simulation/domain/usecases/submit_diagnosis_usecase.dart';
import '../features/case_simulation/presentation/bloc/simulation_bloc.dart';

// Emergency Consultation
import '../features/emergency_consultation/data/repositories/emergency_repository_impl.dart';
import '../features/emergency_consultation/domain/repositories/emergency_repository.dart';
import '../features/emergency_consultation/domain/usecases/get_active_consultations_usecase.dart';
import '../features/emergency_consultation/domain/usecases/create_consultation_usecase.dart';
import '../features/emergency_consultation/domain/usecases/respond_to_consultation_usecase.dart';
import '../features/emergency_consultation/domain/usecases/get_available_experts_usecase.dart';
import '../features/emergency_consultation/presentation/bloc/emergency_bloc.dart';

// Differential Diagnosis
import '../features/differential_diagnosis/data/repositories/diagnosis_repository_impl.dart';
import '../features/differential_diagnosis/domain/repositories/diagnosis_repository.dart';
import '../features/differential_diagnosis/domain/usecases/analyze_diagnosis_usecase.dart';
import '../features/differential_diagnosis/domain/usecases/get_suggested_symptoms_usecase.dart';
import '../features/differential_diagnosis/presentation/bloc/diagnosis_bloc.dart';

// Medical Files
import '../features/medical_files/data/repositories/medical_files_repository_impl.dart';
import '../features/medical_files/domain/repositories/medical_files_repository.dart';
import '../features/medical_files/presentation/bloc/medical_files_bloc.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // ── External ─────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (opt, handler) async {
      final token = getIt<SharedPreferences>().getString('auth_token');
      if (token != null) opt.headers['Authorization'] = 'Bearer \$token';
      return handler.next(opt);
    },
  ));
  getIt.registerLazySingleton(() => dio);

  // ── Core ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  getIt.registerLazySingleton<LocalStorage>(
      () => LocalStorageImpl(getIt<SharedPreferences>()));

  // ── Auth ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(), getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton(() => LoginUser(getIt()));
  getIt.registerLazySingleton(() => RegisterUser(getIt()));
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
        loginUser: getIt<LoginUser>(),
        registerUser: getIt<RegisterUser>(),
        authRepository: getIt<AuthRepository>(),
        prefs: getIt<SharedPreferences>(),
      ));

  // ── Cases ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<CaseRepository>(() => CaseRepositoryImpl());
  getIt.registerLazySingleton<CaseAssignmentRepository>(
    () => CaseAssignmentRepositoryImpl(),
  );
  getIt.registerLazySingleton(() => GetCasesUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCaseByIdUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateCaseUseCase(getIt()));
  getIt.registerLazySingleton(() => ContributeToCaseUseCase(getIt()));
  getIt.registerLazySingleton(() => SearchCasesUseCase(getIt()));
  getIt.registerLazySingleton(() => WatchRecentCasesUseCase(getIt()));
  getIt.registerFactory<CasesBloc>(() => CasesBloc(
        getCases: getIt(),
        searchCases: getIt(),
        watchFeed: getIt(),
        repository: getIt(),
      ));
  getIt.registerFactory<CaseDetailBloc>(() => CaseDetailBloc(
        getCaseById: getIt(),
        contribute: getIt(),
        repository: getIt(),
      ));

  // ── Dashboard ─────────────────────────────────────────────────────
  getIt.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl());
  getIt.registerLazySingleton(
      () => GetDashboardSummaryUseCase(getIt<DashboardRepository>()));
  getIt.registerFactory<DashboardBloc>(
      () => DashboardBloc(
        getSummary: getIt(),
        prefs: getIt<SharedPreferences>(),
      ));
  getIt.registerLazySingleton<ClaudeAIService>(() => ClaudeAIService());
  getIt.registerLazySingleton<AICaseGeneratorService>(
    () => AICaseGeneratorService(getIt<ClaudeAIService>()),
  );
  getIt.registerFactory<AIChatBloc>(() => AIChatBloc(
        dio: getIt<Dio>(),
        storage: getIt<LocalStorage>(),
        claudeAI: getIt<ClaudeAIService>(),
      ));

  // ── Leaderboard ───────────────────────────────────────────────────
  getIt.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(),
  );
  getIt.registerLazySingleton(() => GetLeaderboardUseCase(getIt()));
  getIt.registerFactory<LeaderboardBloc>(
    () => LeaderboardBloc(getLeaderboard: getIt()),
  );

  // ── Messaging ─────────────────────────────────────────────────────
  getIt.registerLazySingleton<MessagingRepository>(
    () => MessagingRepositoryImpl(),
  );
  getIt.registerLazySingleton(() => WatchConversationsUseCase(getIt()));
  getIt.registerLazySingleton(() => WatchMessagesUseCase(getIt()));
  getIt.registerLazySingleton(() => SendMessageUseCase(getIt()));
  getIt.registerLazySingleton(() => MarkAsReadUseCase(getIt()));
  getIt.registerLazySingleton<ConversationsBloc>(
    () => ConversationsBloc(watchConversations: getIt()),
  );
  getIt.registerFactory<MessagesBloc>(() => MessagesBloc(
        watchMessages: getIt(),
        sendMessage: getIt(),
        markAsRead: getIt(),
      ));

  // ── Notifications ─────────────────────────────────────────────────
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(),
  );
  getIt.registerLazySingleton<NotificationsBloc>(
    () => NotificationsBloc(repository: getIt()),
  );

  // ── Profile ───────────────────────────────────────────────────────
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(),
  );
  getIt.registerLazySingleton(
      () => UpdateProfileUseCase(getIt<ProfileRepository>()));
  getIt.registerLazySingleton<ProfileBloc>(() => ProfileBloc(
        getSummary: getIt(),
        updateProfile: getIt(),
        prefs: getIt<SharedPreferences>(),
      ));

  // ── Search ────────────────────────────────────────────────────────
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(),
  );
  getIt.registerLazySingleton<SearchBloc>(
    () => SearchBloc(repository: getIt()),
  );

  // ── Analytics ─────────────────────────────────────────────────────
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(),
  );
  getIt.registerLazySingleton<AnalyticsBloc>(
    () => AnalyticsBloc(repository: getIt()),
  );

  // ── Knowledge Hub ─────────────────────────────────────────────────
  getIt.registerLazySingleton<HubCaseRepository>(
    () => HubCaseRepositoryImpl(),
  );
  getIt.registerLazySingleton(
      () => GetHubCasesUseCase(getIt<HubCaseRepository>()));
  getIt.registerLazySingleton(
      () => GetHubCaseDetailUseCase(getIt<HubCaseRepository>()));
  getIt.registerLazySingleton(
      () => CreateHubCaseUseCase(getIt<HubCaseRepository>()));
  getIt.registerLazySingleton(
      () => LikeHubCaseUseCase(getIt<HubCaseRepository>()));
  getIt.registerLazySingleton(
      () => SearchHubCasesUseCase(getIt<HubCaseRepository>()));
  getIt.registerLazySingleton<HubCasesBloc>(() => HubCasesBloc(
        getHubCases: getIt(),
        likeHubCase: getIt(),
        searchHubCases: getIt(),
      ));
  getIt.registerFactory<HubCaseDetailBloc>(() => HubCaseDetailBloc(
        getDetail: getIt(),
        like: getIt(),
        repository: getIt(),
      ));

  // ── Consensus ─────────────────────────────────────────────────────
  getIt.registerLazySingleton<ConsensusRepository>(
    () => ConsensusRepositoryImpl(),
  );
  getIt.registerLazySingleton(
      () => GetPollsUseCase(getIt<ConsensusRepository>()));
  getIt.registerLazySingleton(
      () => VoteOnPollUseCase(getIt<ConsensusRepository>()));
  getIt.registerLazySingleton<ConsensusBloc>(() => ConsensusBloc(
        getPolls: getIt(),
        vote: getIt(),
      ));

  // ── Appointments ──────────────────────────────────────────────────
  getIt.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(),
  );
  getIt.registerLazySingleton(
      () => GetAppointmentsUseCase(getIt<AppointmentsRepository>()));
  getIt.registerLazySingleton(
      () => CancelAppointmentUseCase(getIt<AppointmentsRepository>()));
  getIt.registerFactory<AppointmentsBloc>(() => AppointmentsBloc(
        getAppointments: getIt(),
        cancelAppointment: getIt(),
      ));

  // ── Prescriptions ─────────────────────────────────────────────────
  getIt.registerLazySingleton<PrescriptionsRepository>(
    () => PrescriptionsRepositoryImpl(),
  );
  getIt.registerLazySingleton(
      () => GetPrescriptionsUseCase(getIt<PrescriptionsRepository>()));
  getIt.registerFactory<PrescriptionsBloc>(() => PrescriptionsBloc(
        getPrescriptions: getIt(),
      ));

  // ── Reports ───────────────────────────────────────────────────────
  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(),
  );
  getIt.registerLazySingleton(
      () => GetReportsUseCase(getIt<ReportsRepository>()));
  getIt.registerLazySingleton(
      () => UploadReportUseCase(getIt<ReportsRepository>()));
  getIt.registerFactory<ReportsBloc>(() => ReportsBloc(
        getReports: getIt(),
      ));

  // ── Case Simulation ────────────────────────────────────────────────
  getIt.registerLazySingleton<SimulationRepository>(
    () => SimulationRepositoryImpl(),
  );
  getIt.registerLazySingleton(() => GetScenariosUseCase(getIt()));
  getIt.registerLazySingleton(() => StartSimulationUseCase(getIt()));
  getIt.registerLazySingleton(() => SendSimulationMessageUseCase(getIt()));
  getIt.registerLazySingleton(() => SubmitDiagnosisUseCase(getIt()));
  getIt.registerFactory<SimulationBloc>(() => SimulationBloc(
        getScenarios: getIt(),
        startSimulation: getIt(),
        sendMessage: getIt(),
        submitDiagnosis: getIt(),
        repository: getIt(),
      ));

  // ── Emergency Consultation ─────────────────────────────────────────
  getIt.registerLazySingleton<EmergencyRepository>(
    () => EmergencyRepositoryImpl(),
  );
  getIt.registerLazySingleton(() => GetActiveConsultationsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateConsultationUseCase(getIt()));
  getIt.registerLazySingleton(() => RespondToConsultationUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAvailableExpertsUseCase(getIt()));
  getIt.registerFactory<EmergencyBloc>(() => EmergencyBloc(
        getActive: getIt(),
        create: getIt(),
        respond: getIt(),
        getExperts: getIt(),
      ));

  // ── Differential Diagnosis ─────────────────────────────────────────
  getIt.registerLazySingleton<DiagnosisRepository>(
    () => DiagnosisRepositoryImpl(),
  );
  getIt.registerLazySingleton(() => AnalyzeDiagnosisUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSuggestedSymptomsUseCase(getIt()));
  getIt.registerFactory<DiagnosisBloc>(() => DiagnosisBloc(
        analyze: getIt(),
        getSuggestions: getIt(),
        repository: getIt(),
      ));

  // ── Medical Files ────────────────────────────────────────────────────
  getIt.registerLazySingleton<MedicalFilesRepository>(
    () => MedicalFilesRepositoryImpl(),
  );
  getIt.registerFactory<MedicalFilesBloc>(
    () => MedicalFilesBloc(
      repository: getIt(),
      aiService: getIt<ClaudeAIService>(),
    ),
  );
}
