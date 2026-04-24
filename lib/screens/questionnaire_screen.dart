import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/save_questionnaire/save_questionnaire.dart';
import '../database/create_table/create_table_temoin.dart';
import '../services/session_service.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/questionnaire_widget.dart';
import 'audio_record.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {

  Map<String, dynamic>?      _temoinSelectionne;
  List<Map<String, dynamic>> _temoins = [];
  String?                    _contactSelectionne;

  final _accompagnantCtrl = TextEditingController();
  final _sujetCtrl        = TextEditingController();

  String?      _lieu;
  String?      _periodeEvoquee;
  List<String> _themes         = [];
  bool         _isLoading      = false;
  bool         _loadingTemoins = true;

  static const _lieuxOptions = [
    'Domicile', 'EHPAD', 'Extérieur', 'Cuisine de la ferme', 'Autre',
  ];

  static const _periodesOptions = [
    'Enfance', 'Avant-guerre', 'Années 40', 'Années 50',
    'Années 60', 'Années 70', 'Années 80', 'Autre',
  ];

  List<Map<String, String>> get _contactsTemoin {
    if (_temoinSelectionne == null) return [];
    try {
      final raw = _temoinSelectionne!['contacts'];
      if (raw is List) {
        return raw.map((c) => Map<String, String>.from(c as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadTemoins();
  }

  Future<void> _loadTemoins() async {
    final userId = SessionService.currentUserId;
    final db     = CreateTableTemoin.db;
    final rows   = await db.query(
      'info_perso_temoin',
      where:     userId != null ? 'user_id = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy:   'nom ASC',
    );

    final temoins = rows.map((row) {
      final r = Map<String, dynamic>.from(row);
      try {
        r['contacts'] = jsonDecode(r['contacts'] as String? ?? '[]');
      } catch (_) {
        r['contacts'] = [];
      }
      return r;
    }).toList();

    if (mounted) {
      setState(() {
        _temoins        = temoins;
        _loadingTemoins = false;
      });
    }
  }

  void _openAudioSheet() {
    if (_temoinSelectionne == null) {
      _snack("Sélectionnez un témoin avant d'enregistrer");
      return;
    }
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => AudioRecordSheet(
        // ── Reçoit maintenant aussi waveData ──────────────────────────
        onSave: (audioPath, dureeSecondes, waveData) =>
            _saveAll(audioPath, dureeSecondes, waveData),
      ),
    );
  }

  Future<void> _saveAll(
    String       audioPath,
    int          dureeSecondes,
    List<double> waveData,       // ← nouveau paramètre
  ) async {
    setState(() => _isLoading = true);
    try {
      await SaveQuestionnaire.save(
        userId:         SessionService.currentUserId ?? 'test',
        temoinId:       _temoinSelectionne!['id'] as String,
        accompagnant:   _accompagnantCtrl.text.trim().isEmpty
                            ? null : _accompagnantCtrl.text.trim(),
        contact:        _contactSelectionne,
        lieu:           _lieu,
        periodeEvoquee: _periodeEvoquee,
        themes:         _themes,
        sujetDuJour:    _sujetCtrl.text.trim().isEmpty
                            ? null : _sujetCtrl.text.trim(),
        urlAudio:       audioPath,
        dureeAudio:     dureeSecondes,
        waveData:       jsonEncode(waveData),  // ← sérialise en JSON
      );

      if (!mounted) return;
      _reset();
      context.go('/notification_save_collect', extra: {
        'success': true,
        'message': null,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go('/notification_save_collect', extra: {
        'success': false,
        'message': e.toString(),
      });
    }
  }

  void _reset() {
    setState(() {
      _temoinSelectionne  = null;
      _contactSelectionne = null;
      _lieu               = null;
      _periodeEvoquee     = null;
      _themes             = [];
    });
    _accompagnantCtrl.clear();
    _sujetCtrl.clear();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.surface,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side:         const BorderSide(color: Colors.white24),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation:       0,
        title: const Text(
          'Nouveau questionnaire',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _loadingTemoins
                    ? const SizedBox(height: 52,
                        child: Center(child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.textMuted)))
                    : TemoinDropdown(
                        temoins:   _temoins,
                        selected:  _temoinSelectionne,
                        onChanged: (t) => setState(() {
                          _temoinSelectionne  = t;
                          _contactSelectionne = null;
                        }),
                      ),
                  const SizedBox(height: 14),
                  if (_temoinSelectionne != null && _contactsTemoin.isNotEmpty) ...[
                    ContactSelectWidget(
                      contacts:  _contactsTemoin,
                      selected:  _contactSelectionne,
                      onChanged: (v) => setState(() => _contactSelectionne = v),
                    ),
                    const SizedBox(height: 14),
                  ],
                  QTextField(label: 'Accompagnants',
                    hint: 'ex. Sa fille était présente dans la pièce',
                    controller: _accompagnantCtrl),
                  const SizedBox(height: 24),
                  _SectionTitle('Où ?'),
                  const SizedBox(height: 10),
                  QSelect(label: 'Lieu', value: _lieu, options: _lieuxOptions,
                    hint: 'Sélectionner un lieu…',
                    onChanged: (v) => setState(() => _lieu = v)),
                  const SizedBox(height: 24),
                  _SectionTitle('Quand ?'),
                  const SizedBox(height: 10),
                  QSelect(label: 'Période évoquée', value: _periodeEvoquee,
                    options: _periodesOptions, hint: 'Sélectionner une période…',
                    onChanged: (v) => setState(() => _periodeEvoquee = v)),
                  const SizedBox(height: 24),
                  ThemesTagGrid(
                    selected: _themes,
                    onToggle: (theme, isSel) {
                      setState(() {
                        isSel ? _themes.add(theme) : _themes.remove(theme);
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle('Quoi ?'),
                  const SizedBox(height: 10),
                  QTextField(label: 'Sujet du jour',
                    hint: 'ex. Récit de son arrivée au village en 1964',
                    controller: _sujetCtrl, maxLines: 3),
                  const SizedBox(height: 32),
                  PrendreTemoignageButton(onPressed: _openAudioSheet),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _accompagnantCtrl.dispose();
    _sujetCtrl.dispose();
    super.dispose();
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.textMuted, letterSpacing: 0.8));
  }
}
