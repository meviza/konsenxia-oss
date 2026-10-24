import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import '../design_system/tokens/app_theme.dart';
import 'cubits/theme_cubit.dart';
import 'cubits/locale_cubit.dart';
import 'router.dart';

/// KONSENXIA root widget
class KONSENXIAApp extends StatelessWidget {
  const KONSENXIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = GetIt.instance<SharedPreferences>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.instance<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<DashboardBloc>(),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<AIChatBloc>(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(prefs),
        ),
        BlocProvider(
          create: (_) => LocaleCubit(prefs),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'KONSENXIA',
                debugShowCheckedModeBanner: false,

                // Clinical Noir tema — cubit ile yonetilen
                theme: KxTheme.light,
                darkTheme: KxTheme.dark,
                themeMode: themeMode,

                // Localization
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: AppRouter.router,

                // Cubit ile yonetilen locale
                locale: locale,
                supportedLocales: const [
                  Locale('tr', 'TR'),
                  Locale('en', 'US'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
