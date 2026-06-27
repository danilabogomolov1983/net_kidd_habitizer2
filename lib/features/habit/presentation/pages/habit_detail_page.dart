import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_parameter.dart';
import '../../presentation/state/habit_notifier.dart';
import '../../presentation/widgets/habit_form.dart';

/// Detail / create page for a habit.
///
/// When [habit] is null the page is in **create mode**: name & type fields
/// are shown inline; tapping "Create" persists the habit and switches to
/// edit mode.  When [habit] is provided the page is in **edit mode** —
/// all values are always editable.
final class HabitDetailPage extends ConsumerStatefulWidget {
  final Habit? habit;

  const HabitDetailPage({super.key, this.habit});

  bool get isNew => habit == null;

  @override
  ConsumerState<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends ConsumerState<HabitDetailPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _typeCtrl;
  Habit? _habit; // null while creating, set after persisting or passed in

  static const _popularTypes = [
    'daily',
    'weekly',
    'monthly',
    'counter',
    'timer',
  ];

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
    _nameCtrl = TextEditingController(text: _habit?.name ?? '');
    _typeCtrl = TextEditingController(text: _habit?.type ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  bool get _isCreating => _habit == null;

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'daily':
        return Icons.today;
      case 'weekly':
        return Icons.date_range;
      case 'monthly':
        return Icons.calendar_month;
      case 'counter':
        return Icons.plus_one;
      case 'timer':
        return Icons.timer;
      default:
        return Icons.self_improvement;
    }
  }

  Color _typeColor(String type, ColorScheme cs) {
    switch (type.toLowerCase()) {
      case 'daily':
        return cs.primary;
      case 'weekly':
        return cs.tertiary;
      case 'monthly':
        return cs.secondary;
      case 'counter':
        return const Color(0xFFE91E63);
      case 'timer':
        return const Color(0xFFFF9800);
      default:
        return cs.primary;
    }
  }

  Future<void> _createHabit() async {
    final name = _nameCtrl.text.trim();
    final type = _typeCtrl.text.trim();
    if (name.isEmpty || type.isEmpty) return;

    final id = const Uuid().v4();
    final habitNotifier = ref.read(habitNotifierProvider.notifier);
    await habitNotifier.createHabit(id: id, type: type, name: name);

    setState(() {
      _habit = Habit(
        id: id,
        name: name,
        type: type,
        createdAt: DateTime.now(),
      );
    });
  }

  void _showEditHabitForm(BuildContext context) {
    final h = _habit;
    if (h == null) return;
    final habitNotifier = ref.read(habitNotifierProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => HabitForm(
        initialName: h.name,
        initialType: h.type,
        editId: h.id,
        onSubmit: (id, type, name) {
          final updated = h.copyWith(name: name, type: type);
          habitNotifier.updateHabit(updated);
          setState(() => _habit = updated);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final habit = _habit;
    final typeColor = habit != null ? _typeColor(habit.type, cs) : cs.primary;

    final habitId = habit?.id ?? '';
    final paramsAsync = habit != null
        ? ref.watch(habitParameterNotifierProvider(habitId))
        : const AsyncValue.data(<HabitParameter>[]);
    final paramsNotifier = habit != null
        ? ref.read(habitParameterNotifierProvider(habitId).notifier)
        : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            actions: [
              if (!_isCreating)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit habit',
                  onPressed: () => _showEditHabitForm(context),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: _isCreating
                  ? const Text('New Habit')
                  : Text(habit!.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [typeColor, typeColor.withAlpha(180)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      _isCreating
                          ? Icons.self_improvement
                          : _typeIcon(habit!.type),
                      size: 72,
                      color: Colors.white.withAlpha(40),
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
                  _isCreating ? 0 : 36),
              child: _isCreating
                  ? const SizedBox.shrink()
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: _buildEditHeader(
                          theme, cs, habit!, typeColor),
                    ),
            ),
          ),

          if (_isCreating)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: _buildCreateHeader(theme, cs),
                  ),
                ),
              ),
            ),

          if (_isCreating)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Fill in name & type, then tap Create',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            paramsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: cs.error),
                      const SizedBox(height: 8),
                      Text('Error: $err'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            paramsNotifier!.loadParameters(habitId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (params) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == params.length) {
                          return _ValueEditor(
                            habitId: habitId,
                            onSaved: (p) =>
                                paramsNotifier!.createParameter(
                              id: p.id,
                              habitId: p.habitId,
                              startDate: p.startDate,
                              endDate: p.endDate,
                              value: p.value,
                              measureUnit: p.measureUnit,
                            ),
                          );
                        }
                        final param = params[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ValueEditor(
                            habitId: habitId,
                            parameter: param,
                            onSaved: (updated) =>
                                paramsNotifier!.updateParameter(updated),
                            onDelete: () =>
                                paramsNotifier!.deleteParameter(
                                    habitId, param.id),
                          ),
                        );
                      },
                      childCount: params.length + 1,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Create-mode header ──────────────────────────────────────────────

  Widget _buildCreateHeader(ThemeData theme, ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Habit name',
            hintText: 'e.g. Morning workout',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _typeCtrl,
          decoration: const InputDecoration(
            labelText: 'Type',
            hintText: 'e.g. daily, weekly, counter',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _popularTypes.map((t) {
            return ActionChip(
              label: Text(t, style: theme.textTheme.labelSmall),
              onPressed: () => _typeCtrl.text = t,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _createHabit,
            icon: const Icon(Icons.check),
            label: const Text('Create Habit'),
          ),
        ),
      ],
    );
  }

  // ── Edit-mode header ────────────────────────────────────────────────

  Widget _buildEditHeader(
      ThemeData theme, ColorScheme cs, Habit habit, Color typeColor) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              habit.type.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: typeColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            'Created ${_daysAgoLabel(habit.createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withAlpha(120),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _daysAgoLabel(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '$diff days ago';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Unified value editor — used for both creating and editing
