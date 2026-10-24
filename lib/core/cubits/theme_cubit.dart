import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema durumunu yöneten Cubit.
/// SharedPreferences ile kalıcı tercih.
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'app_theme_mode';

  ThemeCubit(this._prefs) : super(_loadFromPrefs(_prefs));

  static ThemeMode _loadFromPrefs(SharedPreferences prefs) {
    final value = prefs.getString(_key);
    if (value == 'light') return ThemeMode.light;
    return ThemeMode.dark; // varsayilan
  }

  void setTheme(ThemeMode mode) {
    _prefs.setString(_key, mode == ThemeMode.light ? 'light' : 'dark');
    emit(mode);
  }

  void toggleTheme() {
    final next =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }

  bool get isDark => state == ThemeMode.dark;
}
