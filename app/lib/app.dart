import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/env.dart';
import 'core/supabase.dart';
import 'core/theme.dart';
import 'features/auth/auth_page.dart';
import 'features/shell/home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return GoRouter(
    refreshListenable: auth,
    redirect: (context, state) {
      // Supabase ayarlı değilse girişi atla (arayüz geliştirme için).
      if (!Env.isConfigured) return null;
      final atLogin = state.matchedLocation == '/giris';
      if (!auth.isLoggedIn) return atLogin ? null : '/giris';
      if (atLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeShell()),
      GoRoute(path: '/giris', builder: (context, state) => const AuthPage()),
    ],
  );
});

class YesChefApp extends ConsumerWidget {
  const YesChefApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'yesChef',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}
