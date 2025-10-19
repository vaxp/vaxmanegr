import 'package:flutter/material.dart';
import 'package:taskmanager/core/constants/app_colors.dart';

class ProcessActionSheet extends StatelessWidget {
  final VoidCallback onKill;
  final VoidCallback onShowLog;
  final VoidCallback onRestart;

  const ProcessActionSheet({
    super.key,
    required this.onKill,
    required this.onShowLog,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: Text('Kill Process', style: TextStyle(color: Colors.red)),
              onTap: onKill,
            ),
            ListTile(
              leading: const Icon(Icons.article, color: AppColors.textPrimary),
              title: Text('Show Log', style: TextStyle(color: AppColors.textPrimary)),
              onTap: onShowLog,
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: AppColors.accent),
              title: Text('Restart', style: TextStyle(color: AppColors.accent)),
              onTap: onRestart,
            ),
          ],
        ),
      ),
    );
  }
}
