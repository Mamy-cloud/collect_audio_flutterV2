// rgpd_widget.dart
// Widget checkbox RGPD avec lien vers le texte complet

import 'package:flutter/material.dart';
import '../../../../screens/rgpd_screen.dart';
import '../global/app_styles.dart';

class RgpdCheckbox extends StatelessWidget {
  final bool     accepted;
  final void Function(bool?) onChanged;

  const RgpdCheckbox({
    super.key,
    required this.accepted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accepted
              ? const Color(0xFF4CAF50)
              : const Color(0xFF333333),
          width: accepted ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24, height: 24,
            child: Checkbox(
              value:          accepted,
              onChanged:      onChanged,
              activeColor:    const Color(0xFF4CAF50),
              checkColor:     Colors.black,
              side: const BorderSide(color: Color(0xFF555555), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.input.copyWith(fontSize: 13),
                    children: const [
                      TextSpan(
                        text: 'Le témoin accepte la collecte et le traitement '
                            'de ses données personnelles conformément au ',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context:            context,
                    isScrollControlled: true,
                    backgroundColor:    Colors.transparent,
                    builder: (_) => const RgpdScreen(),
                  ),
                  child: Text(
                    'Règlement Général sur la Protection des Données (RGPD) →',
                    style: AppTextStyles.label.copyWith(
                      fontSize:        12,
                      color:           Colors.white70,
                      decoration:      TextDecoration.underline,
                      decorationColor: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
