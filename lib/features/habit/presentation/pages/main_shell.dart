import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/habit_parameter_notifier.dart';
import '../widgets/habit_parameter_card.dart';
import 'habit_parameter_detail_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    _HomeTab(),
    StatisticsPage(),
    ProfilePage(),
  ];

  void _onMenuSelected(String value) {
    switch (value) {
      case 'home':
      case 'habits':
        setState(() => _currentIndex = 0);
        break;
      case 'about':
        showAboutDialog(
          context: context,
          applicationName: 'Habitizer',
          applicationVersion: '1.0.0',
          applicationIcon: const Icon(Icons.self_improvement, size: 48),
          children: [
            const Text(
                'Build habits that last. For men who take their health seriously.'),
          ],
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitizer'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onSelected: _onMenuSelected,
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'home',
                child: ListTile(
                  leading: Icon(Icons.home_outlined),
                  title: Text('Home'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const PopupMenuItem(
                value: 'habits',
                child: ListTile(
                  leading: Icon(Icons.checklist_outlined),
                  title: Text('Habits'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const HabitParameterDetailPage()),
              ),
              tooltip: 'New habit',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

}

// ── Home tab ──────────────────────────────────────────────────
final class _HomeTab extends ConsumerWidget {
  const _HomeTab();

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
              // Filter by search query
              final filtered = query.isEmpty
                  ? list
                  : list
                      .where((h) => h.description
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();

              if (filtered.isEmpty) {
                // Distinguish between "no habits at all" and "no search results"
                if (list.isEmpty) {
                  return _EmptyState(
                    icon: Icons.self_improvement,
                    title: 'Start your journey',
                    subtitle:
                        'Tap + to add your first habit.\nWater, workouts, sleep — track what matters.',
                    onAction: () {
                      // The FAB handles this; we just show the message
                    },
                  );
                }
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
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onAction,
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
              child:
                  Icon(icon, size: 40, color: const Color(0xFF0058A3).withAlpha(120)),
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
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5),
                textAlign: TextAlign.center),
            if (onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add habit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
