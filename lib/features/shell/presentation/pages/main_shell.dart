import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _AppBottomBar(
        currentIndex: _currentIndex,
        onSelect: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

/// LinkedIn-style bottom bar: three icon+label tabs. The primary creation
/// action lives on the home tab as a FAB floating over this bar.
final class _AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _AppBottomBar({required this.currentIndex, required this.onSelect});

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
