import 'package:flutter/material.dart';
import 'package:vaxmanegr/core/constants/app_colors.dart';
import 'glass_card.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final Widget? child; // New parameter for dynamic content

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    this.child, // Initialize the new parameter
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (child != null) // Render dynamic content if provided
              child!
            else
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              unit,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}