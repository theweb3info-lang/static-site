import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../services/goal_provider.dart';
import '../services/goal_analyzer.dart';
import '../widgets/pace_chart.dart';
import '../widgets/ai_insights_card.dart';
import '../widgets/progress_ring.dart';

class GoalDetailScreen extends StatelessWidget {
  final String goalId;
  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        final goal = provider.goals.where((g) => g.id == goalId).firstOrNull;
        if (goal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Goal')),
            body: const Center(child: Text('Goal not found')),
          );
        }
        final analysis = GoalAnalyzer.analyze(goal);
        final daysLeft = goal.deadline.difference(DateTime.now()).inDays;

        return Scaffold(
          appBar: AppBar(
            title: Text(goal.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Goal'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await provider.deleteGoal(goalId);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress ring + stats row
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ProgressRing(
                        progress: goal.progress,
                        color: goal.color,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(1)} ${goal.unit}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          _statRow('📅 Days left', '$daysLeft'),
                          _statRow('🔥 Streak', '${analysis.currentStreak} days'),
                          _statRow('⚡ Momentum', '${analysis.momentumScore.toStringAsFixed(0)}%'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pace chart
                const Text('Pace Line', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: PaceChart(goal: goal),
                ),
                const SizedBox(height: 24),

                // AI Insights
                AiInsightsCard(analysis: analysis, unit: goal.unit),
                const SizedBox(height: 24),

                // History
                const Text('Log History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70)),
                const SizedBox(height: 8),
                if (goal.entries.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Text('No entries yet.\nTap + to log your first entry!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
                  )
                else
                  ...([...goal.entries]..sort((a, b) => b.date.compareTo(a.date))).take(20).map((e) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213e),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${e.date.month}/${e.date.day}',
                              style: const TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '+${e.value.toStringAsFixed(1)} ${goal.unit}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            if (e.note != null && e.note!.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(e.note!, style: const TextStyle(color: Colors.white38, fontSize: 13), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ],
                        ),
                      )),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showLogDialog(context, provider, goal),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showLogDialog(BuildContext context, GoalProvider provider, Goal goal) {
    final valueCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Log Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: goal.color)),
            const SizedBox(height: 16),
            TextField(
              controller: valueCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Value (${goal.unit})',
                labelStyle: const TextStyle(color: Colors.white54),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                labelStyle: TextStyle(color: Colors.white54),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: goal.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final val = double.tryParse(valueCtrl.text);
                if (val == null || val <= 0) return;
                provider.addEntry(LogEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: DateTime.now(),
                  value: val,
                  note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
                  goalId: goal.id,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
