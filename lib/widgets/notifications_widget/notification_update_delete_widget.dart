import 'package:flutter/material.dart';
import '../global/app_styles.dart';

class NotificationUpdateDeleteIcon extends StatelessWidget {
  final bool success;
  const NotificationUpdateDeleteIcon({super.key, required this.success});

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
        color: success ? Colors.green : Colors.red,
        size: 40,
      ),
    );
  }
}

class NotificationUpdateDeleteTitle extends StatelessWidget {
  final bool success;
  const NotificationUpdateDeleteTitle({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return Text(
      success ? 'Données mises à jour' : 'Erreur lors de la mise à jour',
      style: TextStyle(
        fontSize:   20,
        fontWeight: FontWeight.w700,
        color:      success ? Colors.green : Colors.red,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class NotificationUpdateDeleteMessage extends StatelessWidget {
  final bool    success;
  final String? errorMessage;
  const NotificationUpdateDeleteMessage({
    super.key,
    required this.success,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      success
          ? 'Les informations ont été mises à jour avec succès.'
          : errorMessage ?? 'Une erreur inattendue est survenue.',
      style: const TextStyle(
          fontSize: 14, color: AppColors.textMuted, height: 1.5),
      textAlign: TextAlign.center,
    );
  }
}

class NotificationUpdateDeleteProgressBar extends StatefulWidget {
  final int          seconds;
  final VoidCallback onComplete;
  const NotificationUpdateDeleteProgressBar({
    super.key,
    required this.seconds,
    required this.onComplete,
  });

  @override
  State<NotificationUpdateDeleteProgressBar> createState() =>
      _NotificationUpdateDeleteProgressBarState();
}

class _NotificationUpdateDeleteProgressBarState
    extends State<NotificationUpdateDeleteProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: Duration(seconds: widget.seconds),
    )..forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value:           1 - _ctrl.value,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Text(
            'Redirection dans ${(widget.seconds * (1 - _ctrl.value)).ceil()}s...',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class NotificationUpdateDeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool         success;
  const NotificationUpdateDeleteButton({
    super.key,
    required this.onTap,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: success ? Colors.green : Colors.red,
          foregroundColor: Colors.white,
          elevation:       0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          success ? 'Voir la liste' : 'Réessayer',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
