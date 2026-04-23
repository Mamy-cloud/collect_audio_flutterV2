// transfert_data_to_cloud_db.dart
// Transfert automatique vers FastAPI + Supabase
// Envoie uniquement les collectes non encore synchronisées (synced = 0)

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../create_table/create_table_temoin.dart';

class TransfertDataToCloudDb {
  // ─── URLs ──────────────────────────────────────────────────────────────────
  static const String _baseUrl = 'http://192.168.43.213:8000';

  static const String _syncEndpoint      = '$_baseUrl/mobile/transfert/cloud/sync';
  static const String _healthEndpoint    = '$_baseUrl/mobile/transfert/cloud/health';
  static const String _collectesEndpoint = '$_baseUrl/mobile/transfert/cloud/collectes';

  StreamSubscription? _connectivitySubscription;

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

  // ── Écoute connexion ───────────────────────────────────────────────────────

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

  void stopListening() {
    _connectivitySubscription?.cancel();
  }

  static Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);
  }

  // ── Vérifie que le serveur FastAPI est opérationnel ───────────────────────

  static Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse(_healthEndpoint))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Récupère les collectes synchronisées d'un utilisateur ─────────────────

  static Future<List<dynamic>> getCollectesByUser(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_collectesEndpoint/$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['collectes'] as List<dynamic>;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── Transfert uniquement les non synchronisées ────────────────────────────

  Future<void> transferAll() async {
    try {
      // Vérifie que le serveur est disponible avant de commencer
      final serverOk = await checkServerHealth();
      if (!serverOk) {
        onError?.call('Serveur FastAPI indisponible');
        return;
      }

      final db = CreateTableTemoin.db;

      // Récupère uniquement les collectes non synchronisées
      final collectes = await db.query(
        'collect_info_from_temoin',
        where: 'synced = ?',
        whereArgs: [0],
      );

      if (collectes.isEmpty) {
        onComplete?.call();
        return;
      }

      final temoins = await db.query('info_perso_temoin');

      int done = 0;
      onProgress?.call(0, collectes.length);

      for (final collecte in collectes) {
        final collectId = collecte['id'] as String;
        final label     = 'Collecte $collectId';

        onItemStatus?.call(label, 'uploading');

        try {
          // Trouve le témoin associé
          final q = jsonDecode(collecte['questionnaire'] as String)
              as List<dynamic>;
          final temoinId = q.isNotEmpty && q.first['champ'] == 'temoin_id'
              ? q.first['valeur'] as String
              : null;

          final temoin = temoinId != null
              ? temoins.firstWhere(
                  (t) => t['id'] == temoinId,
                  orElse: () => {},
                )
              : <String, Object?>{};

          // Envoie vers FastAPI /mobile/transfert/cloud/sync
          await _uploadCollecte(collecte: collecte, temoin: temoin);

          // Marque comme synchronisé dans la DB locale
          await db.update(
            'collect_info_from_temoin',
            {'synced': 1},
            where:     'id = ?',
            whereArgs: [collectId],
          );

          onItemStatus?.call(label, 'done');
          done++;
          onProgress?.call(done, collectes.length);

        } catch (e) {
          onItemStatus?.call(label, 'error');
        }
      }

      onComplete?.call();
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  // ── Upload vers FastAPI /mobile/transfert/cloud/sync ──────────────────────

  Future<void> _uploadCollecte({
    required Map<String, dynamic> collecte,
    required Map<String, dynamic> temoin,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(_syncEndpoint));

    // Données JSON
    request.fields['user_id']       = collecte['user_id'] as String? ?? 'test';
    request.fields['temoin']        = jsonEncode(temoin);
    request.fields['questionnaire'] = collecte['questionnaire'] as String;
    request.fields['duree_audio']   = (collecte['duree_audio'] ?? 0).toString();

    // Fichier audio
    final audioPath = collecte['url_audio'] as String?;
    if (audioPath != null && File(audioPath).existsSync()) {
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioPath,
        filename: audioPath.split('/').last,
      ));
    }

    // Image du témoin
    final imgPath = temoin['img_temoin'] as String?;
    if (imgPath != null && File(imgPath).existsSync()) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imgPath,
        filename: imgPath.split('/').last,
      ));
    }

    final streamed = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Timeout connexion FastAPI'),
    );
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception('Erreur ${response.statusCode}: ${body['detail'] ?? response.body}');
    }
  }
}
