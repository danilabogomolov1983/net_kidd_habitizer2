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
              onPressed: () => _showQuickAddSheet(context),
              tooltip: 'New habit',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('New habit',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge),
              const SizedBox(height: 4),
              Text('Choose a preset or start from scratch',
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              // Quick presets
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _QuickPreset(
                    icon: Icons.water_drop,
                    label: 'Water',
                    subtitle: '8 glasses',
                    type: 'hydration',
                    color: const Color(0xFF00A8D6),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openDetailWithPreset(
                          'Water intake', 'hydration', 8, 'glasses');
                    },
                  ),
                  _QuickPreset(
                    icon: Icons.fitness_center,
                    label: 'Workout',
                    subtitle: '45 min',
                    type: 'strength',
                    color: const Color(0xFF0058A3),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openDetailWithPreset(
                          'Workout', 'strength', 45, 'min');
                    },
                  ),
                  _QuickPreset(
                    icon: Icons.directions_run,
                    label: 'Cardio',
                    subtitle: '30 min',
                    type: 'cardio',
                    color: const Color(0xFF0058A3),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openDetailWithPreset(
                          'Cardio', 'cardio', 30, 'min');
                    },
                  ),
                  _QuickPreset(
                    icon: Icons.bedtime,
                    label: 'Sleep',
                    subtitle: '8 hours',
                    type: 'sleep',
                    color: const Color(0xFF7C5CFC),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openDetailWithPreset(
                          'Sleep', 'sleep', 8, 'hours');
                    },
                  ),
                  _QuickPreset(
                    icon: Icons.restaurant,
                    label: 'Protein',
                    subtitle: '150 g',
                    type: 'nutrition',
                    color: const Color(0xFFFF8C42),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openDetailWithPreset(
                          'Protein intake', 'nutrition', 150, 'g');
                    },
                  ),
                  _QuickPreset(
                    icon: Icons.self_improvement,
                    label: 'Meditate',
                    subtitle: '10 min',
                    type: 'mindfulness',
                    color: const Color(0xFF5E9B7C),
                    onTap: () {
                      Navigator.pop(ctx);
                      _openDetailWithPreset(
                          'Meditation', 'mindfulness', 10, 'min');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            const HabitParameterDetailPage()));
                  },
                  icon: const Icon(Icons.edit_note, size: 20),
                  label: const Text('Custom habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetailWithPreset(
      String desc, String type, double value, String unit) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => HabitParameterDetailPage(
        param: null, // new habit
        // We pass initial data via a separate constructor or route args.
        // For now, navigate to detail page — user fills in the rest.
        // The presets pre-fill data via custom constructor.
        presetDescription: desc,
        presetType: type,
        presetValue: value,
        presetUnit: unit,
      ),
    ));
  }
}

// ── Quick preset chip ────────────────────────────────────────
class _QuickPreset extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String type;
  final Color color;
  final VoidCallback onTap;

  const _QuickPreset({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.type,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 82) / 3,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
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
