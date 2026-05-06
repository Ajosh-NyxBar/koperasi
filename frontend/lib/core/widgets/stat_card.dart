import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkOutline
                : AppColors.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: c, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              maxLines: 1,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: c,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
