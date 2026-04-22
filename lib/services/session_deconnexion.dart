// session_deconnexion.dart
// Gestion de la déconnexion

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/session_service.dart';

class SessionDeconnexion {

  /// Déconnecte l'utilisateur et redirige vers /login
  static Future<void> logout(BuildContext context) async {
    // Vide la session en mémoire
    SessionService.logout();

    // Redirige vers /login en remplaçant toute la pile de navigation
    if (context.mounted) {
      context.go('/login');
    }
  }

  /// Affiche une confirmation avant de déconnecter
  static Future<void> logoutWithConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Se déconnecter',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Annuler',
                style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Se déconnecter',
                style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await logout(context);
    }
  }
}
