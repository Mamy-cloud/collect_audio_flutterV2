import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../create_table/create_table_temoin.dart';
import '../../services/session_service.dart';

class ConserveDataToSqlite {
  static const _uuid = Uuid();

  static Future<String> _copyImageToAppDir(String sourcePath) async {
    final Directory appDir;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      appDir = await getApplicationDocumentsDirectory();
    } else {
      appDir = await getApplicationSupportDirectory();
    }
    final imgDir  = Directory('${appDir.path}/images');
    await imgDir.create(recursive: true);
    final fileName = 'temoin_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = '${imgDir.path}/$fileName';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  // ── INSERT — lié à l'utilisateur connecté ────────────────────────────────

  static Future<String> insertInfoPersoTemoin({
    required String            nom,
    required String            prenom,
    String?                    dateNaissance,
    String?                    departement,
    String?                    region,
    String?                    imgTemoinPath,
    List<Map<String, String>>? contacts,
  }) async {
    final id     = _uuid.v4();
    final userId = SessionService.currentUserId;

    String? imgDestPath;
    if (imgTemoinPath != null) {
      imgDestPath = await _copyImageToAppDir(imgTemoinPath);
    }

    await CreateTableTemoin.db.insert('info_perso_temoin', {
      'id':             id,
      'user_id':        userId,
      'nom':            nom,
      'prenom':         prenom,
      'date_naissance': dateNaissance,
      'departement':    departement,
      'region':         region,
      'img_temoin':     imgDestPath,
      'contacts':       jsonEncode(contacts ?? []),
      'date_creation':  DateTime.now().toIso8601String(),
    });

    return id;
  }

  // ── SELECT — uniquement les témoins de l'utilisateur connecté ─────────────

  static Future<List<Map<String, dynamic>>> getAllInfoPersoTemoin() async {
    final userId = SessionService.currentUserId;

    final rows = await CreateTableTemoin.db.query(
      'info_perso_temoin',
      where:     userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy:   'date_creation DESC',
    );

    return rows.map((row) {
      final r = Map<String, dynamic>.from(row);
      try {
        r['contacts'] = jsonDecode(r['contacts'] as String? ?? '[]');
      } catch (_) {
        r['contacts'] = [];
      }
      return r;
    }).toList();
  }

  // ── SELECT par id ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getInfoPersoTemoinById(
      String id) async {
    final result = await CreateTableTemoin.db.query(
      'info_perso_temoin',
      where:     'id = ?',
      whereArgs: [id],
      limit:     1,
    );
    if (result.isEmpty) return null;
    final r = Map<String, dynamic>.from(result.first);
    try {
      r['contacts'] = jsonDecode(r['contacts'] as String? ?? '[]');
    } catch (_) {
      r['contacts'] = [];
    }
    return r;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  static Future<void> deleteInfoPersoTemoin(String id) async {
    final temoin = await getInfoPersoTemoinById(id);
    if (temoin != null && temoin['img_temoin'] != null) {
      final file = File(temoin['img_temoin'] as String);
      if (await file.exists()) await file.delete();
    }
    await CreateTableTemoin.db.delete(
      'info_perso_temoin',
      where:     'id = ?',
      whereArgs: [id],
    );
  }
}
