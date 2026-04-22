import 'package:flutter/material.dart';
import '../global/app_styles.dart';

// ── Titre Liste témoin ────────────────────────────────────────────────────────

class ListTemoinTitle extends StatelessWidget {
  const ListTemoinTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Liste témoin',
        style: TextStyle(
          fontSize:      22,
          fontWeight:    FontWeight.w700,
          color:         AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// ── Barre de recherche ────────────────────────────────────────────────────────

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SearchField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      style:        AppTextStyles.input,
      onChanged:    onChanged,
      keyboardType: TextInputType.text,
      decoration: AppInputDecoration.of('Rechercher un témoin').copyWith(
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textMuted,
          size:  20,
        ),
      ),
    );
  }
}

// ── Bouton Ajouter un témoin ──────────────────────────────────────────────────

class AddTemoinButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AddTemoinButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:        Colors.black,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add,
                  color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Ajouter un témoin',
              style: TextStyle(
                color:      Colors.white,
                fontSize:   14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
