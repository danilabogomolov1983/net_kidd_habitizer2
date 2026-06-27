import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit_parameter.dart';

final class HabitParameterForm extends StatefulWidget {
  final String habitId;
  final void Function({
    required String id,
    required String habitId,
    DateTime? startDate,
    DateTime? endDate,
    required double value,
    required String measureUnit,
  }) onSubmit;
  final HabitParameter? existingParameter;

  const HabitParameterForm({
    super.key,
    required this.habitId,
    required this.onSubmit,
    this.existingParameter,
  });

  bool get isEditing => existingParameter != null;

  @override
  State<HabitParameterForm> createState() => _HabitParameterFormState();
}

class _HabitParameterFormState extends State<HabitParameterForm> {
  final _formKey = GlobalKey<FormState>();
  final _valueCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final _uuid = const Uuid();

  static const _popularUnits = [
    'minutes',
    'hours',
    'kg',
    'km',
    'reps',
    'sets',
    'pages',
    'glasses',
    'steps',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingParameter;
    if (p != null) {
      _valueCtrl.text = p.value == p.value.truncateToDouble()
          ? p.value.toInt().toString()
          : p.value.toString();
      _unitCtrl.text = p.measureUnit;
      _startDate = p.startDate;
      _endDate = p.endDate;
    }
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        id: widget.existingParameter?.id ?? _uuid.v4(),
        habitId: widget.habitId,
        startDate: _startDate,
        endDate: _endDate,
        value: double.parse(_valueCtrl.text.trim()),
        measureUnit: _unitCtrl.text.trim(),
      );
    }
  }

  String _formatDate(DateTime? dt) =>
      dt != null
          ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'
          : 'Not set';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.isEditing ? 'Edit Parameter' : 'Add Parameter',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueCtrl,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'e.g. 30',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Value is required';
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _unitCtrl,
              decoration: const InputDecoration(
                labelText: 'Measure unit',
                hintText: 'e.g. minutes, kg, reps',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Unit is required' : null,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularUnits.map((u) {
                return ActionChip(
                  label: Text(u),
                  onPressed: () {
                    _unitCtrl.text = u;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(true),
                    child: Text('Start: ${_formatDate(_startDate)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(false),
                    child: Text('End: ${_formatDate(_endDate)}'),
                  ),
                ),
              ],
            ),
            if (_startDate != null || _endDate != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() {
                  _startDate = null;
                  _endDate = null;
                }),
                child: const Text('Clear dates'),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.isEditing ? 'Save Changes' : 'Add Parameter'),
            ),
          ],
        ),
      ),
    );
  }
}
