// display_info_collect_screen.dart
// Bottom sheet — affiche le détail d'une collecte + lecteur audio

import 'package:flutter/material.dart';
import '../../../widgets/global/app_styles.dart';
import '../../../widgets/screens_widgets/display_info_collect_widget.dart';

class DisplayInfoCollectScreen extends StatelessWidget {
  final Map<String, dynamic> collecte;

  const DisplayInfoCollectScreen({super.key, required this.collecte});

  String _val(List<dynamic> q, String champ) {
    try {
      return q.firstWhere(
            (e) => e['champ'] == champ,
            orElse: () => {'valeur': ''},
          )['valeur'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final q      = collecte['questionnaire'] as List<dynamic>? ?? [];
    final lieu   = _val(q, 'lieu');
    final period = _val(q, 'periode_evoquee');
    final themes = _val(q, 'themes');
    final sujet  = _val(q, 'sujet_du_jour');
    final accomp = _val(q, 'accompagnant');
    final date   = (collecte['created_at'] as String? ?? '').split('T').first;
    final audio  = collecte['url_audio'] as String?;

    return Container(
      decoration: const BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Flèche retour + titre ──────────────────────────────────
            CollectSheetHeader(date: date),

            const SizedBox(height: 20),

            // ── Infos questionnaire ────────────────────────────────────
            if (lieu.isNotEmpty)
              CollectInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Lieu',
                  value: lieu),
            if (period.isNotEmpty)
              CollectInfoRow(
                  icon: Icons.access_time_outlined,
                  label: 'Période',
                  value: period),
            if (accomp.isNotEmpty)
              CollectInfoRow(
                  icon: Icons.people_outline,
                  label: 'Accompagnants',
                  value: accomp),
            if (sujet.isNotEmpty)
              CollectInfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Sujet',
                  value: sujet),

            // ── Thèmes ─────────────────────────────────────────────────
            if (themes.isNotEmpty)
              CollectThemesRow(themes: themes),

            const SizedBox(height: 24),

            // ── Lecteur audio ──────────────────────────────────────────
            if (audio != null)
              AudioPlayerWidget(audioPath: audio)
            else
              const NoAudioWidget(),

          ],
        ),
      ),
    );
  }
}
