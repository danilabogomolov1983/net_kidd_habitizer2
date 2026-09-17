import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/habit_type_style.dart';
import '../../domain/entities/habit_parameter.dart';
import '../state/habit_parameter_notifier.dart';

/// Create/edit form for a habit parameter.
///
/// Auto-saves on every change (no explicit save step — the draft is the
/// habit), so users can back out at any time without losing anything.
/// A "Done" pill button provides explicit closure.
final class HabitParameterDetailPage extends ConsumerStatefulWidget {
  final HabitParameter? param;
  final String? presetDescription;
  final String? presetType;
  final double? presetValue;
  final String? presetUnit;

  const HabitParameterDetailPage({
    super.key,
    this.param,
    this.presetDescription,
    this.presetType,
    this.presetValue,
    this.presetUnit,
  });

  bool get isNew => param == null;
  @override
  ConsumerState<HabitParameterDetailPage> createState() => _DetailState();
}

class _DetailState extends ConsumerState<HabitParameterDetailPage> {
  late final _descCtrl = TextEditingController();
  late final _valueCtrl = TextEditingController();
  late final _unitCtrl = TextEditingController();
  String _type = '';
  DateTime? _startDate;
  DateTime? _endDate;
  HabitParameter? _saved;
  bool _isSaving = false;
  bool _dirty = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _descCtrl.text = widget.param?.description ?? widget.presetDescription ?? '';
    _valueCtrl.text = widget.param != null
        ? (widget.param!.value == widget.param!.value.truncateToDouble()
            ? widget.param!.value.toInt().toString()
            : widget.param!.value.toString())
        : (widget.presetValue != null ? widget.presetValue.toString() : '');
    _unitCtrl.text = widget.param?.unit ?? widget.presetUnit ?? '';
    _type = widget.param?.type ?? widget.presetType ?? '';
    _startDate = widget.param?.startDate;
    _endDate = widget.param?.endDate;
    _saved = widget.param;
    _descCtrl.addListener(_onChanged);
    _valueCtrl.addListener(_onChanged);
    _unitCtrl.addListener(_onChanged);
    _ready = true;
  }

  void _onChanged() {
    if (!_ready) return;
    _dirty = true;
    _save();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  bool get _isNew => widget.isNew && _saved == null;

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final cur = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: cur ?? now,
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
      _dirty = true;
      _save();
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) return;
    var t = _type.isEmpty ? 'health' : _type;
    var v = double.tryParse(_valueCtrl.text.trim()) ?? 0;
    var u = _unitCtrl.text.trim().isEmpty ? 'times' : _unitCtrl.text.trim();

    _isSaving = true;
    _dirty = false;
    try {
      final notifier = ref.read(habitParameterNotifierProvider.notifier);
      if (_saved != null) {
        final updated = _saved!.copyWith(
          description: desc,
          type: t,
          startDate: _startDate,
          endDate: _endDate,
          value: v,
          unit: u,
        );
        await notifier.update(updated);
        setState(() => _saved = updated);
      } else {
        if (_type.isEmpty) setState(() => _type = t);
        final id = const Uuid().v4();
        await notifier.create(
          id: id,
          type: t,
          description: desc,
          startDate: _startDate,
          endDate: _endDate,
          value: v,
          unit: u,
        );
        setState(() => _saved = HabitParameter(
              id: id,
              type: t,
              description: desc,
              startDate: _startDate,
              endDate: _endDate,
              value: v,
              unit: u,
              createdAt: DateTime.now(),
            ));
      }
    } finally {
      _isSaving = false;
      if (_dirty) {
        _save();
      }
    }
  }

  void _delete() {
    final p = _saved ?? widget.param;
    if (p == null) return;
    ref.read(habitParameterNotifierProvider.notifier).delete(p.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.habitizer;
    final daysLeft = _days(_endDate);
    final sinceStart = _since(_startDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New habit' : 'Edit habit'),
        actions: [
          if (!_isNew)
            IconButton(
              icon: Icon(Icons.delete_outline, color: palette.danger),
              tooltip: 'Delete',
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            // ── Category ──────────────────────────────
            const _FieldLabel(text: 'Category'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: habitTypes.map((t) {
                final color = habitTypeColor(t);
                final selected = _type == t;
                return _CategoryPill(
                  type: t,
                  selected: selected,
                  color: color,
                  onTap: () {
                    setState(() => _type = t);
                    _dirty = true;
                    _save();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Description ───────────────────────────
            const _FieldLabel(text: 'What are you tracking?'),
            const SizedBox(height: 8),
            _FieldCard(
              child: TextFormField(
                controller: _descCtrl,
                maxLength: 30,
                autofocus: _isNew,
                decoration: const InputDecoration(
                  hintText: 'e.g. Morning run',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  counterText: '',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),

            // ── Target (value + unit) ─────────────────
            const _FieldLabel(text: 'Target'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _FieldCard(
                    child: TextFormField(
                      controller: _valueCtrl,
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FieldCard(
                    child: TextFormField(
                      controller: _unitCtrl,
                      decoration: const InputDecoration(
                        hintText: 'unit (km, min…)',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.mutedText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Duration ──────────────────────────────
            const _FieldLabel(text: 'Duration'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    date: _startDate,
                    icon: Icons.play_circle_outline,
                    color: scheme.primary,
                    label: 'Start',
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateTile(
                    date: _endDate,
                    icon: Icons.flag_outlined,
                    color: const Color(0xFF7C5CFC),
                    label: 'End',
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            if (!_isNew && (sinceStart >= 0 || daysLeft >= 0)) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (sinceStart >= 0)
                    _StatusBadge(
                      icon: Icons.play_circle_outline,
                      label: 'Started ${_durationLabel(sinceStart)} ago',
                      color: scheme.primary,
                    ),
                  if (daysLeft >= 0)
                    _StatusBadge(
                      icon: Icons.flag_outlined,
                      label: daysLeft == 0
                          ? 'Ends today'
                          : '${_durationLabel(daysLeft)} left',
                      color: daysLeft <= 7
                          ? palette.danger
                          : const Color(0xFF7C5CFC),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 28),
            Tooltip(
              message: 'Done',
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(64, 48),
                ),
                child: const Icon(Icons.check, size: 24),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Changes save automatically',
                style: TextStyle(fontSize: 12, color: palette.mutedText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _days(DateTime? d) => d != null ? d.difference(DateTime.now()).inDays : -1;
  int _since(DateTime? d) =>
      d != null ? DateTime.now().difference(d).inDays : -1;

  static String _durationLabel(int totalDays) {
    if (totalDays == 0) return 'today';
    final parts = <String>[];
    var r = totalDays;
    if (r >= 365) {
      parts.add('${r ~/ 365}y');
      r %= 365;
    }
    if (r >= 30) {
      parts.add('${r ~/ 30}mo');
      r %= 30;
    }
    if (r >= 7) {
      parts.add('${r ~/ 7}w');
      r %= 7;
    }
    if (r > 0 || parts.isEmpty) parts.add('${r}d');
    return parts.join(' ');
  }
}

// ── Field label ──────────────────────────────────────────────
final class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: palette.mutedText,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Card wrapper for form fields ─────────────────────────────
final class _FieldCard extends StatelessWidget {
  final Widget child;
  const _FieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}

// ── Category pill ────────────────────────────────────────────
final class _CategoryPill extends StatelessWidget {
  final String type;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.type,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : palette.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                habitTypeIcon(type),
                size: 15,
                color: selected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                habitTypeLabel(type),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Date tile ────────────────────────────────────────────────
final class _DateTile extends StatelessWidget {
  final DateTime? date;
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _DateTile({
    required this.date,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.habitizer;
    final hasDate = date != null;

    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 17, color: hasDate ? color : palette.mutedText),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: palette.mutedText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDate
                          ? '${date!.day.toString().padLeft(2, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.year}'
                          : 'Add date',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasDate
                            ? Theme.of(context).colorScheme.onSurface
                            : palette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: palette.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status badge ─────────────────────────────────────────────
final class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      );
}
