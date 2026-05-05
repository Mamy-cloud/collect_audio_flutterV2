// session_service.dart
// Gère la session utilisateur avec persistance locale (SharedPreferences)
// → première connexion en ligne, ensuite hors ligne possible

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyUserId      = 'session_user_id';
  static const _keyIdentifiant = 'session_identifiant';

  static String? _currentUserId;
  static String? _currentIdentifiant;

  // ── Getters ──────────────────────────────────────────────────────────────
  static String? get currentUserId      => _currentUserId;
  static String? get currentIdentifiant => _currentIdentifiant;
  static bool    get isLoggedIn         => _currentUserId != null;

  // ── Init au démarrage — restaure la session si elle existe ───────────────
  static Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId      = prefs.getString(_keyUserId);
    final identifiant = prefs.getString(_keyIdentifiant);

    if (userId != null && identifiant != null) {
      _currentUserId      = userId;
      _currentIdentifiant = identifiant;
      return true;   // session restaurée → pas besoin de se reconnecter
    }
    return false;    // pas de session → afficher login
  }

  // ── Login — appelé après authentification réussie ────────────────────────
  static Future<void> login(String userId, String identifiant) async {
    _currentUserId      = userId;
    _currentIdentifiant = identifiant;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId,      userId);
    await prefs.setString(_keyIdentifiant, identifiant);
  }

  // ── Logout — efface la session persistante ───────────────────────────────
  static Future<void> logout() async {
    _currentUserId      = null;
    _currentIdentifiant = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyIdentifiant);
  }
}
