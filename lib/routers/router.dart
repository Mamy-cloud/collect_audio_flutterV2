// router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/login_screen.dart';
import '../screens/list_temoin_screen.dart';
import '../screens/questionnaire_screen.dart';
import '../screens/save_local_detail_screen.dart';
import '../screens/transfert_data_to_cloud_screen.dart';
import '../screens/setting_screen.dart';

import '../notifications_screens/notification_addtemoin_screen.dart';
import '../notifications_screens/notification_save_collect_info_temoin_screen.dart';
import '../notifications_screens/notification_update_delete.dart';

import '../widgets/global/app_navbar.dart';
import '../database/save_questionnaire/list_collect_data.dart';
import '../services/session_service.dart';
import '../database/create_table/create_table_temoin.dart';

final router = GoRouter(
  initialLocation: '/splash',

  redirect: (context, state) {
    final location = state.matchedLocation;

    // Splash toujours autorisé
    if (location == '/splash') return null;

    // Session active en mémoire → accès libre
    if (SessionService.isLoggedIn) return null;

    // Pas de session → forcer login
    if (location != '/login') return '/login';

    return null;
  },

  routes: [

    // ── Splash ────────────────────────────────────────────────────────────────
    GoRoute(
      path:    '/splash',
      builder: (_, __) => const _SplashScreen(),
    ),

    // ── Login ─────────────────────────────────────────────────────────────────
    GoRoute(
      path:    '/login',
      builder: (_, __) => const LoginScreen(),
    ),

    // ── Pages hors navbar ─────────────────────────────────────────────────────
    GoRoute(
      path: '/save_local_detail',
      builder: (context, state) =>
          SaveLocalDetailScreen(temoin: state.extra as Map<String, dynamic>),
    ),
    GoRoute(
      path: '/list_collect_data',
      builder: (context, state) =>
          ListCollectData(temoin: state.extra as Map<String, dynamic>),
    ),
    GoRoute(
      path: '/notification_update_delete',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return NotificationUpdateDelete(
          success:      extra['success'] as bool,
          errorMessage: extra['message'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/notification_save_collect',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return NotificationSaveCollectInfoTemoinScreen(
          success:      extra['success'] as bool,
          errorMessage: extra['message'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/notification_add_temoin',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return NotificationAddTemoinScreen(
          success:      extra['success'] as bool,
          errorMessage: extra['message'] as String?,
        );
      },
    ),

    // ── Shell Route (navbar) ──────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => AppNavbar(child: child),
      routes: [
        GoRoute(
          path:    '/list_temoin',
          builder: (_, __) => const ListTemoinScreen(),
        ),
        GoRoute(
          path:    '/questionnaire',
          builder: (_, __) => const QuestionnaireScreen(),
        ),
        GoRoute(
          path:    '/transfert',
          builder: (_, __) => const TransfertDataToCloudScreen(),
        ),
        GoRoute(
          path:    '/settings',
          builder: (_, __) => const SettingScreen(),
        ),
      ],
    ),
  ],
);

// ── Splash Screen ──────────────────────────────────────────────────────────────

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Init SQLite
    await CreateTableTemoin.init();

    // 2. Restaure la session depuis SharedPreferences
    //    (déjà appelé dans main.dart — idempotent, rapide)
    final restored = await SessionService.restoreSession();

    if (!mounted) return;

    // 3. Redirection
    if (restored && SessionService.isLoggedIn) {
      context.go('/list_temoin');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
