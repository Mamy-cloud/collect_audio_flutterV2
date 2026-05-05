// session_deconnexion.dart
// Déconnexion avec confirmation — efface la session persistante

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/session_service.dart';
import '../widgets/global/app_styles.dart';

class SessionDeconnexion {
  static Future<void> logoutWithConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Déconnexion',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Voulez-vous vous déconnecter ?\nVos données locales seront conservées.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Déconnecter',
                style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await SessionService.logout();
      context.go('/login');
    }
  }
}
