// transfert_data_to_cloud_widget.dart
// Widgets de l'écran de transfert vers le cloud

import 'package:flutter/material.dart';
import '../global/app_styles.dart';

// ── Indicateur de connexion ────────────────────────────────────────────────────

class ConnexionStatusWidget extends StatelessWidget {
  final bool isConnected;

  const ConnexionStatusWidget({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color:        AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected
              ? const Color(0xFF2E7D32)
              : const Color(0xFFB71C1C),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53935),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isConnected ? 'Connecté à Internet' : 'Pas de connexion',
            style: AppTextStyles.label.copyWith(
              color: isConnected
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53935),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animation de transfert style WhatsApp ─────────────────────────────────────

class TransfertAnimationWidget extends StatefulWidget {
  final TransfertStatus status;
  final int             total;
  final int             transferred;

  const TransfertAnimationWidget({
    super.key,
    required this.status,
    required this.total,
    required this.transferred,
  });

  @override
  State<TransfertAnimationWidget> createState() =>
      _TransfertAnimationWidgetState();
}

class _TransfertAnimationWidgetState extends State<TransfertAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;
  late Animation<double>   _pulseAnim;
  late Animation<double>   _progressAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _progressCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    );

    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(TransfertAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == TransfertStatus.transferring) {
      _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
    }

