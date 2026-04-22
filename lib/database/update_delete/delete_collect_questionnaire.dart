// delete_collect_questionnaire.dart
// Suppression d'une collecte dans collect_info_from_temoin

import '../create_table/create_table_temoin.dart';

class DeleteCollectQuestionnaire {

  static Future<void> delete(String collectId) async {
    final db = CreateTableTemoin.db;

    // Suppression des infos liées avant la collecte
    await db.delete(
      'info_perso_temoin_collect',
      where:     'collect_id = ?',
      whereArgs: [collectId],
    );

    await db.delete(
      'collect_info_from_temoin',
      where:     'id = ?',
      whereArgs: [collectId],
    );
  }
}
