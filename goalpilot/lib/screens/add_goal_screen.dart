import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/goal_provider.dart';
import '../theme/app_theme.dart';

class AddGoalScreen extends StatefulWidget {
  final Goal? existingGoal;
  const AddGoalScreen({super.key, this.existingGoal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _unitCtrl;
  GoalType _type = GoalType.numeric;
  DateTime _startDate = DateTime.now();
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  Color _color = AppTheme.goalColors[0];

  bool get _isEdit => widget.existingGoal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existingGoal;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _targetCtrl = TextEditingController(text: g != null ? g.targetValue.toString() : '');
    _unitCtrl = TextEditingController(text: g?.unit ?? '');
    if (g != null) {
      _type = g.type;
      _startDate = g.startDate;
      _deadline = g.deadline;
      _color = g.color;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => isStart ? _startDate = picked : _deadline = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final goal = Goal(
      id: widget.existingGoal?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      type: _type,
      targetValue: double.parse(_targetCtrl.text),
      unit: _unitCtrl.text.trim(),
      startDate: _startDate,
      deadline: _deadline,
      color: _color,
      entries: widget.existingGoal?.entries,
    );
    final provider = context.read<GoalProvider>();
    final nav = Navigator.of(context);
    (_isEdit ? provider.updateGoal(goal) : provider.addGoal(goal)).then((_) => nav.pop());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Goal' : 'New Goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal name'),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            // Goal type
            const Text('Type', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            SegmentedButton<GoalType>(
              segments: const [
                ButtonSegment(value: GoalType.numeric, label: Text('Numeric')),
                ButtonSegment(value: GoalType.count, label: Text('Count')),
                ButtonSegment(value: GoalType.habit, label: Text('Habit')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetCtrl,
                    decoration: const InputDecoration(labelText: 'Target value'),
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Enter a number' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(labelText: 'Unit (e.g. km)'),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _dateTile('Start', _startDate, () => _pickDate(true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateTile('Deadline', _deadline, () => _pickDate(false)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Color', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: AppTheme.goalColors.map((c) => GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: _color == c
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                      ),
                    ),
                  )).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isEdit ? 'Update Goal' : 'Create Goal',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTile(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
