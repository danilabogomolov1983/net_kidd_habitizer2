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
    _saved = widget.param; // editing existing → update, not create
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
    _descCtrl.dispose(); _valueCtrl.dispose(); _unitCtrl.dispose();
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

  int _days(DateTime? d) => d != null ? d.difference(DateTime.now()).inDays : -1;
  int _since(DateTime? d) => d != null ? DateTime.now().difference(d).inDays : -1;

  String _durationLabel(int totalDays) {
    if (totalDays == 0) return 'now';
    final parts = <String>[];
    int r = totalDays;
    if (r >= 365) { parts.add('${r ~/ 365}y'); r %= 365; }
    if (r >= 30) { parts.add('${r ~/ 30}m'); r %= 30; }
    if (r >= 7) { parts.add('${r ~/ 7}w'); r %= 7; }
    if (r > 0 || parts.isEmpty) parts.add('${r}d');
    return parts.join(' ');
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final cur = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context, initialDate: cur ?? now,
      firstDate: DateTime(2020), lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) { _startDate = picked; } else { _endDate = picked; }
      });
    }
  }

  Future<void> _save() async {
    final desc = _descCtrl.text.trim();
    final v = double.tryParse(_valueCtrl.text.trim());
    final u = _unitCtrl.text.trim();
    if (desc.isEmpty || _type.isEmpty || v == null || u.isEmpty) return;
    final notifier = ref.read(habitParameterNotifierProvider.notifier);
    if (_saved != null) {
      final updated = _saved!.copyWith(
        description: desc, type: _type, startDate: _startDate,
        endDate: _endDate, value: v, unit: u,
      );
      await notifier.update(updated);
      setState(() => _saved = updated);
    } else {
      final id = const Uuid().v4();
      await notifier.create(
        id: id, type: _type, description: desc,
        startDate: _startDate, endDate: _endDate, value: v, unit: u,
      );
      setState(() => _saved = HabitParameter(
        id: id, type: _type, description: desc,
        startDate: _startDate, endDate: _endDate, value: v, unit: u,
        createdAt: DateTime.now(),
      ));
    }
  }

  void _delete() {
    final p = _saved ?? widget.param;
    if (p == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Remove "${p.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(habitParameterNotifierProvider.notifier).delete(p.id);
              Navigator.pop(ctx); Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE8445A)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
            IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFE8445A)),
                onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── ALL fields in ONE row ──────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Description
                    SizedBox(
                      width: 180,
                      child: TextFormField(
                        controller: _descCtrl,
                        maxLength: 30,
                        decoration: const InputDecoration(
                            hintText: 'Description', isDense: true, border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            counterText: ''),
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Value
                    SizedBox(
                      width: 52,
                      child: TextFormField(
                        controller: _valueCtrl,
                        decoration: const InputDecoration(
                            hintText: 'Val', isDense: true, border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10)),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    // Unit
                    SizedBox(
                      width: 52,
                      child: TextFormField(
                        controller: _unitCtrl,
                        decoration: const InputDecoration(
                            hintText: 'Unit', isDense: true, border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10)),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Start date icon
                    _DateIcon(isStart: true, date: _startDate, color: _primaryBlue,
                        onTap: () => _pickDate(true)),
                    Text('·', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                    // End date icon
                    _DateIcon(isStart: false, date: _endDate,
                        color: const Color(0xFF7C5CFC),
                        onTap: () => _pickDate(false)),
                    // Clear dates
                    if (_startDate != null || _endDate != null)
                      GestureDetector(
                        onTap: () { setState(() => _startDate = _endDate = null); if (!_isNew) _save(); },
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close, size: 13, color: Color(0xFFB0B0C0)),
                        ),
                      ),
                    const SizedBox(width: 2),
                    // Stats
                    if (!_isNew && sinceStart >= 0)
                      Text('${_durationLabel(sinceStart)} ago',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _primaryBlue)),
                    if (!_isNew && daysLeft >= 0) ...[
                      const SizedBox(width: 3),
                      Text(daysLeft == 0 ? 'ends' : '${_durationLabel(daysLeft)} left',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                              color: daysLeft <= 7 ? const Color(0xFFE8445A) : const Color(0xFF7C5CFC))),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Type buttons at bottom ─────────────────────
            Wrap(
              spacing: 6, runSpacing: 6,
              alignment: WrapAlignment.center,
              children: _types.map((t) {
                final selected = _type == t;
                final tc = _typeColor(t);
                return ActionChip(
                  label: Text(t, style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : tc)),
                  onPressed: () {
                    setState(() => _type = t);
                    if (!_isNew) _save();
                  },
                  backgroundColor: selected ? tc : Colors.white,
                  side: BorderSide(color: tc.withAlpha(selected ? 0 : 80)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Compact date icon ──────────────────────────────────────
class _DateIcon extends StatelessWidget {
  final bool isStart;
  final DateTime? date;
  final Color color;
  final VoidCallback onTap;
  const _DateIcon({required this.isStart, required this.date,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isStart ? Icons.play_circle_outline : Icons.flag_circle_outlined,
              size: 14, color: date != null ? color : const Color(0xFFB0B0C0)),
          const SizedBox(width: 1),
          Text(date != null ? '${date!.month}/${date!.day}' : (isStart ? 'Start' : 'End'),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: date != null ? const Color(0xFF1A1A2E) : const Color(0xFFB0B0C0))),
        ],
      ),
    ),
  );
}
