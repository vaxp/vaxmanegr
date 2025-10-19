import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
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
    return GlassmorphicContainer(
      width: double.infinity,
      height: 220,
      borderRadius: 24,
      blur: 24,
      alignment: Alignment.center,
      border: 1.5,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.glassLight.withOpacity(0.25),
          AppColors.glassDark.withOpacity(0.25),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accent.withOpacity(0.4),
          AppColors.ramColor.withOpacity(0.2),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionTile(
                icon: Icons.delete_forever_rounded,
                iconColor: Colors.redAccent,
                title: 'Kill Process',
                titleColor: Colors.redAccent,
                onTap: onKill,
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.visibility_rounded,
                iconColor: AppColors.accent,
                title: 'Show Log',
                titleColor: AppColors.textPrimary,
                onTap: onShowLog,
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.restart_alt_rounded,
                iconColor: AppColors.diskColor,
                title: 'Restart',
                titleColor: AppColors.diskColor,
                onTap: onRestart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
