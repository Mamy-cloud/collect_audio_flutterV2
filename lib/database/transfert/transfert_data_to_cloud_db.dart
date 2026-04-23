// transfert_data_to_cloud_db.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../create_table/create_table_temoin.dart';
import '../../url_Api/api_config.dart';          // ← import centralisé

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
    return results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);
  }

  static Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.healthCloud))   // ← ApiConfig
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<dynamic>> getCollectesByUser(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.collectes}/$userId'))  // ← ApiConfig
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

  Future<void> transferAll() async {
    if (_isRunning) return;
    _isRunning = true;

    try {
      final serverOk = await checkServerHealth();
      if (!serverOk) {
        onError?.call('Serveur indisponible. Réessayez plus tard.');
        return;
      }

      final db       = CreateTableTemoin.db;
      final collectes = await db.query(
        'collect_info_from_temoin',
        where: 'synced = ?',
        whereArgs: [0],
      );

      if (collectes.isEmpty) { onComplete?.call(); return; }

      final temoins = await db.query('info_perso_temoin');
      int done = 0;
      onProgress?.call(0, collectes.length);

      for (final collecte in collectes) {
        final collectId = collecte['id'] as String;
        final label     = 'Collecte $collectId';
        onItemStatus?.call(label, 'uploading');

        try {
          final q = jsonDecode(collecte['questionnaire'] as String) as List<dynamic>;
          final temoinId = q.isNotEmpty && q.first['champ'] == 'temoin_id'
              ? q.first['valeur'] as String : null;
          final temoin = temoinId != null
              ? temoins.firstWhere((t) => t['id'] == temoinId, orElse: () => {})
              : <String, Object?>{};

          final success = await _uploadCollecte(collecte: collecte, temoin: temoin);

          if (success) {
            await db.update(
              'collect_info_from_temoin', {'synced': 1},
              where: 'id = ?', whereArgs: [collectId],
            );
            onItemStatus?.call(label, 'done');
          } else {
            onItemStatus?.call(label, 'error');
          }

          done++;
          onProgress?.call(done, collectes.length);
        } catch (_) {
          onItemStatus?.call(label, 'error');
          done++;
          onProgress?.call(done, collectes.length);
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
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.syncCloud),              // ← ApiConfig
    );

    request.fields['user_id']       = collecte['user_id'] as String? ?? '';
    request.fields['temoin']        = jsonEncode(temoin);
    request.fields['questionnaire'] = collecte['questionnaire'] as String;
    request.fields['duree_audio']   = (collecte['duree_audio'] ?? 0).toString();

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

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['success'] == true;
    }
    return false;
  }
}
