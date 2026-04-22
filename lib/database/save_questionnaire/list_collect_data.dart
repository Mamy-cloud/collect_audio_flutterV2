// list_collect_data.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../database/create_table/create_table_temoin.dart';
import '../../widgets/global/app_styles.dart';
import '../../widgets/screens_widgets/save_local_widget.dart';

class ListCollectData extends StatefulWidget {
  final Map<String, dynamic> temoin;

  const ListCollectData({super.key, required this.temoin});

  @override
  State<ListCollectData> createState() => _ListCollectDataState();
}

class _ListCollectDataState extends State<ListCollectData> {
  List<Map<String, dynamic>> _collectes = [];
  bool                       _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollectes();
  }

  Future<void> _loadCollectes() async {
    final db   = CreateTableTemoin.db;
    // Filtrage côté Dart — évite json_extract non supporté sur Android ancien
    final rows = await db.query(
      'collect_info_from_temoin',
      orderBy: 'created_at DESC',
    );

    final collectes = <Map<String, dynamic>>[];
    for (final row in rows) {
      final r = Map<String, dynamic>.from(row);
      try {
        final q = jsonDecode(r['questionnaire'] as String) as List<dynamic>;
        r['questionnaire'] = q;
        if (q.isNotEmpty &&
            q.first['champ'] == 'temoin_id' &&
            q.first['valeur'] == widget.temoin['id']) {
          collectes.add(r);
        }
      } catch (_) {
        r['questionnaire'] = [];
      }
    }

    setState(() {
      _collectes = collectes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.temoin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation:       0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          '${t['prenom']} ${t['nom']}',
          style: const TextStyle(
            fontSize:   17,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoPersoCard(temoin: t),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text(
                        'Témoignages enregistrés',
                        style: TextStyle(
                          fontSize:      13,
                          fontWeight:    FontWeight.w600,
                          color:         AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:        AppColors.inputFill,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_collectes.length}',
                          style: AppTextStyles.label.copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_collectes.isEmpty)
                    const CollecteEmptyState()
                  else
                    ..._collectes.map((c) => CollecteCard(collecte: c)),
                ],
              ),
            ),
    );
  }
}
