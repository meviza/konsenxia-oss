import '../constants/app_constants.dart';

abstract class ApiEndpoints {
  // Base URLs
  static const String baseUrl = AppConstants.baseUrl;
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String logout = '$baseUrl/auth/logout';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String resetPassword = '$baseUrl/auth/reset-password';
  static const String verifyEmail = '$baseUrl/auth/verify-email';
  static const String changePassword = '$baseUrl/auth/change-password';
  
  // User endpoints
  static const String profile = '$baseUrl/users/profile';
  static const String updateProfile = '$baseUrl/users/profile';
  static const String uploadAvatar = '$baseUrl/users/avatar';
  static const String deleteAccount = '$baseUrl/users/account';
  static const String userSettings = '$baseUrl/users/settings';
  static const String updateSettings = '$baseUrl/users/settings';
  
  // AI Chat endpoints
  static const String aiChat = '$baseUrl/ai/chat';
  static const String aiChatHistory = '$baseUrl/ai/chat/history';
  static const String aiChatClear = '$baseUrl/ai/chat/clear';
  static const String aiSuggestions = '$baseUrl/ai/suggestions';
  static const String aiAnalyze = '$baseUrl/ai/analyze';
  static const String aiMedicalInfo = '$baseUrl/ai/medical-info';
  static const String aiSymptomCheck = '$baseUrl/ai/symptom-check';
  static const String aiMedicationInfo = '$baseUrl/ai/medication-info';
  
  // Dashboard endpoints
  static const String dashboard = '$baseUrl/dashboard';
  static const String dashboardStats = '$baseUrl/dashboard/stats';
  static const String dashboardRecent = '$baseUrl/dashboard/recent';
  static const String dashboardAlerts = '$baseUrl/dashboard/alerts';
  static const String dashboardActivity = '$baseUrl/dashboard/activity';
  
  // Health endpoints
  static const String healthCheck = '$baseUrl/health';
  static const String healthDetailed = '$baseUrl/health/detailed';
  static const String healthReady = '$baseUrl/health/ready';
  static const String healthLive = '$baseUrl/health/live';
  
  // Patient endpoints
  static const String patients = '$baseUrl/patients';
  static const String patientDetails = '$baseUrl/patients/:id';
  static const String patientCreate = '$baseUrl/patients';
  static const String patientUpdate = '$baseUrl/patients/:id';
  static const String patientDelete = '$baseUrl/patients/:id';
  static const String patientSearch = '$baseUrl/patients/search';
  static const String patientMedicalHistory = '$baseUrl/patients/:id/medical-history';
  static const String patientPrescriptions = '$baseUrl/patients/:id/prescriptions';
  static const String patientAppointments = '$baseUrl/patients/:id/appointments';
  static const String patientVitals = '$baseUrl/patients/:id/vitals';
  static const String patientAllergies = '$baseUrl/patients/:id/allergies';
  static const String patientMedications = '$baseUrl/patients/:id/medications';
  
  // Appointment endpoints
  static const String appointments = '$baseUrl/appointments';
  static const String appointmentDetails = '$baseUrl/appointments/:id';
  static const String appointmentCreate = '$baseUrl/appointments';
  static const String appointmentUpdate = '$baseUrl/appointments/:id';
  static const String appointmentCancel = '$baseUrl/appointments/:id/cancel';
  static const String appointmentReschedule = '$baseUrl/appointments/:id/reschedule';
  static const String appointmentConfirm = '$baseUrl/appointments/:id/confirm';
  static const String appointmentComplete = '$baseUrl/appointments/:id/complete';
  static const String appointmentAvailability = '$baseUrl/appointments/availability';
  static const String appointmentTypes = '$baseUrl/appointments/types';
  
  // Prescription endpoints
  static const String prescriptions = '$baseUrl/prescriptions';
  static const String prescriptionDetails = '$baseUrl/prescriptions/:id';
  static const String prescriptionCreate = '$baseUrl/prescriptions';
  static const String prescriptionUpdate = '$baseUrl/prescriptions/:id';
  static const String prescriptionCancel = '$baseUrl/prescriptions/:id/cancel';
  static const String prescriptionRenew = '$baseUrl/prescriptions/:id/renew';
  static const String prescriptionFill = '$baseUrl/prescriptions/:id/fill';
  static const String prescriptionRefill = '$baseUrl/prescriptions/:id/refill';
  static const String prescriptionHistory = '$baseUrl/prescriptions/history';
  static const String prescriptionActive = '$baseUrl/prescriptions/active';
  static const String prescriptionExpired = '$baseUrl/prescriptions/expired';
  
