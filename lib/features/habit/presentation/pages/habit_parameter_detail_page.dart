import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit_parameter.dart';
import '../state/habit_parameter_notifier.dart';

final class HabitParameterDetailPage extends ConsumerStatefulWidget {
  final HabitParameter? param;
  const HabitParameterDetailPage({super.key, this.param});
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

  static const _primaryBlue = Color(0xFF0058A3);
  static const _types = ['health', 'food', 'fitness', 'sleep'];

  @override
  void initState() {
    super.initState();
    _descCtrl.text = widget.param?.description ?? '';
    _valueCtrl.text = widget.param != null
        ? (widget.param!.value == widget.param!.value.truncateToDouble()
            ? widget.param!.value.toInt().toString()
            : widget.param!.value.toString())
        : '';
    _unitCtrl.text = widget.param?.unit ?? '';
    _type = widget.param?.type ?? '';
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
  bool _ready = false;

  Color _typeColor(String t) => switch (t) {
        'health' => const Color(0xFFE8445A),
        'food' => const Color(0xFFFF8C42),
        'fitness' => _primaryBlue,
        'sleep' => const Color(0xFF7C5CFC),
        _ => _primaryBlue,
      };

  IconData _typeIcon(String t) => switch (t) {
        'health' => Icons.favorite,
        'food' => Icons.restaurant,
        'fitness' => Icons.fitness_center,
        'sleep' => Icons.bedtime,
        _ => Icons.check_circle_outline,
      };

  String _durationLabel(int totalDays) {
    if (totalDays == 0) return 'now';
    final parts = <String>[];
    int r = totalDays;
    if (r >= 365) {
      parts.add('${r ~/ 365}y');
      r %= 365;
    }
    if (r >= 30) {
      parts.add('${r ~/ 30}m');
      r %= 30;
    }
    if (r >= 7) {
      parts.add('${r ~/ 7}w');
      r %= 7;
    }
    if (r > 0 || parts.isEmpty) parts.add('${r}d');
    return parts.join(' ');
  }

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
      _save();
    }
  }

  Future<void> _save() async {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) return;
    var t = _type.isEmpty ? 'health' : _type;
    var v = double.tryParse(_valueCtrl.text.trim()) ?? 0;
    var u = _unitCtrl.text.trim().isEmpty ? 'times' : _unitCtrl.text.trim();
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
  }

  void _delete() {
    final p = _saved ?? widget.param;
    if (p == null) return;
    ref.read(habitParameterNotifierProvider.notifier).delete(p.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = _days(_endDate);
    final sinceStart = _since(_startDate);
    final p = _saved ?? widget.param;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_isNew ? 'New Habit' : (p?.description ?? '')),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFE8445A)),
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Description ──────────────────────────
            _SectionLabel(text: 'What'),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextFormField(
                  controller: _descCtrl,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Morning run',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Value + Unit (side by side, prominent) ──
            _SectionLabel(text: 'Target'),
            const SizedBox(height: 8),
            Row(
              children: [
                // Value
                Expanded(
                  flex: 3,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: TextFormField(
                        controller: _valueCtrl,
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _primaryBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Unit
                Expanded(
                  flex: 2,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: TextFormField(
                        controller: _unitCtrl,
                        decoration: const InputDecoration(
                          hintText: 'km',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Dates ──────────────────────────────────
            _SectionLabel(text: 'Duration'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DateCard(
                    label: 'Start',
                    date: _startDate,
                    icon: Icons.play_circle_outline,
                    color: _primaryBlue,
                    onTap: () => _pickDate(true),
                    onClear: _startDate != null
                        ? () {
                            setState(() => _startDate = null);
                            _save();
                          }
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child:
                      Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400),
                ),
                Expanded(
                  child: _DateCard(
                    label: 'End',
                    date: _endDate,
                    icon: Icons.flag_circle_outlined,
                    color: const Color(0xFF7C5CFC),
                    onTap: () => _pickDate(false),
                    onClear: _endDate != null
                        ? () {
                            setState(() => _endDate = null);
                            _save();
                          }
                        : null,
                  ),
                ),
              ],
            ),
            // Status line
            if (!_isNew && (sinceStart >= 0 || daysLeft >= 0)) ...[
              const SizedBox(height: 10),
              Center(
                child: _StatusBadge(
                  sinceStart: sinceStart,
                  daysLeft: daysLeft,
                  durationLabel: _durationLabel,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Type chips ─────────────────────────────
            _SectionLabel(text: 'Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((t) {
                final selected = _type == t;
                final tc = _typeColor(t);
                final ic = _typeIcon(t);
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ic, size: 16, color: selected ? Colors.white : tc),
                      const SizedBox(width: 6),
                      Text(t,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : tc,
                          )),
                    ],
                  ),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _type = t);
                    _save();
                  },
                  selectedColor: tc,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                      color: tc.withAlpha(selected ? 0 : 60)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  labelPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  int _days(DateTime? d) => d != null ? d.difference(DateTime.now()).inDays : -1;
  int _since(DateTime? d) =>
      d != null ? DateTime.now().difference(d).inDays : -1;
}

// ── Section label ───────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.3,
          ),
        ),
      );
}

// ── Date card ───────────────────────────────────────────────
class _DateCard extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateCard({
    required this.label,
    required this.date,
    required this.icon,
    required this.color,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 18,
                      color: hasDate ? color : Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    hasDate ? '${date!.month}/${date!.day}' : '—',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasDate
                          ? const Color(0xFF1A1A2E)
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Clear',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status badge ────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final int sinceStart;
  final int daysLeft;
  final String Function(int) durationLabel;

  const _StatusBadge({
    required this.sinceStart,
    required this.daysLeft,
    required this.durationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (sinceStart >= 0) {
      chips.add(_Chip(
        icon: Icons.play_circle_outline,
        label: 'Started ${durationLabel(sinceStart)} ago',
        color: const Color(0xFF0058A3),
      ));
      chips.add(const SizedBox(width: 8));
    }
    if (daysLeft >= 0) {
      chips.add(_Chip(
        icon: Icons.flag_circle_outlined,
        label: daysLeft == 0 ? 'Ends today' : '${durationLabel(daysLeft)} left',
        color: daysLeft <= 7 ? const Color(0xFFE8445A) : const Color(0xFF7C5CFC),
      ));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: chips);
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      );
}
