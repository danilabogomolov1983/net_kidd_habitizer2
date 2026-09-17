import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../habit/presentation/pages/habit_parameter_detail_page.dart';
import '../../../habit/presentation/pages/habit_parameter_list_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';

/// App shell — the composition root of the presentation layer.
///
/// Belongs to the `shell` slice. It owns navigation, the top-level
/// `Scaffold` and the FAB, and composes screens from sibling slices.
/// It contains no domain or application logic: state lives in each slice.
final class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    HabitParameterListPage(),
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
