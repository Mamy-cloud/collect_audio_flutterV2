// setting_widget.dart
import 'package:flutter/material.dart';
import '../global/app_styles.dart';

// ── Tile paramètre ─────────────────────────────────────────────────────────────

class SettingTile extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final String?      subtitle;
  final VoidCallback onTap;
  final Color?       iconColor;
  final Color?       labelColor;
  final Widget?      trailing;

  const SettingTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.labelColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (iconColor ?? AppColors.textMuted)
                    .withValues(alpha: 0.12),
              ),
              child: Icon(icon,
                  size:  18,
                  color: iconColor ?? AppColors.textMuted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.input.copyWith(
                        fontSize:   14,
                        fontWeight: FontWeight.w500,
                        color:      labelColor ?? AppColors.textPrimary,
                      )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: AppTextStyles.label.copyWith(fontSize: 12)),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Section titre ──────────────────────────────────────────────────────────────

class SettingSectionTitle extends StatelessWidget {
  final String text;
  const SettingSectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          fontSize:      11,
          letterSpacing: 1.2,
          fontWeight:    FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Card info utilisateur ──────────────────────────────────────────────────────

class UserInfoCard extends StatelessWidget {
  final String identifiant;

  const UserInfoCard({super.key, required this.identifiant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.inputFill,
              border: Border.all(color: const Color(0xFF444444)),
            ),
            child: Center(
              child: Text(
                identifiant.isNotEmpty
                    ? identifiant[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize:   20,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(identifiant,
                  style: AppTextStyles.input.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              Text('Connecté',
                  style: AppTextStyles.label.copyWith(
                      fontSize: 12, color: const Color(0xFF4CAF50))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Dialog confirmation déconnexion ────────────────────────────────────────────

class LogoutConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Se déconnecter',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17)),
      content: const Text(
        'Voulez-vous vraiment vous déconnecter ?',
        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler',
              style: TextStyle(color: AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Se déconnecter',
              style: TextStyle(color: Color(0xFFE53935))),
        ),
      ],
    );
  }
}
