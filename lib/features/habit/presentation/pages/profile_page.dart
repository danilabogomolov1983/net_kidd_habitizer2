import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/habit_parameter_notifier.dart';

final class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(habitParameterNotifierProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFF0058A3).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.self_improvement,
                size: 44, color: Color(0xFF0058A3)),
          ),
          const SizedBox(height: 16),
          Text('Habitizer', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Build habits that last.\nFor men who take their health seriously.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Stats row
          async.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (habits) {
              final now = DateTime.now();
              final active = habits
                  .where((h) => h.endDate == null || h.endDate!.isAfter(now))
                  .length;
              return Row(
                children: [
                  Expanded(
                      child: _Tile(
                          icon: Icons.checklist,
                          label: 'Habits',
                          value: '${habits.length}')),
                  Expanded(
                      child: _Tile(
                          icon: Icons.local_fire_department,
                          label: 'Active',
                          value: '$active')),
                  Expanded(
                      child: _Tile(
                          icon: Icons.calendar_month,
                          label: 'Joined',
                          value: _joined(habits))),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // About card
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _AboutRow(
                      icon: Icons.info_outline, label: 'Version', value: '1.0.0'),
                  const Divider(height: 20),
                  _AboutRow(
                      icon: Icons.health_and_safety,
                      label: 'Focus',
                      value: 'Men\'s health'),
                  const Divider(height: 20),
                  _AboutRow(
                      icon: Icons.phone_android,
                      label: 'Platform',
                      value: 'Mobile'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _joined(List habits) {
    if (habits.isEmpty) return '—';
    final dates = habits.map((h) => h.createdAt).toList()..sort();
    final first = dates.first;
    final diff = DateTime.now().difference(first).inDays;
    if (diff == 0) return 'Today';
    if (diff < 7) return '${diff}d ago';
    if (diff < 30) return '${diff ~/ 7}w ago';
    if (diff < 365) return '${diff ~/ 30}mo ago';
    return '${diff ~/ 365}y ago';
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF0058A3)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 2),
          Text(label,
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      );
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _AboutRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
        ],
      );
}
