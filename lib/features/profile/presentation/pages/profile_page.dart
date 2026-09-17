import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../habit/habit.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_logo.dart';

/// Profile screen — LinkedIn-style profile: gradient cover, overlapping
/// avatar, headline, stat row and settings/about sections.
///
/// Read-only over habit state; the one mutation it owns is the app-wide
/// theme preference (`themeModeProvider`), which lives in `shared/theme`.
final class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(habitParameterNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);
    final palette = context.habitizer;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Cover + avatar (LinkedIn hero) ──
        _ProfileHero(),
        // ── Headline ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                'Habitizer',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Build habits that last. For men who take their health seriously.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: palette.mutedText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Stats row ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: async.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (habits) {
              final now = DateTime.now();
              final active = habits
                  .where((h) => h.endDate == null || h.endDate!.isAfter(now))
                  .length;
              return _ProfileStats(
                habitsCount: habits.length,
                activeCount: active,
                joinedLabel: _joined(habits),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // ── Preferences ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionCard(
            title: 'Preferences',
            children: [
              _SettingsRow(
                icon: Icons.dark_mode_outlined,
                label: 'Dark mode',
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (dark) => ref
                      .read(themeModeProvider.notifier)
                      .state = dark ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── About ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionCard(
            title: 'About',
            children: [
              _SettingsRow(
                icon: Icons.info_outline,
                label: 'Version',
                trailing: _ValueText('1.1.0'),
              ),
              const _HairlineDivider(),
              _SettingsRow(
                icon: Icons.health_and_safety_outlined,
                label: 'Focus',
                trailing: _ValueText('Men\'s health'),
              ),
              const _HairlineDivider(),
              _SettingsRow(
                icon: Icons.phone_android_outlined,
                label: 'Platform',
                trailing: _ValueText('Mobile'),
              ),
              const _HairlineDivider(),
              _SettingsRow(
                icon: Icons.campaign_outlined,
                label: 'About Habitizer',
                trailing: Icon(Icons.chevron_right,
                    size: 20, color: palette.mutedText),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Habitizer',
                  applicationVersion: '1.1.0',
                  applicationIcon:
                      const Icon(Icons.self_improvement, size: 44),
                  children: const [
                    Text(
                      'Build habits that last. For men who take their health seriously.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Habitizer 1.1.0 · Made with Flutter',
            style: TextStyle(fontSize: 11.5, color: palette.mutedText),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  static String _joined(List<HabitParameter> habits) {
    if (habits.isEmpty) return '—';
    final dates = habits.map((h) => h.createdAt).toList()..sort();
    final diff = DateTime.now().difference(dates.first).inDays;
    if (diff == 0) return 'Today';
    if (diff < 7) return '${diff}d ago';
    if (diff < 30) return '${diff ~/ 7}w ago';
    if (diff < 365) return '${diff ~/ 30}mo ago';
    return '${diff ~/ 365}y ago';
  }
}

// ── Cover + avatar ───────────────────────────────────────────
final class _ProfileHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.gradientStart, palette.gradientEnd],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 150,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Decorativermark.
              Positioned(
                right: -18,
                top: -28,
                child: AppLogo(size: 150, opacity: 0.08, color: Colors.white),
              ),
              // Avatar overlapping the cover, LinkedIn-style.
              Positioned(
                bottom: -44,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: palette.canvas,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.self_improvement,
                      size: 42,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stats row ────────────────────────────────────────────────
final class _ProfileStats extends StatelessWidget {
  final int habitsCount;
  final int activeCount;
  final String joinedLabel;

  const _ProfileStats({
    required this.habitsCount,
    required this.activeCount,
    required this.joinedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          _StatColumn(value: '$habitsCount', label: 'Habits'),
          _hairline(palette),
          _StatColumn(value: '$activeCount', label: 'Active'),
          _hairline(palette),
          _StatColumn(value: joinedLabel, label: 'Joined'),
        ],
      ),
    );
  }

  Widget _hairline(HabitizerPalette palette) =>
      Container(width: 1, height: 28, color: palette.border);
}

final class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: palette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card ─────────────────────────────────────────────
final class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ── Settings row ─────────────────────────────────────────────
final class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: palette.mutedText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

final class _ValueText extends StatelessWidget {
  final String text;

  const _ValueText(this.text);

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: palette.mutedText,
      ),
    );
  }
}

final class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Container(height: 1, color: palette.border);
  }
}
