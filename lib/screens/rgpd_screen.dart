// rgpd_screen.dart
// Écran modal affichant le texte complet du RGPD

import 'package:flutter/material.dart';
import '../../widgets/global/app_styles.dart';

class RgpdScreen extends StatelessWidget {
  const RgpdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 14, bottom: 8),
              decoration: BoxDecoration(
                  color:        Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    color: AppColors.textPrimary, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Protection des données personnelles',
                    style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close,
                      color: AppColors.textMuted, size: 20),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFF2A2A2A)),

          // ── Contenu RGPD ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _RgpdSection(
                    titre: '1. Responsable du traitement',
                    contenu:
                        'Les données collectées dans le cadre de cette application '
                        'sont traitées par l\'organisation responsable de la collecte '
                        'de témoignages oraux. Le responsable du traitement s\'engage '
                        'à respecter la réglementation en vigueur (RGPD - Règlement '
                        'UE 2016/679).',
                  ),
                  SizedBox(height: 20),
                  _RgpdSection(
                    titre: '2. Données collectées',
                    contenu:
                        'Dans le cadre de cette collecte, les données suivantes '
                        'peuvent être enregistrées :\n\n'
                        '• Nom et prénom du témoin\n'
                        '• Date de naissance\n'
                        '• Lieu de résidence (département, région)\n'
                        '• Enregistrement audio du témoignage\n'
                        '• Photo du témoin (optionnelle)\n'
                        '• Contacts du témoin\n'
                        '• Signature manuscrite',
                  ),
                  SizedBox(height: 20),
                  _RgpdSection(
                    titre: '3. Finalité du traitement',
                    contenu:
                        'Les données sont collectées dans le but de :\n\n'
                        '• Archiver et préserver les témoignages oraux\n'
                        '• Constituer un patrimoine mémoriel\n'
                        '• Réaliser des études historiques et culturelles\n\n'
                        'Les données ne seront en aucun cas utilisées à des fins '
                        'commerciales ou cédées à des tiers sans consentement explicite.',
                  ),
                  SizedBox(height: 20),
                  _RgpdSection(
                    titre: '4. Durée de conservation',
                    contenu:
                        'Les données personnelles et les enregistrements audio '
                        'seront conservés pour une durée de 50 ans à compter de '
                        'la date de collecte, dans le cadre de la préservation '
                        'du patrimoine oral.',
                  ),
                  SizedBox(height: 20),
                  _RgpdSection(
                    titre: '5. Droits du témoin',
                    contenu:
                        'Conformément au RGPD, le témoin dispose des droits suivants :\n\n'
                        '• Droit d\'accès à ses données\n'
                        '• Droit de rectification\n'
                        '• Droit à l\'effacement (droit à l\'oubli)\n'
                        '• Droit d\'opposition au traitement\n'
                        '• Droit à la portabilité des données\n\n'
                        'Pour exercer ces droits, le témoin peut contacter '
                        'le responsable du traitement.',
                  ),
                  SizedBox(height: 20),
                  _RgpdSection(
                    titre: '6. Sécurité des données',
                    contenu:
                        'Toutes les mesures techniques et organisationnelles '
                        'nécessaires sont mises en œuvre pour garantir la sécurité '
                        'et la confidentialité des données personnelles collectées.',
                  ),
                  SizedBox(height: 20),
                  _RgpdSection(
                    titre: '7. Consentement',
                    contenu:
                        'En cochant la case de consentement, le témoin confirme '
                        'avoir lu et compris la présente politique de protection '
                        'des données et consent au traitement de ses données '
                        'personnelles dans les conditions décrites ci-dessus.\n\n'
                        'Ce consentement est libre, éclairé et peut être retiré '
                        'à tout moment.',
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Bouton fermer ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppButtonStyle.primary,
                child: const Text('J\'ai compris'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RgpdSection extends StatelessWidget {
  final String titre;
  final String contenu;

  const _RgpdSection({required this.titre, required this.contenu});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titre,
            style: const TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w700,
              color:      AppColors.textPrimary,
            )),
        const SizedBox(height: 8),
        Text(contenu,
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
              height:   1.6,
              color:    const Color(0xFFBBBBBB),
            )),
      ],
    );
  }
}
