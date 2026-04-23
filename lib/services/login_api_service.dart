// login_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../url_Api/api_config.dart';

class LoginApiService {

  // ─── Vérifie la connexion internet ────────────────────────────────────────

  static Future<bool> hasInternet() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);
  }

  // ─── Vérifie internet + serveur ───────────────────────────────────────────

  static Future<ServerCheckResult> checkServerStatus() async {
    // 1. Vérifie internet
    final internet = await hasInternet();
    if (!internet) {
      return ServerCheckResult(
        internetAvailable: false,
        serverAvailable:   false,
        message:           'Pas de connexion Internet 📴',
      );
    }

    // 2. Vérifie que le serveur répond
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.statusLogin))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return ServerCheckResult(
            internetAvailable: true,
            serverAvailable:   true,
            message:           'Serveur connecté ✅',
          );
        }
      }
      return ServerCheckResult(
        internetAvailable: true,
        serverAvailable:   false,
        message:           'Serveur inaccessible ⚠️',
      );
    } catch (_) {
      return ServerCheckResult(
        internetAvailable: true,
        serverAvailable:   false,
        message:           'Serveur inaccessible ⚠️',
      );
    }
  }

  // ─── Login via FastAPI ─────────────────────────────────────────────────────
  // Retourne l'id depuis Supabase pour le stocker dans SQLite local

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
          success:       body['success']       ?? false,
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
