// save_questionnaire.dart.
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../create_table/create_table_temoin.dart';

class SaveQuestionnaire {
  static const _uuid = Uuid();

  static Future<String> save({
    required String       userId,
    required String       temoinId,
    String?               accompagnant,
    String?               contact,
    String?               lieu,
    String?               periodeEvoquee,
    required List<String> themes,
    String?               sujetDuJour,
    String?               urlAudio,
    int                   dureeAudio   = 0,
    String?               signatureUrl,
    bool                  accepteRgpd  = false,
  }) async {
    final db = CreateTableTemoin.db;
    final id = _uuid.v4();

    final questionnaire = [
      {'champ': 'temoin_id',       'valeur': temoinId},
      {'champ': 'accompagnant',    'valeur': accompagnant   ?? ''},
      {'champ': 'contact',         'valeur': contact        ?? ''},
      {'champ': 'lieu',            'valeur': lieu           ?? ''},
      {'champ': 'periode_evoquee', 'valeur': periodeEvoquee ?? ''},
      {'champ': 'themes',          'valeur': themes.join(',')},
      {'champ': 'sujet_du_jour',   'valeur': sujetDuJour    ?? ''},
    ];

    await db.insert(
      'collect_info_from_temoin',
      {
        'id':            id,
        'user_id':       userId,
        'questionnaire': jsonEncode(questionnaire),
        'url_audio':     urlAudio,
      'duree_audio':   dureeAudio,
      'signature_url': signatureUrl,
      'accepte_rgpd':  accepteRgpd ? 1 : 0,
        'created_at':    DateTime.now().toIso8601String(),
      },
    );

    return id;
  }

  static Future<void> updateAudio({
    required String collectId,
    required String urlAudio,
  }) async {
    final db = CreateTableTemoin.db;
    await db.update(
      'collect_info_from_temoin',
      {'url_audio': urlAudio},
      where:     'id = ?',
      whereArgs: [collectId],
    );
  }

  // Filtrage côté Dart — évite json_extract non supporté sur Android ancien
  static Future<List<Map<String, dynamic>>> getByUser(String userId) async {
    final db = CreateTableTemoin.db;

    final rows = await db.query(
      'collect_info_from_temoin',
      where:     'user_id = ?',
      whereArgs: [userId],
      orderBy:   'created_at DESC',
    );

    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      final r = Map<String, dynamic>.from(row);
      try {
        final q = jsonDecode(r['questionnaire'] as String) as List<dynamic>;
        r['questionnaire'] = q;

        // Récupère le temoin_id depuis le questionnaire
        final temoinId = q.isNotEmpty && q.first['champ'] == 'temoin_id'
            ? q.first['valeur'] as String?
            : null;

        if (temoinId != null) {
          final temoins = await db.query(
            'info_perso_temoin',
            where:     'id = ?',
            whereArgs: [temoinId],
            limit:     1,
          );
          if (temoins.isNotEmpty) {
            r['nom']    = temoins.first['nom'];
            r['prenom'] = temoins.first['prenom'];
          }
        }
        result.add(r);
      } catch (_) {
        r['questionnaire'] = [];
        result.add(r);
      }
    }

    return result;
  }
}