// ═══════════════════════════════════════════════════════════════════════════

class _ValueEditor extends StatefulWidget {
  final String habitId;
  final HabitParameter? parameter;
  final ValueChanged<HabitParameter> onSaved;
  final VoidCallback? onDelete;

  const _ValueEditor({
    required this.habitId,
    this.parameter,
    required this.onSaved,
    this.onDelete,
  });

  bool get isNew => parameter == null;

  @override
  State<_ValueEditor> createState() => _ValueEditorState();
}

class _ValueEditorState extends State<_ValueEditor> {
  late final TextEditingController _valueCtrl;
  late final TextEditingController _unitCtrl;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    final p = widget.parameter;
    _valueCtrl = TextEditingController(
      text: p != null
          ? (p.value == p.value.truncateToDouble()
              ? p.value.toInt().toString()
              : p.value.toString())
          : '',
    );
    _unitCtrl = TextEditingController(text: p?.measureUnit ?? '');
    _startDate = p?.startDate;
    _endDate = p?.endDate;
    _expanded = !widget.isNew;
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final current = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _fmt(DateTime? dt) => dt != null
      ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'
      : 'n.a.';

  String _fmtShort(DateTime? dt) => dt != null
      ? '${dt.month}/${dt.day}'
      : 'Set';

  void _save() {
    final v = double.tryParse(_valueCtrl.text.trim());
    final u = _unitCtrl.text.trim();
    if (v == null || u.isEmpty) return;

    if (widget.isNew) {
      widget.onSaved(HabitParameter.create(
        id: const Uuid().v4(),
        habitId: widget.habitId,
        startDate: _startDate,
        endDate: _endDate,
        value: v,
        measureUnit: u,
      ));
      _valueCtrl.clear();
      _unitCtrl.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
        _expanded = false;
      });
    } else {
      widget.onSaved(widget.parameter!.copyWith(
        value: v,
        measureUnit: u,
        startDate: _startDate,
        endDate: _endDate,
      ));
    }
  }

  void _cancel() {
    _valueCtrl.clear();
    _unitCtrl.clear();
    setState(() {
      _startDate = null;
      _endDate = null;
      _expanded = false;
    });
  }

  int _daysFrom(DateTime? d) =>
      d != null ? DateTime.now().difference(d).inDays : -1;

  int _daysTill(DateTime? d) =>
      d != null ? d.difference(DateTime.now()).inDays : -1;

  double? _progress() {
    final s = widget.parameter?.startDate;
    final e = widget.parameter?.endDate;
    if (s == null || e == null) return null;
    final total = e.difference(s).inDays;
    if (total <= 0) return null;
    return (DateTime.now().difference(s).inDays / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (widget.isNew && !_expanded) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: cs.outlineVariant.withAlpha(80),
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => _expanded = true),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 20),
                SizedBox(width: 8),
                Text('Add value',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    final isNew = widget.isNew;
    final p = widget.parameter;
    final daysFrom = _daysFrom(p?.startDate);
    final daysTill = _daysTill(p?.endDate);
    final progress = _progress();

    return Card(
      elevation: isNew ? 3 : 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: cs.outlineVariant.withAlpha(isNew ? 200 : 80),
          width: isNew ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  isNew ? 'New value' : 'Edit value',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (!isNew && widget.onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        size: 22, color: cs.error.withAlpha(180)),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _valueCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _startDate != null
                          ? _fmtShort(_startDate)
                          : 'Start',
                      style: theme.textTheme.bodySmall,
                    ),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(false),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _endDate != null ? _fmtShort(_endDate) : 'End',
                      style: theme.textTheme.bodySmall,
                    ),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                  ),
                ),
              ],
            ),
            if (_startDate != null || _endDate != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    setState(() => _startDate = _endDate = null),
                child: const Text('Clear dates'),
              ),
            ],
            const SizedBox(height: 16),
            if (!isNew && p != null) ...[
              if (progress != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress < 0.7 ? cs.primary : cs.error,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% complete',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: progress < 0.7 ? cs.primary : cs.error,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _StatChip(
                    icon: Icons.play_arrow_rounded,
                    label: daysFrom >= 0
                        ? (daysFrom == 0
                            ? 'Started today'
                            : daysFrom == 1
                                ? '1 day ago'
                                : '$daysFrom days ago')
                        : 'n.a.',
                    color: cs.primary,
                  ),
                  _StatChip(
                    icon: Icons.flag_rounded,
                    label: daysTill >= 0
                        ? (daysTill == 0
                            ? 'Ends today'
                            : daysTill == 1
                                ? '1 day left'
                                : '$daysTill days left')
                        : 'n.a.',
                    color: daysTill >= 0 && daysTill <= 7
                        ? cs.error
                        : cs.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  'From ${_fmt(p.startDate)}  ·  Until ${_fmt(p.endDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withAlpha(140),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                if (isNew)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                if (isNew) const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(isNew ? 'Save' : 'Save changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Mini stat chip
// ═══════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
