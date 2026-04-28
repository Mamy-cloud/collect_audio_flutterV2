// transfert_data_to_cloud_db.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../create_table/create_table_temoin.dart';
import '../../url_Api/api_config.dart';

class TransfertDataToCloudDb {
  StreamSubscription? _connectivitySubscription;
  bool _isRunning = false;

  final void Function(bool isConnected)?            onConnectivityChanged;
  final void Function(int done, int total)?         onProgress;
  final void Function(String label, String status)? onItemStatus;
  final void Function()?                            onComplete;
  final void Function(String error)?                onError;

  TransfertDataToCloudDb({
    this.onConnectivityChanged,
    this.onProgress,
    this.onItemStatus,
    this.onComplete,
    this.onError,
  });

  void startListening() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((results) async {
      final connected = !results.contains(ConnectivityResult.none) &&
          results.isNotEmpty;
      onConnectivityChanged?.call(connected);
      if (connected) await transferAll();
    });
  }

  void stopListening() => _connectivitySubscription?.cancel();

  static Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  // Render cold start peut prendre 30-60s → timeout à 60s
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.healthCloud))
          .timeout(const Duration(seconds: 80));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Étape 1 : envoie tous les id_questionnaire → récupère ceux à transférer

  static Future<List<String>> _checkIdsWithServer({
    required String userId,
    required List<String> ids,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.checkIds),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id':           userId,
              'id_questionnaires': ids,
            }),
          )
          .timeout(const Duration(seconds: 80));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return List<String>.from(body['ids_a_transferer'] ?? []);
      }
      return ids;
    } catch (_) {
      return ids;
    }
  }

  // ── Transfert principal ───────────────────────────────────────────────────

  Future<void> transferAll() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      final serverOk = await checkServerHealth();
      if (!serverOk) {
        onError?.call('Serveur indisponible. Réessayez plus tard.');
        return;
      }

      final db = CreateTableTemoin.db;

      final collectes = await db.query(
        'collect_info_from_temoin',
        where:     'synced = ?',
        whereArgs: [0],
      );

      if (collectes.isEmpty) {
        onComplete?.call();
        return;
      }

      final allIds = collectes
          .where((c) => c['id_questionnaire'] != null)
          .map((c) => c['id_questionnaire'] as String)
          .toList();

      final userId    = collectes.first['user_id'] as String? ?? '';
      final idsAFaire = await _checkIdsWithServer(userId: userId, ids: allIds);

      final collectesAFaire = collectes.where((c) {
        final idQ = c['id_questionnaire'] as String?;
        if (idQ == null) return true;
        return idsAFaire.contains(idQ);
      }).toList();

      if (collectesAFaire.isEmpty) {
        onComplete?.call();
        return;
      }

      final temoins = await db.query('info_perso_temoin');
      int done = 0;
      onProgress?.call(0, collectesAFaire.length);

      for (final collecte in collectesAFaire) {
        final collectId       = collecte['id'] as String;
        final idQuestionnaire = collecte['id_questionnaire'] as String? ?? collectId;
        final label           = 'Collecte $collectId';

        onItemStatus?.call(label, 'uploading');

        try {
          final q = jsonDecode(collecte['questionnaire'] as String) as List<dynamic>;
          final temoinId = q.isNotEmpty && q.first['champ'] == 'temoin_id'
              ? q.first['valeur'] as String : null;
          final temoin = temoinId != null
              ? temoins.firstWhere((t) => t['id'] == temoinId, orElse: () => {})
              : <String, Object?>{};

          final success = await _uploadCollecte(
            collecte:        collecte,
            temoin:          temoin,
            idQuestionnaire: idQuestionnaire,
          );

          if (success) {
            await db.update(
              'collect_info_from_temoin',
              {'synced': 1},
              where:     'id = ?',
              whereArgs: [collectId],
            );
            onItemStatus?.call(label, 'done');
          } else {
            onItemStatus?.call(label, 'error');
          }

          done++;
          onProgress?.call(done, collectesAFaire.length);
        } catch (_) {
          onItemStatus?.call(label, 'error');
          done++;
          onProgress?.call(done, collectesAFaire.length);
        }
      }

      onComplete?.call();
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      _isRunning = false;
    }
  }

  Future<bool> _uploadCollecte({
    required Map<String, dynamic> collecte,
    required Map<String, dynamic> temoin,
    required String idQuestionnaire,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.syncCloud));

    request.fields['user_id']          = collecte['user_id'] as String? ?? '';
    request.fields['temoin']           = jsonEncode(temoin);
    request.fields['questionnaire']    = collecte['questionnaire'] as String;
    request.fields['duree_audio']      = (collecte['duree_audio'] ?? 0).toString();
    request.fields['id_questionnaire'] = idQuestionnaire;

    final audioPath = collecte['url_audio'] as String?;
    if (audioPath != null && File(audioPath).existsSync()) {
      request.files.add(await http.MultipartFile.fromPath(
        'audio', audioPath, filename: audioPath.split('/').last,
      ));
    }

    final imgPath = temoin['img_temoin'] as String?;
    if (imgPath != null && File(imgPath).existsSync()) {
      request.files.add(await http.MultipartFile.fromPath(
        'image', imgPath, filename: imgPath.split('/').last,
      ));
    }

    // Upload audio peut être long → timeout généreux
    final streamed = await request.send().timeout(const Duration(seconds: 160));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['success'] == true;
    }
    return false;
  }
}