  // Medical Record endpoints
  static const String medicalRecords = '$baseUrl/medical-records';
  static const String medicalRecordDetails = '$baseUrl/medical-records/:id';
  static const String medicalRecordCreate = '$baseUrl/medical-records';
  static const String medicalRecordUpdate = '$baseUrl/medical-records/:id';
  static const String medicalRecordDelete = '$baseUrl/medical-records/:id';
  static const String medicalRecordSearch = '$baseUrl/medical-records/search';
  static const String medicalRecordExport = '$baseUrl/medical-records/export';
  static const String medicalRecordShare = '$baseUrl/medical-records/:id/share';
  
  // Lab Test endpoints
  static const String labTests = '$baseUrl/lab-tests';
  static const String labTestDetails = '$baseUrl/lab-tests/:id';
  static const String labTestCreate = '$baseUrl/lab-tests';
  static const String labTestUpdate = '$baseUrl/lab-tests/:id';
  static const String labTestResults = '$baseUrl/lab-tests/:id/results';
  static const String labTestReport = '$baseUrl/lab-tests/:id/report';
  static const String labTestTypes = '$baseUrl/lab-tests/types';
  static const String labTestHistory = '$baseUrl/lab-tests/history';
  
  // Vital Signs endpoints
  static const String vitalSigns = '$baseUrl/vital-signs';
  static const String vitalSignDetails = '$baseUrl/vital-signs/:id';
  static const String vitalSignCreate = '$baseUrl/vital-signs';
  static const String vitalSignUpdate = '$baseUrl/vital-signs/:id';
  static const String vitalSignHistory = '$baseUrl/vital-signs/history';
  static const String vitalSignTrends = '$baseUrl/vital-signs/trends';
  static const String vitalSignAlerts = '$baseUrl/vital-signs/alerts';
  
  // Medication endpoints
  static const String medications = '$baseUrl/medications';
  static const String medicationDetails = '$baseUrl/medications/:id';
  static const String medicationCreate = '$baseUrl/medications';
  static const String medicationUpdate = '$baseUrl/medications/:id';
  static const String medicationDelete = '$baseUrl/medications/:id';
  static const String medicationSearch = '$baseUrl/medications/search';
  static const String medicationInteractions = '$baseUrl/medications/interactions';
  static const String medicationAlternatives = '$baseUrl/medications/alternatives';
  static const String medicationSideEffects = '$baseUrl/medications/side-effects';
  
  // Allergy endpoints
  static const String allergies = '$baseUrl/allergies';
  static const String allergyDetails = '$baseUrl/allergies/:id';
  static const String allergyCreate = '$baseUrl/allergies';
  static const String allergyUpdate = '$baseUrl/allergies/:id';
  static const String allergyDelete = '$baseUrl/allergies/:id';
  static const String allergySearch = '$baseUrl/allergies/search';
  static const String allergyTypes = '$baseUrl/allergies/types';
  
  // Notification endpoints
  static const String notifications = '$baseUrl/notifications';
  static const String notificationDetails = '$baseUrl/notifications/:id';
  static const String notificationMarkRead = '$baseUrl/notifications/:id/read';
  static const String notificationMarkAllRead = '$baseUrl/notifications/read-all';
  static const String notificationDelete = '$baseUrl/notifications/:id';
  static const String notificationSettings = '$baseUrl/notifications/settings';
  static const String notificationUpdateSettings = '$baseUrl/notifications/settings';
  
  // Analytics endpoints
  static const String analytics = '$baseUrl/analytics';
  static const String analyticsOverview = '$baseUrl/analytics/overview';
  static const String analyticsPatients = '$baseUrl/analytics/patients';
  static const String analyticsAppointments = '$baseUrl/analytics/appointments';
  static const String analyticsPrescriptions = '$baseUrl/analytics/prescriptions';
  static const String analyticsRevenue = '$baseUrl/analytics/revenue';
  static const String analyticsReports = '$baseUrl/analytics/reports';
  static const String analyticsExport = '$baseUrl/analytics/export';
  
