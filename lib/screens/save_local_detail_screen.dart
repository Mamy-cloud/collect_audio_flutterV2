import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/create_table/create_table_temoin.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/save_local_widget.dart';

class SaveLocalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> temoin;
  const SaveLocalDetailScreen({super.key, required this.temoin});

  @override
  State<SaveLocalDetailScreen> createState() => _SaveLocalDetailScreenState();
}

class _SaveLocalDetailScreenState extends State<SaveLocalDetailScreen> {
  late Map<String, dynamic>  _temoin;
  List<Map<String, dynamic>> _collectes  = [];
  bool                       _isLoading  = true;

  // ── Scroll + GlobalKeys pour navigation par numéro ────────────────────────
  final ScrollController          _scrollCtrl = ScrollController();
  List<GlobalKey> _keys = [];

  @override
  void initState() {
    super.initState();
    _temoin = Map<String, dynamic>.from(widget.temoin);
    _loadCollectes();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCollectes() async {
    setState(() => _isLoading = true);
    final db   = CreateTableTemoin.db;
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
            q.first['valeur'] == _temoin['id']) {
          collectes.add(r);
        }
      } catch (_) {
        r['questionnaire'] = [];
      }
    }

    // Générer une clé par collecte
    final keys = List.generate(collectes.length, (_) => GlobalKey());

    setState(() {
      _collectes = collectes;
      _keys      = keys;
      _isLoading = false;
    });
  }

  void _scrollToIndex(int index) {
    final ctx = _keys[index].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve:    Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation:       0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          '${_temoin['prenom']} ${_temoin['nom']}',
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
          : Stack(
              children: [
                // ── Contenu principal ──────────────────────────────────────
                SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 40, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Carte info témoin ──────────────────────────────
                      InfoPersoCard(temoin: _temoin),

                      // ── En-tête enregistrements ────────────────────────
                      if (_collectes.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text(
                              'Enregistrements',
                              style: TextStyle(
                                fontSize:   15,
                                fontWeight: FontWeight.w700,
                                color:      Color(0xFFE53935),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:        const Color(0xFFE53935)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_collectes.length}',
                                style: const TextStyle(
                                  fontSize:   11,
                                  fontWeight: FontWeight.w700,
                                  color:      Color(0xFFE53935),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],

                      // ── Liste des collectes ────────────────────────────
                      if (_collectes.isEmpty)
                        const CollecteEmptyState()
                      else
                        ...List.generate(_collectes.length, (i) {
                          return Column(
                            key:                 _keys[i],
                            crossAxisAlignment:  CrossAxisAlignment.start,
                            children: [
                              // Titre rouge "Enregistrement N"
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, bottom: 6),
                                child: Text(
                                  'Enregistrement ${i + 1}',
                                  style: const TextStyle(
                                    fontSize:   13,
                                    fontWeight: FontWeight.w700,
                                    color:      Color(0xFFE53935),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              CollecteCard(collecte: _collectes[i]),
                              if (i < _collectes.length - 1)
                                const SizedBox(height: 4),
                            ],
                          );
                        }),
                    ],
                  ),
                ),

                // ── Index numérique à droite ───────────────────────────────
                if (_collectes.length > 1)
                  Positioned(
                    right:  4,
                    top:    0,
                    bottom: 0,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_collectes.length, (i) {
                          return GestureDetector(
                            onTap: () => _scrollToIndex(i),
                            child: Container(
                              width:  26,
                              height: 26,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                color:        AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: const Color(0xFF333333)),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontSize:   11,
                                    fontWeight: FontWeight.w700,
                                    color:      Color(0xFFE53935),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
