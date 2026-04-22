import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/save_questionnaire/save_questionnaire.dart';
import '../database/create_table/create_table_temoin.dart';
import '../services/session_service.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/questionnaire_widget.dart';
import '../widgets/screens_widgets/rgpd_widget.dart';
import 'audio_record.dart';
import 'signature_screen.dart';

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
  bool         _accepteRgpd   = false;
  String?      _signatureUrl;

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

  // ── Audio ──────────────────────────────────────────────────────────────────

  void _openAudioSheet() {
    if (_temoinSelectionne == null) {
      _snack("Sélectionnez un témoin avant d'enregistrer");
      return;
    }
    if (!_accepteRgpd) {
      _snack('Le témoin doit accepter la politique de confidentialité');
      return;
    }
    if (_signatureUrl == null) {
      _snack('La signature du témoin est requise');
      return;
    }
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => AudioRecordSheet(
        onSave: (audioPath, dureeSecondes) =>
            _saveAll(audioPath, dureeSecondes),
      ),
    );
  }

  // ── Sauvegarde ─────────────────────────────────────────────────────────────

  Future<void> _saveAll(String audioPath, int dureeSecondes) async {
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
        signatureUrl:   _signatureUrl,
        accepteRgpd:    _accepteRgpd,
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
      if (!mounted) return;
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
      _accepteRgpd        = false;
      _signatureUrl       = null;
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
          style: TextStyle(
            fontSize:   17,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Sélection témoin ─────────────────────────────────────
                  _loadingTemoins
                    ? const SizedBox(
                        height: 52,
                        child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.textMuted),
                        ),
                      )
                    : TemoinDropdown(
                        temoins:   _temoins,
                        selected:  _temoinSelectionne,
                        onChanged: (t) => setState(() {
                          _temoinSelectionne  = t;
                          _contactSelectionne = null;
                        }),
                      ),

                  const SizedBox(height: 14),

                  // ── Contact ──────────────────────────────────────────────
                  if (_temoinSelectionne != null &&
                      _contactsTemoin.isNotEmpty) ...[
                    ContactSelectWidget(
                      contacts:  _contactsTemoin,
                      selected:  _contactSelectionne,
                      onChanged: (v) =>
                          setState(() => _contactSelectionne = v),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Accompagnants ────────────────────────────────────────
                  QTextField(
                    label:      'Accompagnants',
                    hint:       'ex. Sa fille était présente dans la pièce',
                    controller: _accompagnantCtrl,
                  ),

                  const SizedBox(height: 24),

                  // ── Où ? ────────────────────────────────────────────────
                  _SectionTitle('Où ?'),
                  const SizedBox(height: 10),

                  QSelect(
                    label:     'Lieu',
                    value:     _lieu,
                    options:   _lieuxOptions,
                    hint:      'Sélectionner un lieu…',
                    onChanged: (v) => setState(() => _lieu = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Quand ? ─────────────────────────────────────────────
                  _SectionTitle('Quand ?'),
                  const SizedBox(height: 10),

                  QSelect(
                    label:     'Période évoquée',
                    value:     _periodeEvoquee,
                    options:   _periodesOptions,
                    hint:      'Sélectionner une période…',
                    onChanged: (v) => setState(() => _periodeEvoquee = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Thèmes ───────────────────────────────────────────────
                  ThemesTagGrid(
                    selected: _themes,
                    onToggle: (theme, isSel) {
                      setState(() {
                        isSel ? _themes.add(theme) : _themes.remove(theme);
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Quoi ? ──────────────────────────────────────────────
                  _SectionTitle('Quoi ?'),
                  const SizedBox(height: 10),

                  QTextField(
                    label:      'Sujet du jour',
                    hint:       'ex. Récit de son arrivée au village en 1964',
                    controller: _sujetCtrl,
                    maxLines:   3,
                  ),

                  const SizedBox(height: 24),

                  // ── RGPD ────────────────────────────────────────────────
                  _SectionTitle('Consentement RGPD'),
                  const SizedBox(height: 10),

                  RgpdCheckbox(
                    accepted:  _accepteRgpd,
                    onChanged: (v) =>
                        setState(() => _accepteRgpd = v ?? false),
                  ),

                  const SizedBox(height: 14),

                  // ── Signature ────────────────────────────────────────────
                  _SignatureButton(
                    signatureUrl: _signatureUrl,
                    onTap: () => showModalBottomSheet(
                      context:            context,
                      isScrollControlled: true,
                      backgroundColor:    Colors.transparent,
                      builder: (_) => SignatureScreen(
                        onSave: (path) =>
                            setState(() => _signatureUrl = path),
                      ),
                    ),
                    onRemove: () => setState(() => _signatureUrl = null),
                  ),

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

// ── Bouton / aperçu signature ──────────────────────────────────────────────────

class _SignatureButton extends StatelessWidget {
  final String?      signatureUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SignatureButton({
    required this.signatureUrl,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Signature du témoin *', style: AppTextStyles.label),
            const SizedBox(width: 8),
            if (signatureUrl != null)
              const Icon(Icons.check_circle_outline,
                  size: 14, color: Color(0xFF4CAF50)),
          ],
        ),
        const SizedBox(height: 8),

        if (signatureUrl == null)
          GestureDetector(
            onTap: onTap,
            child: Container(
              width:  double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color:        AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.draw_outlined,
                      size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Text('Appuyez pour signer',
                      style: AppTextStyles.label.copyWith(fontSize: 13)),
                ],
              ),
            ),
          )
        else
          Stack(
            children: [
              Container(
                height: 100,
                width:  double.infinity,
                decoration: BoxDecoration(
                  color:        AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF4CAF50), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(signatureUrl!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 4, right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
              Positioned(
                bottom: 4, left: 4,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:        Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Modifier',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ── Titre de section ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize:      13,
        fontWeight:    FontWeight.w600,
        color:         AppColors.textMuted,
        letterSpacing: 0.8,
      ),
    );
  }
}
