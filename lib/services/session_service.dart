// session_service.dart
// Gestion de l'utilisateur connecté en mémoire + persistance SQLite

import '../database/create_table/create_table_temoin.dart';

class SessionService {
  static String? _currentUserId;
  static String? _currentIdentifiant;

  static String? get currentUserId      => _currentUserId;
  static String? get currentIdentifiant => _currentIdentifiant;

  static bool get isLoggedIn => _currentUserId != null;

  // ─── Connexion : met à jour la mémoire + last_login dans SQLite ───────────

  static Future<void> login(String userId, String identifiant) async {
    _currentUserId      = userId;
    _currentIdentifiant = identifiant;
    // Met à jour last_login pour que ce user soit restauré au prochain démarrage
    await CreateTableTemoin.updateLastLogin(userId);
  }

  // ─── Déconnexion : vide la mémoire ────────────────────────────────────────

  static void logout() {
    _currentUserId      = null;
    _currentIdentifiant = null;
  }

  // ─── Restaure la session depuis SQLite au démarrage de l'appli ───────────

  static Future<bool> restoreSession() async {
    final user = await CreateTableTemoin.getLastLoggedUser();
    if (user == null) return false;

    _currentUserId      = user['id']          as String;
    _currentIdentifiant = user['identifiant'] as String;
    return true;
  }
}
