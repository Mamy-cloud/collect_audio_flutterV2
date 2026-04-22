// notification_save_collect_info_temoin_screen.dart
// Notification après sauvegarde du questionnaire + audio
// Redirige automatiquement vers /questionnaire après 2 secondes

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/notifications_widget/notification_save_collect_info_temoin_widget.dart';

class NotificationSaveCollectInfoTemoinScreen extends StatefulWidget {
  final bool    success;
  final String? errorMessage;

  const NotificationSaveCollectInfoTemoinScreen({
    super.key,
    required this.success,
    this.errorMessage,
  });

  @override
  State<NotificationSaveCollectInfoTemoinScreen> createState() =>
      _NotificationSaveCollectInfoTemoinScreenState();
}

class _NotificationSaveCollectInfoTemoinScreenState
    extends State<NotificationSaveCollectInfoTemoinScreen> {

  @override
  void initState() {
    super.initState();

    // Redirection automatique vers /questionnaire après 2 secondes
    Timer(const Duration(seconds: 2), () {
      if (mounted) context.go('/questionnaire');
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationSaveCollectWidget(
      success:      widget.success,
      errorMessage: widget.errorMessage,
    );
  }
}
