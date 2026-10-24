import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// KONSENXIA — Sesli Giriş Servisi
///
/// Doktorların sözlü vaka anlatımını metne çevirir.
/// - Türkçe (tr_TR) ve İngilizce (en_US) dil desteği
/// - Stream tabanlı gerçek zamanlı metin güncellemesi
/// - İzin yönetimi ve hata handling
class VoiceInputService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;
  String _currentLocale = 'tr_TR';

  /// Tanınan metnin stream'i (gerçek zamanlı güncelleme)
  final StreamController<String> _textController =
      StreamController<String>.broadcast();

  /// Hata stream'i
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  /// Dinleme durumu stream'i
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();

  /// Son tanınan tam metin
  String _lastRecognizedText = '';

  // ── Getters ──────────────────────────────────────────────────────

  Stream<String> get textStream => _textController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;
  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;
  String get lastRecognizedText => _lastRecognizedText;

  // ── Permission ──────────────────────────────────────────────────

  /// Mikrofon iznini kontrol et ve gerekirse iste.
  /// Dönen değerler:
  ///   - `granted` → izin verildi, devam et
  ///   - `denied` → kullanıcı reddetti ama tekrar sorulabilir
  ///   - `permanentlyDenied` → ayarlardan açılmalı
  Future<PermissionStatus> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return status;

    // İlk kez veya daha önce reddedildi ama kalıcı değil
    final result = await Permission.microphone.request();
    return result;
  }

  // ── Initialization ───────────────────────────────────────────────

  /// Ses tanıma motorunu başlat
  /// Başarılı ise true, başarısız veya izin yoksa false döner
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: kDebugMode,
      );

      if (!_isInitialized) {
        _errorController.add(
          'Ses tanıma kullanılamıyor. Mikrofon izni verilmemiş olabilir.',
        );
      }

      return _isInitialized;
    } catch (e) {
      _errorController.add('Ses tanıma başlatılamadı: $e');
      return false;
    }
  }

  // ── Public API ───────────────────────────────────────────────────

  /// Dinlemeye başla
  /// [locale] — Dil kodu: 'tr_TR' veya 'en_US'
  Future<void> startListening({String? locale}) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    if (_isListening) return;

    _currentLocale = locale ?? _currentLocale;
    _lastRecognizedText = '';

    try {
      await _speech.listen(
        onResult: _onResult,
        localeId: _currentLocale,
        listenMode: stt.ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 10),
      );

      _isListening = true;
      _listeningController.add(true);
    } catch (e) {
      _errorController.add('Dinleme başlatılamadı: $e');
    }
  }

  /// Dinlemeyi durdur
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
    } catch (_) {
      // ignore stop errors
    }

    _isListening = false;
    _listeningController.add(false);
  }

  /// Dinlemeyi iptal et (metni silmez ama stream günceller)
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speech.cancel();
    } catch (_) {
      // ignore cancel errors
    }

    _isListening = false;
    _listeningController.add(false);
  }

  /// Aktif dili değiştir
  void setLocale(String localeId) {
    _currentLocale = localeId;
  }

  /// Kullanılabilir dilleri getir
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();
    return _speech.locales();
  }

  /// Kaynakları serbest bırak
  void dispose() {
    _speech.cancel();
    _textController.close();
    _errorController.close();
    _listeningController.close();
  }

  // ── Private handlers ─────────────────────────────────────────────

  void _onResult(SpeechRecognitionResult result) {
    _lastRecognizedText = result.recognizedWords;
    _textController.add(_lastRecognizedText);

    // Konuşma tamamlandıysa durumu güncelle
    if (result.finalResult) {
      _isListening = false;
      _listeningController.add(false);
    }
  }

  void _onError(SpeechRecognitionError error) {
    final message = switch (error.errorMsg) {
      'error_no_match'         => 'Ses algılanamadı. Lütfen tekrar deneyin.',
      'error_speech_timeout'   => 'Konuşma zaman aşımına uğradı.',
      'error_audio'            => 'Mikrofon hatası. Mikrofon izinlerini kontrol edin.',
      'error_permission'       => 'Mikrofon izni reddedildi.',
      'error_network'          => 'Ağ bağlantısı hatası.',
      'error_not_recognized'   => 'Ses tanınamadı. Lütfen daha net konuşun.',
      _                        => 'Ses tanıma hatası: ${error.errorMsg}',
    };

    _errorController.add(message);

    if (!error.permanent) return;

    _isListening = false;
    _listeningController.add(false);
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      _listeningController.add(false);
    }
  }
}