  // Settings endpoints
  static const String settings = '$baseUrl/settings';
  static const String settingsGeneral = '$baseUrl/settings/general';
  static const String settingsSecurity = '$baseUrl/settings/security';
  static const String settingsPrivacy = '$baseUrl/settings/privacy';
  static const String settingsNotifications = '$baseUrl/settings/notifications';
  static const String settingsAppearance = '$baseUrl/settings/appearance';
  static const String settingsLanguage = '$baseUrl/settings/language';
  static const String settingsBackup = '$baseUrl/settings/backup';
  static const String settingsRestore = '$baseUrl/settings/restore';
  
  // File endpoints
  static const String files = '$baseUrl/files';
  static const String fileUpload = '$baseUrl/files/upload';
  static const String fileDetails = '$baseUrl/files/:id';
  static const String fileDownload = '$baseUrl/files/:id/download';
  static const String fileDelete = '$baseUrl/files/:id';
  static const String fileShare = '$baseUrl/files/:id/share';
  
  // Search endpoints
  static const String search = '$baseUrl/search';
  static const String searchPatients = '$baseUrl/search/patients';
  static const String searchAppointments = '$baseUrl/search/appointments';
  static const String searchPrescriptions = '$baseUrl/search/prescriptions';
  static const String searchMedicalRecords = '$baseUrl/search/medical-records';
  static const String searchMedications = '$baseUrl/search/medications';
  static const String searchGlobal = '$baseUrl/search/global';
  
  // Report endpoints
  static const String reports = '$baseUrl/reports';
  static const String reportGenerate = '$baseUrl/reports/generate';
  static const String reportDetails = '$baseUrl/reports/:id';
  static const String reportDownload = '$baseUrl/reports/:id/download';
  static const String reportShare = '$baseUrl/reports/:id/share';
  static const String reportTypes = '$baseUrl/reports/types';
  static const String reportTemplates = '$baseUrl/reports/templates';
  
  // Integration endpoints
  static const String integrations = '$baseUrl/integrations';
  static const String integrationConnect = '$baseUrl/integrations/connect';
  static const String integrationDisconnect = '$baseUrl/integrations/:id/disconnect';
  static const String integrationSync = '$baseUrl/integrations/:id/sync';
  static const String integrationStatus = '$baseUrl/integrations/:id/status';
  
  // WebSocket endpoints
  static const String websocket = '$baseUrl/ws';
  static const String websocketChat = '$baseUrl/ws/chat';
  static const String websocketNotifications = '$baseUrl/ws/notifications';
  static const String websocketUpdates = '$baseUrl/ws/updates';
  
  // Version endpoints
  static const String version = '$baseUrl/version';
  static const String versionCheck = '$baseUrl/version/check';
  static const String versionUpdate = '$baseUrl/version/update';
  
  // Help endpoints
  static const String help = '$baseUrl/help';
  static const String helpFAQ = '$baseUrl/help/faq';
  static const String helpSupport = '$baseUrl/help/support';
  static const String helpFeedback = '$baseUrl/help/feedback';
  static const String helpContact = '$baseUrl/help/contact';
  
  // Legal endpoints
  static const String legal = '$baseUrl/legal';
  static const String legalTerms = '$baseUrl/legal/terms';
  static const String legalPrivacy = '$baseUrl/legal/privacy';
  static const String legalCookies = '$baseUrl/legal/cookies';
  static const String legalGDPR = '$baseUrl/legal/gdpr';
  
  // Utility endpoints
  static const String validateEmail = '$baseUrl/utils/validate-email';
  static const String validatePhone = '$baseUrl/utils/validate-phone';
  static const String generateOTP = '$baseUrl/utils/generate-otp';
  static const String verifyOTP = '$baseUrl/utils/verify-otp';
  static const String timezones = '$baseUrl/utils/timezones';
  static const String currencies = '$baseUrl/utils/currencies';
  static const String languages = '$baseUrl/utils/languages';
  static const String countries = '$baseUrl/utils/countries';
}
