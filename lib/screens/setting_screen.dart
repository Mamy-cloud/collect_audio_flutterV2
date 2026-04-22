import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/session_service.dart';
import '../services/session_deconnexion.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/setting_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final identifiant = SessionService.currentIdentifiant ?? 'Utilisateur';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation:       0,
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontSize:   17,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Carte utilisateur ──────────────────────────────────────────
            UserInfoCard(identifiant: identifiant),

            const SizedBox(height: 32),

            // ── Section Application ────────────────────────────────────────
            const SettingSectionTitle(text: 'Application'),
            const SizedBox(height: 8),

            SettingTile(
              icon:      Icons.cloud_upload_outlined,
              label:     'Synchronisation Cloud',
              subtitle:  'Transférer vers Supabase',
              iconColor: const Color(0xFF7986CB),
              onTap:     () => context.go('/transfert'),
            ),

            const SizedBox(height: 8),

            SettingTile(
              icon:      Icons.info_outline,
              label:     'Version',
              subtitle:  '1.0.0',
              iconColor: AppColors.textMuted,
              onTap:     () {},
              trailing:  const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // ── Déconnexion ────────────────────────────────────────────────
            const SettingSectionTitle(text: 'Session'),
            const SizedBox(height: 8),

            SettingTile(
              icon:       Icons.logout,
              label:      'Se déconnecter',
              iconColor:  const Color(0xFFE53935),
              labelColor: const Color(0xFFE53935),
              onTap: () => SessionDeconnexion.logoutWithConfirm(context),
              trailing: const Icon(Icons.chevron_right,
                  size: 18, color: Color(0xFFE53935)),
            ),

          ],
        ),
      ),
    );
  }
}