    if (widget.total > 0) {
      _progressCtrl.animateTo(widget.transferred / widget.total);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Icône animée ─────────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Transform.scale(
            scale: widget.status == TransfertStatus.transferring
                ? _pulseAnim.value
                : 1.0,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _iconBgColor,
                border: Border.all(color: _iconBorderColor, width: 2),
              ),
              child: Icon(
                _iconData,
                size:  48,
                color: _iconColor,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Titre statut ──────────────────────────────────────────────────────
        Text(
          _statusLabel,
          style: AppTextStyles.input.copyWith(
            fontSize:   18,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // ── Sous-titre ────────────────────────────────────────────────────────
        Text(
          _statusSubLabel,
          style: AppTextStyles.label.copyWith(fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 28),

        // ── Barre de progression ──────────────────────────────────────────────
        if (widget.status == TransfertStatus.transferring ||
            widget.status == TransfertStatus.done) ...[
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           widget.total > 0
                        ? widget.transferred / widget.total
                        : null,
                    backgroundColor: const Color(0xFF2A2A2A),
                    valueColor:      AlwaysStoppedAnimation<Color>(
                        _progressColor),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.transferred} / ${widget.total} transferé(s)',
                      style: AppTextStyles.label.copyWith(fontSize: 12),
                    ),
                    if (widget.total > 0)
                      Text(
                        '${(widget.transferred / widget.total * 100).toStringAsFixed(0)}%',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 12,
                          color: _progressColor,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (widget.status == TransfertStatus.idle)
          const SizedBox(height: 43),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color get _iconBgColor {
    switch (widget.status) {
      case TransfertStatus.idle:
        return AppColors.inputFill;
      case TransfertStatus.transferring:
        return const Color(0xFF1A237E).withValues(alpha: 0.3);
      case TransfertStatus.done:
        return const Color(0xFF1B5E20).withValues(alpha: 0.3);
      case TransfertStatus.error:
        return const Color(0xFFB71C1C).withValues(alpha: 0.3);
    }
  }

  Color get _iconBorderColor {
    switch (widget.status) {
      case TransfertStatus.idle:        return const Color(0xFF333333);
      case TransfertStatus.transferring: return const Color(0xFF3F51B5);
      case TransfertStatus.done:        return const Color(0xFF4CAF50);
      case TransfertStatus.error:       return const Color(0xFFE53935);
    }
  }

  Color get _iconColor {
    switch (widget.status) {
      case TransfertStatus.idle:        return AppColors.textMuted;
      case TransfertStatus.transferring: return const Color(0xFF7986CB);
      case TransfertStatus.done:        return const Color(0xFF4CAF50);
      case TransfertStatus.error:       return const Color(0xFFE53935);
    }
  }

  IconData get _iconData {
    switch (widget.status) {
      case TransfertStatus.idle:        return Icons.cloud_upload_outlined;
      case TransfertStatus.transferring: return Icons.cloud_sync_outlined;
      case TransfertStatus.done:        return Icons.cloud_done_outlined;
      case TransfertStatus.error:       return Icons.cloud_off_outlined;
    }
  }

  String get _statusLabel {
    switch (widget.status) {
      case TransfertStatus.idle:        return 'Prêt à synchroniser';
      case TransfertStatus.transferring: return 'Transfert en cours...';
      case TransfertStatus.done:        return 'Synchronisation terminée';
      case TransfertStatus.error:       return 'Erreur de transfert';
    }
  }

  String get _statusSubLabel {
    switch (widget.status) {
      case TransfertStatus.idle:
        return 'Appuyez sur le bouton pour envoyer\nvos données vers le cloud.';
      case TransfertStatus.transferring:
        return 'Envoi des témoignages en cours,\nne fermez pas l\'application.';
      case TransfertStatus.done:
        return 'Toutes les données ont été\nenvoyées avec succès.';
      case TransfertStatus.error:
        return 'Une erreur est survenue.\nVérifiez votre connexion et réessayez.';
    }
  }

  Color get _progressColor {
    switch (widget.status) {
      case TransfertStatus.done:  return const Color(0xFF4CAF50);
      case TransfertStatus.error: return const Color(0xFFE53935);
      default:                    return const Color(0xFF7986CB);
    }
  }
}

// ── Carte d'un item en cours de transfert (style WhatsApp) ─────────────────────

class TransfertItemCard extends StatelessWidget {
  final String  label;
  final String  subLabel;
  final ItemTransfertStatus status;

  const TransfertItemCard({
    super.key,
    required this.label,
    required this.subLabel,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          // Icône statut
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _itemBgColor,
            ),
            child: Icon(_itemIcon, size: 18, color: _itemIconColor),
          ),
          const SizedBox(width: 12),
          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.input.copyWith(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subLabel, style: AppTextStyles.label.copyWith(fontSize: 12)),
              ],
            ),
          ),
          // Badge statut
          _StatusBadge(status: status),
        ],
      ),
    );
  }

  Color get _itemBgColor {
    switch (status) {
      case ItemTransfertStatus.waiting:    return AppColors.inputFill;
      case ItemTransfertStatus.uploading:  return const Color(0xFF1A237E).withValues(alpha: 0.2);
      case ItemTransfertStatus.done:       return const Color(0xFF1B5E20).withValues(alpha: 0.2);
      case ItemTransfertStatus.error:      return const Color(0xFFB71C1C).withValues(alpha: 0.2);
    }
  }

  IconData get _itemIcon {
    switch (status) {
      case ItemTransfertStatus.waiting:   return Icons.schedule_outlined;
      case ItemTransfertStatus.uploading: return Icons.upload_outlined;
      case ItemTransfertStatus.done:      return Icons.check;
      case ItemTransfertStatus.error:     return Icons.error_outline;
    }
  }

  Color get _itemIconColor {
    switch (status) {
      case ItemTransfertStatus.waiting:   return AppColors.textMuted;
      case ItemTransfertStatus.uploading: return const Color(0xFF7986CB);
      case ItemTransfertStatus.done:      return const Color(0xFF4CAF50);
      case ItemTransfertStatus.error:     return const Color(0xFFE53935);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final ItemTransfertStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == ItemTransfertStatus.uploading) {
      return const SizedBox(
        width: 16, height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color:       Color(0xFF7986CB),
        ),
      );
    }

    return Text(
      _label,
      style: AppTextStyles.label.copyWith(
        fontSize: 11,
        color:    _color,
      ),
    );
  }

  String get _label {
    switch (status) {
      case ItemTransfertStatus.waiting:   return 'En attente';
      case ItemTransfertStatus.uploading: return '';
      case ItemTransfertStatus.done:      return 'Envoyé';
      case ItemTransfertStatus.error:     return 'Erreur';
    }
  }

  Color get _color {
    switch (status) {
      case ItemTransfertStatus.waiting:   return AppColors.textMuted;
      case ItemTransfertStatus.uploading: return const Color(0xFF7986CB);
      case ItemTransfertStatus.done:      return const Color(0xFF4CAF50);
      case ItemTransfertStatus.error:     return const Color(0xFFE53935);
    }
  }
}

// ── Bouton de transfert ────────────────────────────────────────────────────────

class TransfertButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool          isLoading;

  const TransfertButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? const Color(0xFF2A2A2A)
              : AppColors.buttonBg,
          foregroundColor: onPressed == null
              ? AppColors.textMuted
              : const Color(0xFF000000),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.textMuted))
            : const Icon(Icons.cloud_upload_outlined, size: 20),
        label: Text(
          isLoading ? 'Transfert en cours...' : 'Synchroniser maintenant',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Enums ──────────────────────────────────────────────────────────────────────

enum TransfertStatus { idle, transferring, done, error }
enum ItemTransfertStatus { waiting, uploading, done, error }
