// login_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../url_Api/api_config.dart';

class LoginApiService {

  // ─── Vérifie internet réel + serveur (appel unique) ───────────────────────

  static Future<ServerCheckResult> checkServerStatus() async {

    // 1. Vérifie connectivity_plus (interface réseau active ?)
    final results      = await Connectivity().checkConnectivity();
    final hasInterface = results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);

    if (!hasInterface) {
      return const ServerCheckResult(
        internetAvailable: false,
        serverAvailable:   false,
        message:           'Pas de connexion Internet 📴',
      );
    }

    // 2. Vrai test internet — HEAD sur Google
    final realInternet = await _hasRealInternet();
    if (!realInternet) {
      return const ServerCheckResult(
        internetAvailable: false,
        serverAvailable:   false,
        message:           'Pas de connexion Internet 📴',
      );
    }

    // 3. Ping le serveur FastAPI
    // Render cold start peut prendre 30-60s → timeout à 60s
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.statusLogin))
          .timeout(const Duration(seconds: 80));

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

  // ─── Vrai test internet ────────────────────────────────────────────────────

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
          .timeout(const Duration(seconds: 80));

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
