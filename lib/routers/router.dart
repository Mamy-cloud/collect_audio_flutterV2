/* // router.dart
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
import 'package:flutter/material.dart';

final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    // Laisse passer le splash sans vérification
    if (state.matchedLocation == '/splash') return null;

    // Si session déjà en mémoire → laisse passer
    if (SessionService.isLoggedIn) return null;

    // Tente de restaurer depuis SQLite
    final restored = await SessionService.restoreSession();

    if (restored) {
      // Session restaurée → redirige vers list_temoin si on allait vers login
      if (state.matchedLocation == '/login') {
        return '/list_temoin';
      }
      return null;
    }

    // Pas de session → force le login
    if (state.matchedLocation != '/login') {
      return '/login';
    }
    return null;
  },
  routes: [

    // ── Splash — initialise SQLite et vérifie la session ──────────────────────
    GoRoute(
      path:    '/splash',
      builder: (_, __) => const _SplashScreen(),
    ),

    // ── Hors ShellRoute — pas de navbar ───────────────────────────────────────
    GoRoute(
      path:    '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/save_local_detail',
      builder: (context, state) {
        final temoin = state.extra as Map<String, dynamic>;
        return SaveLocalDetailScreen(temoin: temoin);
      },
    ),
    GoRoute(
      path: '/list_collect_data',
      builder: (context, state) {
        final temoin = state.extra as Map<String, dynamic>;
        return ListCollectData(temoin: temoin);
      },
    ),
    GoRoute(
      path: '/notification_update_delete',
      builder: (context, state) {
        final extra   = state.extra as Map<String, dynamic>;
        final success = extra['success'] as bool;
        final message = extra['message'] as String?;
        return NotificationUpdateDelete(
          success:      success,
          errorMessage: message,
        );
      },
    ),
    GoRoute(
      path: '/notification_save_collect',
      builder: (context, state) {
        final extra   = state.extra as Map<String, dynamic>;
        final success = extra['success'] as bool;
        final message = extra['message'] as String?;
        return NotificationSaveCollectInfoTemoinScreen(
          success:      success,
          errorMessage: message,
        );
      },
    ),
    GoRoute(
      path: '/notification_add_temoin',
      builder: (context, state) {
        final extra   = state.extra as Map<String, dynamic>;
        final success = extra['success'] as bool;
        final message = extra['message'] as String?;
        return NotificationAddTemoinScreen(
          success:      success,
          errorMessage: message,
        );
      },
    ),

    // ── ShellRoute — avec navbar ───────────────────────────────────────────────
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

// ── Splash Screen — initialise SQLite et restaure la session ──────────────────

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
    // Initialise SQLite
    await CreateTableTemoin.init();

    // Tente de restaurer le dernier user connecté
    final restored = await SessionService.restoreSession();

    if (!mounted) return;

    if (restored) {
      // Dernier user trouvé → va directement dans l'appli sans login
      context.go('/list_temoin');
    } else {
      // SQLite vide → connexion internet requise
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
 */
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

  // ─────────────────────────────────────────────────────────
  // REDIRECT GLOBAL (VERSION STABLE)
  // ─────────────────────────────────────────────────────────
  redirect: (context, state) {
    final location = state.matchedLocation;

    // 1. Splash toujours autorisé
    if (location == '/splash') return null;

    // 2. Si utilisateur connecté en mémoire → accès libre
    if (SessionService.isLoggedIn) return null;

    // 3. Sinon → forcer login sauf si déjà sur login
    if (location != '/login') {
      return '/login';
    }

    return null;
  },

  routes: [

    // ─────────────────────────────
    // SPLASH (INIT APP)
    // ─────────────────────────────
    GoRoute(
      path: '/splash',
      builder: (_, __) => const _SplashScreen(),
    ),

    // ─────────────────────────────
    // LOGIN
    // ─────────────────────────────
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),

    // ─────────────────────────────
    // PAGES HORS NAVBAR
    // ─────────────────────────────
    GoRoute(
      path: '/save_local_detail',
      builder: (context, state) {
        final temoin = state.extra as Map<String, dynamic>;
        return SaveLocalDetailScreen(temoin: temoin);
      },
    ),

    GoRoute(
      path: '/list_collect_data',
      builder: (context, state) {
        final temoin = state.extra as Map<String, dynamic>;
        return ListCollectData(temoin: temoin);
      },
    ),

    GoRoute(
      path: '/notification_update_delete',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return NotificationUpdateDelete(
          success: extra['success'] as bool,
          errorMessage: extra['message'] as String?,
        );
      },
    ),

    GoRoute(
      path: '/notification_save_collect',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return NotificationSaveCollectInfoTemoinScreen(
          success: extra['success'] as bool,
          errorMessage: extra['message'] as String?,
        );
      },
    ),

    GoRoute(
      path: '/notification_add_temoin',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return NotificationAddTemoinScreen(
          success: extra['success'] as bool,
          errorMessage: extra['message'] as String?,
        );
      },
    ),

    // ─────────────────────────────
    // SHELL ROUTE (NAVBAR)
    // ─────────────────────────────
    ShellRoute(
      builder: (context, state, child) {
        return AppNavbar(child: child);
      },
      routes: [

        GoRoute(
          path: '/list_temoin',
          builder: (_, __) => const ListTemoinScreen(),
        ),

        GoRoute(
          path: '/questionnaire',
          builder: (_, __) => const QuestionnaireScreen(),
        ),

        GoRoute(
          path: '/transfert',
          builder: (_, __) => const TransfertDataToCloudScreen(),
        ),

        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingScreen(),
        ),
      ],
    ),
  ],
);

// ─────────────────────────────────────────────────────────────
// SPLASH SCREEN (SEUL ENDROIT QUI RESTORE SQLITE)
// ─────────────────────────────────────────────────────────────

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

    // 2. Restore session depuis SQLite
    final restored = await SessionService.restoreSession();

    if (!mounted) return;

    // 3. Navigation stable
    if (restored) {
      SessionService.isLoggedIn
          ? context.go('/list_temoin')
          : context.go('/login');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}