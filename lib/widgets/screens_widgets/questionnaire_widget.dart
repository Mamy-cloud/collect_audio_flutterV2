// questionnaire_widget.dart
// Widgets du formulaire questionnaire de contexte

import 'package:flutter/material.dart';
import '../global/app_styles.dart';

// ── Dropdown témoin ───────────────────────────────────────────────────────────

class TemoinDropdown extends StatelessWidget {
  final List<Map<String, dynamic>>            temoins;
  final Map<String, dynamic>?                 selected;
  final void Function(Map<String, dynamic>?)  onChanged;

  const TemoinDropdown({
    super.key,
    required this.temoins,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Témoin *', style: AppTextStyles.label),
        const SizedBox(height: 6),
        DropdownButtonFormField<Map<String, dynamic>>(
          value:         selected,
          hint:          Text('Sélectionner un témoin…',
                             style: AppTextStyles.label),
          style:         AppTextStyles.input,
          dropdownColor: AppColors.inputFill,
          decoration:    AppInputDecoration.of(''),
          isExpanded:    true,
          items: temoins.map((t) => DropdownMenuItem<Map<String, dynamic>>(
            value: t,
            child: Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 15, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${t['prenom']} ${t['nom']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ── Chip témoin sélectionné ────────────────────────────────────────────────────

class TemoinSelectedChip extends StatelessWidget {
  final String       label;
  final VoidCallback onRemove;

  const TemoinSelectedChip({
    super.key,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, color: AppColors.textPrimary, size: 15),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.input.copyWith(fontSize: 14)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: AppColors.textMuted, size: 14),
          ),
        ],
      ),
    );
  }
}

// ── Select générique ───────────────────────────────────────────────────────────

class QSelect extends StatelessWidget {
  final String       label;
  final String?      value;
  final List<String> options;
  final String       hint;
  final void Function(String?) onChanged;

  const QSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint = 'Sélectionner…',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value:         value,
          hint:          Text(hint, style: AppTextStyles.label),
          style:         AppTextStyles.input,
          dropdownColor: AppColors.inputFill,
          decoration:    AppInputDecoration.of(''),
          items: options.map((o) =>
              DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ── Champ texte libre ──────────────────────────────────────────────────────────

class QTextField extends StatelessWidget {
  final String               label;
  final String               hint;
  final TextEditingController controller;
  final int                  maxLines;

  const QTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style:      AppTextStyles.input,
          maxLines:   maxLines,
          decoration: AppInputDecoration.of('', hint: hint),
        ),
      ],
    );
  }
}

// ── Grille de tags thèmes ──────────────────────────────────────────────────────

class ThemesTagGrid extends StatelessWidget {
  static const List<String> allThemes = [
    'Enfance', 'Travail', 'Guerre', 'Mariage',
    'Voyage', 'Loisirs', 'Lieu de vie',
  ];

  final List<String>                          selected;
  final void Function(String theme, bool sel) onToggle;

  const ThemesTagGrid({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thèmes', style: AppTextStyles.label),
        const SizedBox(height: 10),
        Wrap(
          spacing:    8,
          runSpacing: 8,
          children: allThemes.map((theme) {
            final isSel = selected.contains(theme);
            return GestureDetector(
              onTap: () => onToggle(theme, !isSel),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.textPrimary : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSel
                        ? AppColors.textPrimary
                        : const Color(0xFF444444),
                  ),
                ),
                child: Text(
                  theme,
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: FontWeight.w500,
                    color: isSel ? AppColors.background : AppColors.textMuted,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Bouton principal ───────────────────────────────────────────────────────────

class PrendreTemoignageButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PrendreTemoignageButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style:     AppButtonStyle.primary,
        icon:      const Icon(Icons.mic, size: 20),
        label:     const Text('Prendre un témoignage oral'),
      ),
    );
  }
}

// ── État vide ──────────────────────────────────────────────────────────────────

class QuestionnaireEmptyState extends StatelessWidget {
  const QuestionnaireEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.article_outlined,
              size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Aucun questionnaire',
            style: AppTextStyles.headline.copyWith(
              fontSize: 20, fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les questionnaires créés apparaîtront ici.',
            style:     AppTextStyles.label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Carte questionnaire ────────────────────────────────────────────────────────

class QuestionnaireCard extends StatelessWidget {
  final String        temoinNom;
  final String        date;
  final List<String>  themes;
  final String?       sujet;
  final VoidCallback? onTap;

  const QuestionnaireCard({
    super.key,
    required this.temoinNom,
    required this.date,
    required this.themes,
    this.sujet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline,
                    color: AppColors.textMuted, size: 15),
                const SizedBox(width: 6),
                Text(temoinNom,
                    style: AppTextStyles.input
                        .copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(date, style: AppTextStyles.label),
              ],
            ),
            if (sujet != null && sujet!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(sujet!, style: AppTextStyles.label),
            ],
            if (themes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: themes.map((t) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:        AppColors.inputFill,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(t,
                      style: AppTextStyles.label.copyWith(fontSize: 11)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Select contact du témoin ───────────────────────────────────────────────────

class ContactSelectWidget extends StatelessWidget {
  final List<Map<String, String>> contacts;
  final String?                   selected;
  final void Function(String?)    onChanged;

  const ContactSelectWidget({
    super.key,
    required this.contacts,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = contacts
        .map((c) => c['nom'] ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact présent', style: AppTextStyles.label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value:         selected,
          hint:          Text('Sélectionner un contact…',
                             style: AppTextStyles.label),
          style:         AppTextStyles.input,
          dropdownColor: AppColors.inputFill,
          decoration:    AppInputDecoration.of(''),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('Aucun', style: AppTextStyles.label),
            ),
            ...options.map((name) => DropdownMenuItem<String>(
              value: name,
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(name),
                ],
              ),
            )),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
