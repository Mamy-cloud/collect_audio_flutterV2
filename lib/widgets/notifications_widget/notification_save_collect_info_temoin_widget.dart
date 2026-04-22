// notification_save_collect_info_temoin_widget.dart
// Widgets de style pour la notification de sauvegarde du questionnaire

import 'package:flutter/material.dart';
import '../global/app_styles.dart';

class NotificationSaveCollectWidget extends StatelessWidget {
  final bool    success;
  final String? errorMessage;

  const NotificationSaveCollectWidget({
    super.key,
    required this.success,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ── Icône ────────────────────────────────────────────────────
              Container(
                width:  96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: success
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF1A1A1A),
                  border: Border.all(
                    color: success
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  success ? Icons.check : Icons.error_outline,
                  size:  44,
                  color: success
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935),
                ),
              ),

              const SizedBox(height: 32),

              // ── Titre ─────────────────────────────────────────────────────
              Text(
                success
                    ? 'Témoignage enregistré'
                    : 'Erreur lors de la sauvegarde',
                style: AppTextStyles.headline.copyWith(
                  fontSize:   22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // ── Sous-titre ────────────────────────────────────────────────
              Text(
                success
                    ? 'Le questionnaire et l\'enregistrement audio ont bien été sauvegardés.'
                    : errorMessage ?? 'Une erreur inattendue est survenue.',
                style: AppTextStyles.label.copyWith(
                  fontSize:   14,
                  height:     1.6,
                ),
                textAlign: TextAlign.center,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
