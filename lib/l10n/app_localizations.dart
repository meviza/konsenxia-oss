import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to get the current localizations
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static method to get supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('tr', 'TR'), // Turkish
    Locale('de', 'DE'), // German
    Locale('fr', 'FR'), // French
    Locale('es', 'ES'), // Spanish
    Locale('ar', 'SA'), // Arabic
    Locale('ru', 'RU'), // Russian
    Locale('zh', 'CN'), // Chinese
  ];

  // Localizations delegates
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  // App General
  String get appName => _localizedValues[locale.languageCode]!['appName'] ?? 'KONSENXIA';
  String get welcome => _localizedValues[locale.languageCode]!['welcome'] ?? 'Welcome';
  String get welcomeBack => _localizedValues[locale.languageCode]!['welcomeBack'] ?? 'Welcome back';
  String get getStarted => _localizedValues[locale.languageCode]!['getStarted'] ?? 'Get Started';
  String get continueText => _localizedValues[locale.languageCode]!['continue'] ?? 'Continue';
  String get cancel => _localizedValues[locale.languageCode]!['cancel'] ?? 'Cancel';
  String get confirm => _localizedValues[locale.languageCode]!['confirm'] ?? 'Confirm';
  String get save => _localizedValues[locale.languageCode]!['save'] ?? 'Save';
  String get delete => _localizedValues[locale.languageCode]!['delete'] ?? 'Delete';
  String get edit => _localizedValues[locale.languageCode]!['edit'] ?? 'Edit';
  String get add => _localizedValues[locale.languageCode]!['add'] ?? 'Add';
  String get search => _localizedValues[locale.languageCode]!['search'] ?? 'Search';
  String get filter => _localizedValues[locale.languageCode]!['filter'] ?? 'Filter';
  String get sort => _localizedValues[locale.languageCode]!['sort'] ?? 'Sort';
  String get refresh => _localizedValues[locale.languageCode]!['refresh'] ?? 'Refresh';
  String get loading => _localizedValues[locale.languageCode]!['loading'] ?? 'Loading';
  String get error => _localizedValues[locale.languageCode]!['error'] ?? 'Error';
  String get success => _localizedValues[locale.languageCode]!['success'] ?? 'Success';
  String get warning => _localizedValues[locale.languageCode]!['warning'] ?? 'Warning';
  String get info => _localizedValues[locale.languageCode]!['info'] ?? 'Info';

  // Authentication
  String get login => _localizedValues[locale.languageCode]!['login'] ?? 'Login';
  String get register => _localizedValues[locale.languageCode]!['register'] ?? 'Register';
  String get logout => _localizedValues[locale.languageCode]!['logout'] ?? 'Logout';
  String get email => _localizedValues[locale.languageCode]!['email'] ?? 'Email';
  String get password => _localizedValues[locale.languageCode]!['password'] ?? 'Password';
  String get confirmPassword => _localizedValues[locale.languageCode]!['confirmPassword'] ?? 'Confirm Password';
  String get forgotPassword => _localizedValues[locale.languageCode]!['forgotPassword'] ?? 'Forgot Password?';
  String get rememberMe => _localizedValues[locale.languageCode]!['rememberMe'] ?? 'Remember Me';
  String get loginSuccess => _localizedValues[locale.languageCode]!['loginSuccess'] ?? 'Login successful';
  String get loginError => _localizedValues[locale.languageCode]!['loginError'] ?? 'Login failed';
  String get registerSuccess => _localizedValues[locale.languageCode]!['registerSuccess'] ?? 'Registration successful';
  String get registerError => _localizedValues[locale.languageCode]!['registerError'] ?? 'Registration failed';
  String get invalidEmail => _localizedValues[locale.languageCode]!['invalidEmail'] ?? 'Invalid email address';
  String get invalidPassword => _localizedValues[locale.languageCode]!['invalidPassword'] ?? 'Password must be at least 8 characters';
  String get passwordMismatch => _localizedValues[locale.languageCode]!['passwordMismatch'] ?? 'Passwords do not match';

  // Dashboard
  String get dashboard => _localizedValues[locale.languageCode]!['dashboard'] ?? 'Dashboard';
  String get overview => _localizedValues[locale.languageCode]!['overview'] ?? 'Overview';
  String get quickActions => _localizedValues[locale.languageCode]!['quickActions'] ?? 'Quick Actions';
  String get recentActivities => _localizedValues[locale.languageCode]!['recentActivities'] ?? 'Recent Activities';
  String get statistics => _localizedValues[locale.languageCode]!['statistics'] ?? 'Statistics';
  String get consultations => _localizedValues[locale.languageCode]!['consultations'] ?? 'Consultations';
  String get patients => _localizedValues[locale.languageCode]!['patients'] ?? 'Patients';
  String get appointments => _localizedValues[locale.languageCode]!['appointments'] ?? 'Appointments';
  String get prescriptions => _localizedValues[locale.languageCode]!['prescriptions'] ?? 'Prescriptions';
  String get reports => _localizedValues[locale.languageCode]!['reports'] ?? 'Reports';
  String get analytics => _localizedValues[locale.languageCode]!['analytics'] ?? 'Analytics';

  // AI Chat
  String get aiChat => _localizedValues[locale.languageCode]!['aiChat'] ?? 'AI Chat';
  String get aiAssistant => _localizedValues[locale.languageCode]!['aiAssistant'] ?? 'AI Assistant';
  String get sendMessage => _localizedValues[locale.languageCode]!['sendMessage'] ?? 'Send Message';
  String get typeMessage => _localizedValues[locale.languageCode]!['typeMessage'] ?? 'Type your message...';
  String get aiThinking => _localizedValues[locale.languageCode]!['aiThinking'] ?? 'AI is thinking...';
  String get aiResponse => _localizedValues[locale.languageCode]!['aiResponse'] ?? 'AI Response';
  String get consultAI => _localizedValues[locale.languageCode]!['consultAI'] ?? 'Consult AI';
  String get medicalConsultation => _localizedValues[locale.languageCode]!['medicalConsultation'] ?? 'Medical Consultation';
  String get diagnosisAssistance => _localizedValues[locale.languageCode]!['diagnosisAssistance'] ?? 'Diagnosis Assistance';
  String get treatmentRecommendation => _localizedValues[locale.languageCode]!['treatmentRecommendation'] ?? 'Treatment Recommendation';

  // Collaboration
  String get collaboration => _localizedValues[locale.languageCode]!['collaboration'] ?? 'Collaboration';
  String get collaborate => _localizedValues[locale.languageCode]!['collaborate'] ?? 'Collaborate';
  String get secondOpinion => _localizedValues[locale.languageCode]!['secondOpinion'] ?? 'Second Opinion';
  String get specialistConsultation => _localizedValues[locale.languageCode]!['specialistConsultation'] ?? 'Specialist Consultation';
  String get caseReview => _localizedValues[locale.languageCode]!['caseReview'] ?? 'Case Review';
  String get doctorNetwork => _localizedValues[locale.languageCode]!['doctorNetwork'] ?? 'Doctor Network';
  String get collaborationRequests => _localizedValues[locale.languageCode]!['collaborationRequests'] ?? 'Collaboration Requests';
  String get inviteDoctor => _localizedValues[locale.languageCode]!['inviteDoctor'] ?? 'Invite Doctor';
  String get shareCase => _localizedValues[locale.languageCode]!['shareCase'] ?? 'Share Case';

  // Profile
  String get profile => _localizedValues[locale.languageCode]!['profile'] ?? 'Profile';
  String get settings => _localizedValues[locale.languageCode]!['settings'] ?? 'Settings';
  String get personalInfo => _localizedValues[locale.languageCode]!['personalInfo'] ?? 'Personal Information';
  String get medicalInfo => _localizedValues[locale.languageCode]!['medicalInfo'] ?? 'Medical Information';
  String get preferences => _localizedValues[locale.languageCode]!['preferences'] ?? 'Preferences';
  String get notifications => _localizedValues[locale.languageCode]!['notifications'] ?? 'Notifications';
  String get privacy => _localizedValues[locale.languageCode]!['privacy'] ?? 'Privacy';
  String get security => _localizedValues[locale.languageCode]!['security'] ?? 'Security';
  String get language => _localizedValues[locale.languageCode]!['language'] ?? 'Language';
  String get theme => _localizedValues[locale.languageCode]!['theme'] ?? 'Theme';
  String get lightTheme => _localizedValues[locale.languageCode]!['lightTheme'] ?? 'Light';
  String get darkTheme => _localizedValues[locale.languageCode]!['darkTheme'] ?? 'Dark';
  String get systemTheme => _localizedValues[locale.languageCode]!['systemTheme'] ?? 'System';

  // Medical Terms
  String get diagnosis => _localizedValues[locale.languageCode]!['diagnosis'] ?? 'Diagnosis';
  String get symptoms => _localizedValues[locale.languageCode]!['symptoms'] ?? 'Symptoms';
  String get treatment => _localizedValues[locale.languageCode]!['treatment'] ?? 'Treatment';
  String get medication => _localizedValues[locale.languageCode]!['medication'] ?? 'Medication';
  String get medicalHistory => _localizedValues[locale.languageCode]!['medicalHistory'] ?? 'Medical History';
  String get allergies => _localizedValues[locale.languageCode]!['allergies'] ?? 'Allergies';
  String get vitalSigns => _localizedValues[locale.languageCode]!['vitalSigns'] ?? 'Vital Signs';
  String get labResults => _localizedValues[locale.languageCode]!['labResults'] ?? 'Lab Results';
  String get imaging => _localizedValues[locale.languageCode]!['imaging'] ?? 'Imaging';
  String get notes => _localizedValues[locale.languageCode]!['notes'] ?? 'Notes';

  // Legal
  String get termsOfService => _localizedValues[locale.languageCode]!['termsOfService'] ?? 'Terms of Service';
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacyPolicy'] ?? 'Privacy Policy';
  String get kvkkPolicy => _localizedValues[locale.languageCode]!['kvkkPolicy'] ?? 'KVKK Policy';
  String get gdprPolicy => _localizedValues[locale.languageCode]!['gdprPolicy'] ?? 'GDPR Policy';
  String get legalDisclaimer => _localizedValues[locale.languageCode]!['legalDisclaimer'] ?? 'Legal Disclaimer';
  String get dataProtection => _localizedValues[locale.languageCode]!['dataProtection'] ?? 'Data Protection';
  String get consent => _localizedValues[locale.languageCode]!['consent'] ?? 'Consent';
  String get agree => _localizedValues[locale.languageCode]!['agree'] ?? 'Agree';
  String get disagree => _localizedValues[locale.languageCode]!['disagree'] ?? 'Disagree';

  // Support
  String get support => _localizedValues[locale.languageCode]!['support'] ?? 'Support';
  String get help => _localizedValues[locale.languageCode]!['help'] ?? 'Help';
  String get contactUs => _localizedValues[locale.languageCode]!['contactUs'] ?? 'Contact Us';
  String get about => _localizedValues[locale.languageCode]!['about'] ?? 'About';
  String get feedback => _localizedValues[locale.languageCode]!['feedback'] ?? 'Feedback';
  String get reportIssue => _localizedValues[locale.languageCode]!['reportIssue'] ?? 'Report Issue';
  String get faq => _localizedValues[locale.languageCode]!['faq'] ?? 'FAQ';

  // Localization values
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'KONSENXIA',
      'welcome': 'Welcome',
      'welcomeBack': 'Welcome back',
      'getStarted': 'Get Started',
      'continue': 'Continue',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'refresh': 'Refresh',
      'loading': 'Loading',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Info',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'rememberMe': 'Remember Me',
      'loginSuccess': 'Login successful',
      'loginError': 'Login failed',
      'registerSuccess': 'Registration successful',
      'registerError': 'Registration failed',
      'invalidEmail': 'Invalid email address',
      'invalidPassword': 'Password must be at least 8 characters',
      'passwordMismatch': 'Passwords do not match',
      'dashboard': 'Dashboard',
      'overview': 'Overview',
      'quickActions': 'Quick Actions',
      'recentActivities': 'Recent Activities',
      'statistics': 'Statistics',
      'consultations': 'Consultations',
      'patients': 'Patients',
      'appointments': 'Appointments',
      'prescriptions': 'Prescriptions',
      'reports': 'Reports',
      'analytics': 'Analytics',
      'aiChat': 'AI Chat',
      'aiAssistant': 'AI Assistant',
      'sendMessage': 'Send Message',
      'typeMessage': 'Type your message...',
      'aiThinking': 'AI is thinking...',
      'aiResponse': 'AI Response',
      'consultAI': 'Consult AI',
      'medicalConsultation': 'Medical Consultation',
      'diagnosisAssistance': 'Diagnosis Assistance',
      'treatmentRecommendation': 'Treatment Recommendation',
      'collaboration': 'Collaboration',
      'collaborate': 'Collaborate',
      'secondOpinion': 'Second Opinion',
      'specialistConsultation': 'Specialist Consultation',
      'caseReview': 'Case Review',
      'doctorNetwork': 'Doctor Network',
      'collaborationRequests': 'Collaboration Requests',
      'inviteDoctor': 'Invite Doctor',
      'shareCase': 'Share Case',
      'profile': 'Profile',
      'settings': 'Settings',
      'personalInfo': 'Personal Information',
      'medicalInfo': 'Medical Information',
      'preferences': 'Preferences',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'security': 'Security',
      'language': 'Language',
      'theme': 'Theme',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemTheme': 'System',
      'diagnosis': 'Diagnosis',
      'symptoms': 'Symptoms',
      'treatment': 'Treatment',
      'medication': 'Medication',
      'medicalHistory': 'Medical History',
      'allergies': 'Allergies',
      'vitalSigns': 'Vital Signs',
      'labResults': 'Lab Results',
      'imaging': 'Imaging',
      'notes': 'Notes',
      'termsOfService': 'Terms of Service',
      'privacyPolicy': 'Privacy Policy',
      'kvkkPolicy': 'KVKK Policy',
      'gdprPolicy': 'GDPR Policy',
      'legalDisclaimer': 'Legal Disclaimer',
      'dataProtection': 'Data Protection',
      'consent': 'Consent',
      'agree': 'Agree',
      'disagree': 'Disagree',
      'support': 'Support',
      'help': 'Help',
      'contactUs': 'Contact Us',
      'about': 'About',
      'feedback': 'Feedback',
      'reportIssue': 'Report Issue',
      'faq': 'FAQ',
    },
    'tr': {
      'appName': 'KONSENXIA',
      'welcome': 'Hoş Geldiniz',
      'welcomeBack': 'Hoş geldiniz',
      'getStarted': 'Başlayın',
      'continue': 'Devam Et',
      'cancel': 'İptal',
      'confirm': 'Onayla',
      'save': 'Kaydet',
      'delete': 'Sil',
      'edit': 'Düzenle',
      'add': 'Ekle',
      'search': 'Ara',
      'filter': 'Filtrele',
      'sort': 'Sırala',
      'refresh': 'Yenile',
      'loading': 'Yükleniyor',
      'error': 'Hata',
      'success': 'Başarılı',
      'warning': 'Uyarı',
      'info': 'Bilgi',
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'logout': 'Çıkış Yap',
      'email': 'E-posta',
      'password': 'Şifre',
      'confirmPassword': 'Şifreyi Onayla',
      'forgotPassword': 'Şifremi Unuttum?',
      'rememberMe': 'Beni Hatırla',
      'loginSuccess': 'Giriş başarılı',
      'loginError': 'Giriş başarısız',
      'registerSuccess': 'Kayıt başarılı',
      'registerError': 'Kayıt başarısız',
      'invalidEmail': 'Geçersiz e-posta adresi',
      'invalidPassword': 'Şifre en az 8 karakter olmalı',
      'passwordMismatch': 'Şifreler eşleşmiyor',
      'dashboard': 'Panel',
      'overview': 'Genel Bakış',
      'quickActions': 'Hızlı İşlemler',
      'recentActivities': 'Son Aktiviteler',
      'statistics': 'İstatistikler',
      'consultations': 'Konsültasyonlar',
      'patients': 'Hastalar',
      'appointments': 'Randevular',
      'prescriptions': 'Reçeteler',
      'reports': 'Raporlar',
      'analytics': 'Analitik',
      'aiChat': 'AI Sohbet',
      'aiAssistant': 'AI Asistan',
      'sendMessage': 'Mesaj Gönder',
      'typeMessage': 'Mesajınızı yazın...',
      'aiThinking': 'AI düşünüyor...',
      'aiResponse': 'AI Yanıtı',
      'consultAI': 'AI Danış',
      'medicalConsultation': 'Tıbbi Konsültasyon',
      'diagnosisAssistance': 'Teşhis Yardımı',
      'treatmentRecommendation': 'Tedavi Önerisi',
      'collaboration': 'İş Birliği',
      'collaborate': 'İş Birliği Yap',
      'secondOpinion': 'İkinci Görüş',
      'specialistConsultation': 'Uzman Konsültasyonu',
      'caseReview': 'Vaka İncelemesi',
      'doctorNetwork': 'Doktor Ağı',
      'collaborationRequests': 'İş Birliği İstekleri',
      'inviteDoctor': 'Doktor Davet Et',
      'shareCase': 'Vaka Paylaş',
      'profile': 'Profil',
      'settings': 'Ayarlar',
      'personalInfo': 'Kişisel Bilgiler',
      'medicalInfo': 'Tıbbi Bilgiler',
      'preferences': 'Tercihler',
      'notifications': 'Bildirimler',
      'privacy': 'Gizlilik',
      'security': 'Güvenlik',
      'language': 'Dil',
      'theme': 'Tema',
      'lightTheme': 'Açık',
      'darkTheme': 'Koyu',
      'systemTheme': 'Sistem',
      'diagnosis': 'Teşhis',
      'symptoms': 'Belirtiler',
      'treatment': 'Tedavi',
      'medication': 'İlaç',
      'medicalHistory': 'Tıbbi Geçmiş',
      'allergies': 'Alerjiler',
      'vitalSigns': 'Yaşam Belirtileri',
      'labResults': 'Lab Sonuçları',
      'imaging': 'Görüntüleme',
      'notes': 'Notlar',
      'termsOfService': 'Hizmet Şartları',
      'privacyPolicy': 'Gizlilik Politikası',
      'kvkkPolicy': 'KVKK Politikası',
      'gdprPolicy': 'GDPR Politikası',
      'legalDisclaimer': 'Yasal Feragat',
      'dataProtection': 'Veri Koruma',
      'consent': 'Onay',
      'agree': 'Kabul Et',
      'disagree': 'Kabul Etme',
      'support': 'Destek',
      'help': 'Yardım',
      'contactUs': 'Bize Ulaşın',
      'about': 'Hakkında',
      'feedback': 'Geri Bildirim',
      'reportIssue': 'Sorun Bildir',
      'faq': 'SSS',
    },
    'de': {
      'appName': 'KONSENXIA',
      'welcome': 'Willkommen',
      'welcomeBack': 'Willkommen zurück',
      'getStarted': 'Loslegen',
      'continue': 'Weiter',
      'cancel': 'Abbrechen',
      'confirm': 'Bestätigen',
      'save': 'Speichern',
      'delete': 'Löschen',
      'edit': 'Bearbeiten',
      'add': 'Hinzufügen',
      'search': 'Suchen',
      'filter': 'Filtern',
      'sort': 'Sortieren',
      'refresh': 'Aktualisieren',
      'loading': 'Laden',
      'error': 'Fehler',
      'success': 'Erfolg',
      'warning': 'Warnung',
      'info': 'Info',
      'login': 'Anmelden',
      'register': 'Registrieren',
      'logout': 'Abmelden',
      'email': 'E-Mail',
      'password': 'Passwort',
      'confirmPassword': 'Passwort bestätigen',
      'forgotPassword': 'Passwort vergessen?',
      'rememberMe': 'Angemeldet bleiben',
      'loginSuccess': 'Anmeldung erfolgreich',
      'loginError': 'Anmeldung fehlgeschlagen',
      'registerSuccess': 'Registrierung erfolgreich',
      'registerError': 'Registrierung fehlgeschlagen',
      'invalidEmail': 'Ungültige E-Mail-Adresse',
      'invalidPassword': 'Passwort muss mindestens 8 Zeichen lang sein',
      'passwordMismatch': 'Passwörter stimmen nicht überein',
      'dashboard': 'Dashboard',
      'overview': 'Übersicht',
      'quickActions': 'Schnellaktionen',
      'recentActivities': 'Letzte Aktivitäten',
      'statistics': 'Statistiken',
      'consultations': 'Konsultationen',
      'patients': 'Patienten',
      'appointments': 'Termine',
      'prescriptions': 'Rezepte',
      'reports': 'Berichte',
      'analytics': 'Analytik',
      'aiChat': 'KI-Chat',
      'aiAssistant': 'KI-Assistent',
      'sendMessage': 'Nachricht senden',
      'typeMessage': 'Nachricht eingeben...',
      'aiThinking': 'KI denkt nach...',
      'aiResponse': 'KI-Antwort',
      'consultAI': 'KI konsultieren',
      'medicalConsultation': 'Ärztliche Konsultation',
      'diagnosisAssistance': 'Diagnosehilfe',
      'treatmentRecommendation': 'Behandlungsempfehlung',
      'collaboration': 'Zusammenarbeit',
      'collaborate': 'Zusammenarbeiten',
      'secondOpinion': 'Zweite Meinung',
      'specialistConsultation': 'Facharztkonsultation',
      'caseReview': 'Fallprüfung',
      'doctorNetwork': 'Arzt-Netzwerk',
      'collaborationRequests': 'Zusammenarbeitsanfragen',
      'inviteDoctor': 'Arzt einladen',
      'shareCase': 'Fall teilen',
      'profile': 'Profil',
      'settings': 'Einstellungen',
      'personalInfo': 'Persönliche Informationen',
      'medicalInfo': 'Medizinische Informationen',
      'preferences': 'Präferenzen',
      'notifications': 'Benachrichtigungen',
      'privacy': 'Datenschutz',
      'security': 'Sicherheit',
      'language': 'Sprache',
      'theme': 'Design',
      'lightTheme': 'Hell',
      'darkTheme': 'Dunkel',
      'systemTheme': 'System',
      'diagnosis': 'Diagnose',
      'symptoms': 'Symptome',
      'treatment': 'Behandlung',
      'medication': 'Medikation',
      'medicalHistory': 'Krankengeschichte',
      'allergies': 'Allergien',
      'vitalSigns': 'Vitalzeichen',
      'labResults': 'Laboregebnisse',
      'imaging': 'Bildgebung',
      'notes': 'Notizen',
      'termsOfService': 'Nutzungsbedingungen',
      'privacyPolicy': 'Datenschutzerklärung',
      'kvkkPolicy': 'KVKK-Richtlinie',
      'gdprPolicy': 'DSGVO-Richtlinie',
      'legalDisclaimer': 'Rechtlicher Haftungsausschluss',
      'dataProtection': 'Datenschutz',
      'consent': 'Zustimmung',
      'agree': 'Zustimmen',
      'disagree': 'Ablehnen',
      'support': 'Support',
      'help': 'Hilfe',
      'contactUs': 'Kontakt',
      'about': 'Über uns',
      'feedback': 'Feedback',
      'reportIssue': 'Problem melden',
      'faq': 'FAQ',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
