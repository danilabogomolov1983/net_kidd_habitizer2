import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/habit_parameter.dart';
import '../state/habit_feed_filter_provider.dart';
import '../state/habit_parameter_notifier.dart';
import '../state/habit_search_provider.dart';
import '../widgets/habit_parameter_card.dart';
import 'habit_parameter_detail_page.dart';

/// Habit browsing screen — the app shell's home tab, structured like the
/// LinkedIn mobile feed: a search header, filter pills and a card feed.
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
    final filter = ref.watch(habitFeedFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _FeedHeader(
            query: query,
            onQueryChanged: (v) =>
                ref.read(searchQueryProvider.notifier).state = v,
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Couldn\'t load your habits',
                subtitle: '$err',
                action: IconButton.filled(
                  onPressed: notifier.load,
                  tooltip: 'Try again',
                  icon: const Icon(Icons.refresh),
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return _FeedEmpty(onCreate: () => _pushDetail(context));
                }

                final filtered = list
                    .where(filter.accepts)
                    .where(
                      (h) => h.description.toLowerCase().contains(
                        query.trim().toLowerCase(),
                      ),
                    )
                    .toList();

                return Column(
                  children: [
                    _FilterBar(
                      list: list,
                      selected: filter,
                      onSelected: (f) =>
                          ref.read(habitFeedFilterProvider.notifier).state = f,
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? EmptyState(
                              icon: Icons.search_off,
                              title: 'No matches',
                              subtitle:
                                  'Nothing fits this filter${query.trim().isEmpty ? '' : ' and search'}. Try a different combination.',
                              action: IconButton.outlined(
                                onPressed: () {
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                  ref
                                      .read(habitFeedFilterProvider.notifier)
                                      .state = HabitFeedFilter
                                      .all;
                                },
                                tooltip: 'Clear filters',
                                icon: const Icon(Icons.filter_alt_off),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async => notifier.load(),
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  96,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (ctx, i) {
                                  final p = filtered[i];
                                  return HabitParameterCard(
                                    param: p,
                                    onTap: () => _pushDetail(context, param: p),
                                    onEdit: () =>
                                        _pushDetail(context, param: p),
                                    onDelete: () => notifier.delete(p.id),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      // Primary creation action — floats over the shell's bottom bar,
      // right-aligned (Material's standard FAB position).
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pushDetail(context),
        tooltip: 'New habit',
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }

  void _pushDetail(BuildContext context, {HabitParameter? param}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HabitParameterDetailPage(param: param)),
    );
  }
}

// ── Feed header (logo + pill search field) ──────────────────
final class _FeedHeader extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChanged;

  const _FeedHeader({required this.query, required this.onQueryChanged});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;

    return Container(
      color: palette.canvas,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Brand mark — the "profile avatar" slot of the LinkedIn header.
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: palette.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.self_improvement,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: onQueryChanged,
                decoration: InputDecoration(
                  hintText: 'Search habits',
                  isDense: true,
                  filled: true,
                  fillColor: palette.searchFill,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: palette.mutedText,
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 40),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: palette.mutedText,
                          tooltip: 'Clear search',
                          onPressed: () => onQueryChanged(''),
                        ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 36),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter pills ─────────────────────────────────────────────
final class _FilterBar extends StatelessWidget {
  final List<HabitParameter> list;
  final HabitFeedFilter selected;
  final ValueChanged<HabitFeedFilter> onSelected;

  const _FilterBar({
    required this.list,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: HabitFeedFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter = HabitFeedFilter.values[i];
          return _FilterPill(
            label: filter.label,
            count: filter.countOf(list),
            selected: filter == selected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

final class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.habitizer;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.primary : palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? scheme.primary : palette.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? scheme.onPrimary
                      : scheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.onPrimary.withValues(alpha: 0.22)
                        : palette.primaryTint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? scheme.onPrimary : scheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty feed (no habits at all) ────────────────────────────
final class _FeedEmpty extends StatelessWidget {
  final VoidCallback onCreate;

  const _FeedEmpty({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 96),
      children: [
        // LinkedIn-style "start a post" card.
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.checklist_rtl,
                  size: 30,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Start tracking your first habit',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Build habits that last — add a target like "Morning run · 5 km" and watch your progress.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: palette.mutedText,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              IconButton.filled(
                onPressed: onCreate,
                tooltip: 'Create habit',
                icon: const Icon(Icons.add),
                iconSize: 26,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Brand watermark (also anchors the empty-state integration test).
        const Center(child: AppLogo(size: 170, opacity: 0.07)),
      ],
    );
  }
}
