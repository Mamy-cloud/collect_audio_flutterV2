import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/notifications_widget/notification_update_delete_widget.dart';

class NotificationUpdateDelete extends StatelessWidget {
  final bool    success;
  final String? errorMessage;

  const NotificationUpdateDelete({
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
          child: Center(
            child: Column(
              mainAxisAlignment:  MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NotificationUpdateDeleteIcon(success: success),
                const SizedBox(height: 24),
                NotificationUpdateDeleteTitle(success: success),
                const SizedBox(height: 12),
                NotificationUpdateDeleteMessage(
                  success:      success,
                  errorMessage: errorMessage,
                ),
                const SizedBox(height: 40),
                if (success) ...[
                  NotificationUpdateDeleteProgressBar(
                    seconds:    2,
                    onComplete: () => context.go('/list_temoin'),
                  ),
                  const SizedBox(height: 32),
                ],
                if (!success) const SizedBox(height: 32),
                NotificationUpdateDeleteButton(
                  success: success,
                  onTap:   () => context.go('/list_temoin'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
