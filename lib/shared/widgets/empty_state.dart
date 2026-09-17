import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable LinkedIn-style empty state: tinted circular icon, bold title,
/// muted subtitle and an optional call-to-action.
final class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final Color? accent;

  /// Optional decorative watermark rendered behind the message.
  final Widget? watermark;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.accent,
    this.watermark,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    final accent = this.accent ?? Theme.of(context).colorScheme.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (watermark != null) Positioned.fill(child: Center(child: watermark)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: accent),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.5,
                  color: palette.mutedText,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[
                const SizedBox(height: 20),
                action!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
