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

final router = GoRouter(
  initialLocation: '/login',
  routes: [

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
