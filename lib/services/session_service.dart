// session_service.dart
// Gestion de l'utilisateur connecté en mémoire

class SessionService {
  static String? _currentUserId;
  static String? _currentIdentifiant;

  static String? get currentUserId => _currentUserId;
  static String? get currentIdentifiant => _currentIdentifiant;

  static bool get isLoggedIn => _currentUserId != null;

  static void login(String userId, String identifiant) {
    _currentUserId     = userId;
    _currentIdentifiant = identifiant;
  }

  static void logout() {
    _currentUserId      = null;
    _currentIdentifiant = null;
  }
}
