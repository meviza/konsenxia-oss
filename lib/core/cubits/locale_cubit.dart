import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dil tercihini yoneten Cubit.
/// SharedPreferences ile kalici tercih.
class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences _prefs;
  static const _key = 'app_locale';

  LocaleCubit(this._prefs) : super(_loadFromPrefs(_prefs));

  static Locale _loadFromPrefs(SharedPreferences prefs) {
    final value = prefs.getString(_key);
    if (value == 'en') return const Locale('en', 'US');
    return const Locale('tr', 'TR'); // varsayilan
  }

  void setLocale(Locale locale) {
    _prefs.setString(_key, locale.languageCode);
    emit(locale);
  }

  bool get isTurkish => state.languageCode == 'tr';

  String get displayName => isTurkish ? 'Turkce' : 'English';
}
