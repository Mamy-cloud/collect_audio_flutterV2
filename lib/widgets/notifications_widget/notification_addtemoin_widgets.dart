import 'package:flutter/material.dart';
import '../global/app_styles.dart';

class NotificationIcon extends StatelessWidget {
  final bool success;
  const NotificationIcon({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: success
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.red.withValues(alpha: 0.12),
        border: Border.all(
          color: success ? Colors.green : Colors.red, width: 2),
      ),
      child: Icon(
        success ? Icons.check_rounded : Icons.close_rounded,
        color: success ? Colors.green : Colors.red, size: 40,
      ),
    );
  }
}

class NotificationTitle extends StatelessWidget {
  final bool success;
  const NotificationTitle({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Text(
      success ? 'Ajout témoin terminé' : 'Erreur lors de l\'ajout',
      style: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: success ? Colors.green : Colors.red,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class NotificationMessage extends StatelessWidget {
  final bool    success;
  final String? errorMessage;
  const NotificationMessage({super.key, required this.success, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Text(
      success
          ? 'Le témoin a été enregistré avec succès.'
          : errorMessage ?? 'Une erreur inattendue est survenue.',
      style: const TextStyle(
          fontSize: 14, color: AppColors.textMuted, height: 1.5),
      textAlign: TextAlign.center,
    );
  }
}

class RedirectProgressBar extends StatefulWidget {
  final int seconds;
  final VoidCallback onComplete;
  const RedirectProgressBar({super.key, required this.seconds, required this.onComplete});

  @override
  State<RedirectProgressBar> createState() => _RedirectProgressBarState();
}

class _RedirectProgressBarState extends State<RedirectProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: Duration(seconds: widget.seconds),
    )..forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:           1 - _ctrl.value,
            backgroundColor: const Color(0xFF2A2A2A),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 4,
          ),
        ),
      ),
      const SizedBox(height: 8),
      AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Text(
          'Redirection dans ${(widget.seconds * (1 - _ctrl.value)).ceil()}s...',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ),
    ]);
  }
}

class NotificationBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool         success;
  const NotificationBackButton({super.key, required this.onTap, required this.success});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: success ? Colors.green : Colors.red,
          foregroundColor: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          success ? 'Voir la liste' : 'Réessayer',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
