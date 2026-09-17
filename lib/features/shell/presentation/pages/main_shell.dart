import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../habit/presentation/pages/habit_parameter_detail_page.dart';
import '../../../habit/presentation/pages/habit_parameter_list_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../../shared/theme/app_theme.dart';

/// App shell — the composition root of the presentation layer.
///
/// Belongs to the `shell` slice. It owns tab navigation and the bottom bar,
/// and composes screens from sibling slices. Like the LinkedIn mobile app,
/// each tab owns its header (search on Home, title on Statistics, hero on
/// Profile), and the primary creation action sits in the centre of the bar.
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

  void _openCreate() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HabitParameterDetailPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _AppBottomBar(
        currentIndex: _currentIndex,
        onSelect: (i) => setState(() => _currentIndex = i),
        onCreate: _openCreate,
      ),
    );
  }
}

/// LinkedIn-style bottom bar: icon+label tabs with the creation action
/// elevated in the centre.
final class _AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCreate;

  const _AppBottomBar({
    required this.currentIndex,
    required this.onSelect,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                  selected: currentIndex == 0,
                  onTap: () => onSelect(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.insights_outlined,
                  selectedIcon: Icons.insights,
                  label: 'Statistics',
                  selected: currentIndex == 1,
                  onTap: () => onSelect(1),
                ),
              ),
              // Centre creation action — the "post" of this app.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Tooltip(
                  message: 'New habit',
                  child: Material(
                    color: Theme.of(context).colorScheme.primary,
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                    child: InkWell(
                      onTap: onCreate,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(Icons.add, color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'Profile',
                  selected: currentIndex == 2,
                  onTap: () => onSelect(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.habitizer;
    final color = selected ? scheme.primary : palette.mutedText;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon, size: 24, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
