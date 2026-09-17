import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../state/habit_parameter_notifier.dart';
import '../state/habit_search_provider.dart';
import '../widgets/habit_parameter_card.dart';
import 'habit_parameter_detail_page.dart';

/// Habit browsing screen — also serves as the app shell's home tab.
///
/// Pure presentation: watches slice state, renders widgets, and delegates
/// every mutation to [HabitParameterNotifier]. No business logic lives here.
final class HabitParameterListPage extends ConsumerWidget {
  const HabitParameterListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(habitParameterNotifierProvider);
    final notifier = ref.read(habitParameterNotifierProvider.notifier);
    final query = ref.watch(searchQueryProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: (v) =>
                ref.read(searchQueryProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: 'Search habits...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon:
                  Icon(Icons.search, color: Colors.grey.shade400, size: 22),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () =>
                          ref.read(searchQueryProvider.notifier).state = '',
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // List
        Expanded(
          child: async.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 8),
                Text('Error: $err'),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () => notifier.load(),
                    child: const Text('Retry')),
              ]),
            ),
            data: (list) {
              // ── No habits at all → logo-only empty state ──
              if (list.isEmpty) {
                return Center(child: AppLogo(size: 200, opacity: 0.07));
              }

              // Filter by search query
              final filtered = query.isEmpty
                  ? list
                  : list
                      .where((h) => h.description
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();

              if (filtered.isEmpty) {
                return _EmptyState(
                  icon: Icons.search_off,
                  title: 'No matches',
                  subtitle: 'Try a different search term.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async => notifier.load(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final p = filtered[i];
                    return HabitParameterCard(
                      param: p,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                HabitParameterDetailPage(param: p)),
                      ),
                      onDelete: () => notifier.delete(p.id),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0058A3).withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 40, color: const Color(0xFF0058A3).withAlpha(120)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: const Color(0xFF1A1A2E)),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
