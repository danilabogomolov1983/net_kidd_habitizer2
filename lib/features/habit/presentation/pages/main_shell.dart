import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/habit_parameter_notifier.dart';
import '../widgets/habit_parameter_card.dart';
import 'habit_parameter_detail_page.dart';
import 'statistics_page.dart';
import 'profile_page.dart';

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
            const Text('A simple habit tracker to help you build better routines.'),
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
                MaterialPageRoute(builder: (_) => const HabitParameterDetailPage()),
              ),
              tooltip: 'New',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

/// The home tab content – the habit list.
final class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(habitParameterNotifierProvider);
    final notifier = ref.read(habitParameterNotifierProvider.notifier);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
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
        if (list.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.self_improvement,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('No habits yet',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600)),
            ]),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => notifier.load(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final p = list[i];
              return HabitParameterCard(
                param: p,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => HabitParameterDetailPage(param: p)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
