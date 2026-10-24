import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'core/app.dart';
import 'core/dependency_injection.dart';
import 'core/firebase/firebase_options.dart';
import 'core/services/ai_case_generator_service.dart';
import 'core/utils/case_seed_data.dart';
import 'core/utils/firestore_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlatma (firebase_core 3.x — tüm platformlar)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Türkçe tarih formatlama (intl)
  await initializeDateFormatting('tr');

  // Firestore offline persistence etkinleştir
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Bağımlılıkları kayıt et
  await initDependencies();

  // Debug modda Firestore örnek vakalarını seed et (timeout ile, await yok)
  if (kDebugMode) {
    CaseSeedData.seed().timeout(
      const Duration(seconds: 5),
      onTimeout: () {}, // Offline ise sessizce atla
    );
    FirestoreSeeder.seedAll().timeout(
      const Duration(seconds: 10),
      onTimeout: () {}, // Offline ise sessizce atla
    );
  }

  // AI Profesör vaka üretimi — minimum 15 aktif vaka olmasını sağla
  // Arka planda çalışır, başarısız olursa sessizce atlar
  _ensureAICases();

  // Sistem UI — Clinical Noir: tam şeffaf status/nav bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Portrait + landscape desteklenir (tablet için landscape gerekli)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const KONSENXIAApp());
}

/// AI Profesör tarafından minimum vaka sayısını kontrol et ve gerekirse üret
void _ensureAICases() {
  // DI kurulduktan sonra arka planda çalıştır
  Future.delayed(const Duration(seconds: 3), () async {
    try {
      final generator = GetIt.instance<AICaseGeneratorService>();
      await generator.ensureMinimumCases(minimum: 15).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('[MAIN] AI vaka üretimi zaman aşımı — atlanıyor');
        },
      );
    } catch (e) {
      debugPrint('[MAIN] AI vaka üretimi hatası (kritik değil): $e');
    }
  });
}
