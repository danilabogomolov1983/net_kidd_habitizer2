import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final class HabitForm extends StatefulWidget {
  final void Function(String id, String type, String name) onSubmit;
  final String? initialName;
  final String? initialType;
  final String? editId; // non-null → edit mode, used instead of generating a new id

  const HabitForm({
    super.key,
    required this.onSubmit,
    this.initialName,
    this.initialType,
    this.editId,
  });

  bool get isEditing => editId != null;

  @override
  State<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends State<HabitForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _uuid = const Uuid();

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
    _nameCtrl.text = widget.initialName ?? '';
    _typeCtrl.text = widget.initialType ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        widget.editId ?? _uuid.v4(),
        _typeCtrl.text.trim(),
        _nameCtrl.text.trim(),
      );
    }
  }

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
            Text(widget.isEditing ? 'Edit Habit' : 'New Habit',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Habit name',
                hintText: 'e.g. Morning workout',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _typeCtrl,
              decoration: const InputDecoration(
                labelText: 'Type',
                hintText: 'e.g. daily, weekly, counter',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Type is required' : null,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularTypes.map((t) {
                return ActionChip(
                  label: Text(t),
                  onPressed: () {
                    _typeCtrl.text = t;
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.isEditing ? 'Save Changes' : 'Create Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
