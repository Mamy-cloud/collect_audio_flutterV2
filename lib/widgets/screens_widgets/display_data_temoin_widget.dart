import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../global/app_styles.dart';

// ── Card témoin avec image, nom, prénom ───────────────────────────────────────

class TemoinCard extends StatelessWidget {
  final Map<String, dynamic> temoin;
  const TemoinCard({super.key, required this.temoin});

  @override
  Widget build(BuildContext context) {
    final nom     = temoin['nom']    as String? ?? '';
    final prenom  = temoin['prenom'] as String? ?? '';
    final imgPath = temoin['img_temoin'] as String?;

    return GestureDetector(
      onTap: () => context.push('/save_local_detail', extra: temoin),
      child: Container(
        margin:     const EdgeInsets.only(bottom: 12),
        padding:    const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(children: [

          _TemoinAvatar(imgPath: imgPath, nom: nom, prenom: prenom),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prenom.isNotEmpty ? prenom : '—',
                  style: const TextStyle(
                    color:      AppColors.textMuted,
                    fontSize:   12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nom.isNotEmpty ? nom : 'Sans nom',
                  style: const TextStyle(
                    color:      AppColors.textPrimary,
                    fontSize:   15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 20),
        ]),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _TemoinAvatar extends StatelessWidget {
  final String? imgPath;
  final String  nom;
  final String  prenom;

  const _TemoinAvatar({
    required this.imgPath,
    required this.nom,
    required this.prenom,
  });

  String get _initiales {
    final n = nom.isNotEmpty    ? nom[0].toUpperCase()    : '';
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    return '$p$n'.isNotEmpty ? '$p$n' : '?';
  }

  @override
  Widget build(BuildContext context) {
    if (imgPath != null && File(imgPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          File(imgPath!),
          width: 48, height: 48,
          fit:   BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Text(
          _initiales,
          style: const TextStyle(
            color:      AppColors.textPrimary,
            fontSize:   16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── État vide ─────────────────────────────────────────────────────────────────

class EmptyTemoinState extends StatelessWidget {
  const EmptyTemoinState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 56, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          const Text('Aucun témoin enregistré',
              style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('Ajoutez un témoin pour commencer',
              style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
        ],
      ),
    );
  }
}
