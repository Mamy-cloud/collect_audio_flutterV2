// login_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../url_Api/api_config.dart';

class LoginApiService {

  // ─── Singleton strict — un seul polling actif ─────────────────────────────
  static StreamController<ServerCheckResult>? _statusController;
  static Timer?                               _statusTimer;
  static StreamSubscription?                  _connectivitySub;
  static bool                                 _isPolling = false;

  static Stream<ServerCheckResult> startStatusPolling() {
    // ── Garde : ne recrée rien si déjà actif ──────────────────────────────
    if (_isPolling && _statusController != null && !_statusController!.isClosed) {
      return _statusController!.stream;
    }

    // ── Nettoyage complet avant de redémarrer ─────────────────────────────
    _statusTimer?.cancel();
    _connectivitySub?.cancel();
    _statusController?.close();

    _statusController = StreamController<ServerCheckResult>.broadcast();
    _isPolling        = true;

    // 1. Vérification immédiate
    _checkAndEmit();

    // 2. Polling toutes les 2s
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkAndEmit();
    });

    // 3. Réaction instantanée aux changements réseau natifs Android/iOS
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((_) => _checkAndEmit());

    return _statusController!.stream;
  }

  static void stopStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _statusController?.close();
    _statusController = null;
    _isPolling        = false;
  }

  static Future<void> _checkAndEmit() async {
    final result = await checkServerStatus();
    if (_statusController != null && !_statusController!.isClosed) {
      _statusController!.add(result);
    }
  }

  // ─── Vérifie internet réel + serveur ──────────────────────────────────────

  static Future<ServerCheckResult> checkServerStatus() async {

    // 1. Vérifie connectivity_plus (WiFi/data actif ?)
    final results     = await Connectivity().checkConnectivity();
    final hasInterface = results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);

    if (!hasInterface) {
      return const ServerCheckResult(
        internetAvailable: false,
        serverAvailable:   false,
        message:           'Pas de connexion Internet 📴',
      );
    }

    // 2. Vrai test internet — ping Google DNS (8.8.8.8)
    // connectivity_plus peut dire "WiFi actif" même si le routeur est HS
    final realInternet = await _hasRealInternet();

    if (!realInternet) {
      return const ServerCheckResult(
        internetAvailable: false,
        serverAvailable:   false,
        message:           'Pas de connexion Internet 📴',
      );
    }

    // 3. Ping le serveur FastAPI
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.statusLogin))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return const ServerCheckResult(
            internetAvailable: true,
            serverAvailable:   true,
            message:           'Serveur connecté ✅',
          );
        }
      }
    } catch (_) {}

    return const ServerCheckResult(
      internetAvailable: true,
      serverAvailable:   false,
      message:           'Serveur inaccessible ⚠️',
    );
  }

  // ─── Vrai test internet : HEAD sur Google ─────────────────────────────────
  // Léger (pas de body), rapide, fiable

  static Future<bool> _hasRealInternet() async {
    try {
      final response = await http
          .head(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  // ─── Login via FastAPI ─────────────────────────────────────────────────────

  static Future<LoginApiResult> login({
    required String identifiant,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.postLogin),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'identifiant': identifiant,
              'password':    password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return LoginApiResult(
          success:       body['success']        ?? false,
          identifiantOk: body['identifiant_ok'] ?? false,
          passwordOk:    body['password_ok']    ?? false,
          userId:        body['user_id'],
          message:       body['message']        ?? '',
        );
      }
      return LoginApiResult(
        success:       false,
        identifiantOk: false,
        passwordOk:    false,
        userId:        null,
        message:       'Erreur serveur (${response.statusCode})',
      );
    } catch (e) {
      return LoginApiResult(
        success:       false,
        identifiantOk: false,
        passwordOk:    false,
        userId:        null,
        message:       'Erreur réseau : $e',
      );
    }
  }
}

// ─── Modèles ──────────────────────────────────────────────────────────────────

class ServerCheckResult {
  final bool   internetAvailable;
  final bool   serverAvailable;
  final String message;

  const ServerCheckResult({
    required this.internetAvailable,
    required this.serverAvailable,
    required this.message,
  });
}

class LoginApiResult {
  final bool    success;
  final bool    identifiantOk;
  final bool    passwordOk;
  final String? userId;
  final String  message;

  const LoginApiResult({
    required this.success,
    required this.identifiantOk,
    required this.passwordOk,
    required this.userId,
    required this.message,
  });
}
