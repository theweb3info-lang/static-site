import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/goal_card.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GoalProvider>().loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoalPilot'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.rocket_launch, color: Color(0xFF00b4d8)),
          ),
        ],
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text(
                    'No goals yet',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to set your first goal',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: provider.goals.length,
            itemBuilder: (context, i) => GoalCard(
              goal: provider.goals[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GoalDetailScreen(goalId: provider.goals[i].id),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddGoalScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
