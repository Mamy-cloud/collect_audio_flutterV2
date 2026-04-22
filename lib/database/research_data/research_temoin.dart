import '../conserve_data/conserve_data_to_sqlite.dart';

class ResearchTemoin {
  /// Recherche les témoins de l'utilisateur connecté.
  /// dont le nom OU le prénom contient [query].
  static Future<List<Map<String, dynamic>>> search(String query) async {
    // getAllInfoPersoTemoin filtre déjà par user_id via SessionService.
    final all = await ConserveDataToSqlite.getAllInfoPersoTemoin();

    if (query.trim().isEmpty) return all;

    final q = query.trim().toLowerCase();

    return all.where((t) {
      final nom    = (t['nom']    as String? ?? '').toLowerCase();
      final prenom = (t['prenom'] as String? ?? '').toLowerCase();
      return nom.contains(q) || prenom.contains(q);
    }).toList();
  }
}
