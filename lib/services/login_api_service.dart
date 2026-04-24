// login_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../url_Api/api_config.dart';

class LoginApiService {

  // ─── Boucle de vérification toutes les 2 secondes ─────────────────────────

  static StreamController<ServerCheckResult>? _statusController;
  static Timer?                               _statusTimer;

  static Stream<ServerCheckResult> startStatusPolling() {
    _statusController?.close();
    _statusController = StreamController<ServerCheckResult>.broadcast();

    _checkAndEmit();

    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkAndEmit();
    });

    return _statusController!.stream;
  }

  static void stopStatusPolling() {
    _statusTimer?.cancel();
    _statusTimer = null;
    _statusController?.close();
    _statusController = null;
  }

  static Future<void> _checkAndEmit() async {
    final result = await checkServerStatus();
    if (_statusController != null && !_statusController!.isClosed) {
      _statusController!.add(result);
    }
  }

  // ─── Vérifie internet + serveur ───────────────────────────────────────────

  static Future<ServerCheckResult> checkServerStatus() async {
    final results  = await Connectivity().checkConnectivity();
    final internet = results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);

    if (!internet) {
      return const ServerCheckResult(           // ← const
        internetAvailable: false,
        serverAvailable:   false,
        message:           'Pas de connexion Internet 📴',
      );
    }

    try {
      final response = await http
          .get(Uri.parse(ApiConfig.statusLogin))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return const ServerCheckResult(       // ← const
            internetAvailable: true,
            serverAvailable:   true,
            message:           'Serveur connecté ✅',
          );
        }
      }
    } catch (_) {}

    return const ServerCheckResult(             // ← const
      internetAvailable: true,
      serverAvailable:   false,
      message:           'Serveur inaccessible ⚠️',
    );
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
