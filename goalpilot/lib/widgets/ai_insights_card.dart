import 'package:flutter/material.dart';
import '../services/goal_analyzer.dart';
import '../theme/app_theme.dart';

class AiInsightsCard extends StatelessWidget {
  final GoalAnalysis analysis;
  final String unit;

  const AiInsightsCard({super.key, required this.analysis, required this.unit});

  @override
  Widget build(BuildContext context) {
    final gradient = analysis.isAhead ? AppTheme.aheadGradient : AppTheme.behindGradient;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient.colors.first.withAlpha(40),
            gradient.colors.last.withAlpha(20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradient.colors.first.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: gradient.colors.first, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  color: gradient.colors.first,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            analysis.summary,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _chip('🔥 Streak', '${analysis.currentStreak} days'),
              _chip('💪 Best day', analysis.strongestDay),
              _chip('🎯 Target', '${analysis.suggestedDailyTarget.toStringAsFixed(1)} $unit/day'),
              _chip('📈 Momentum', '${analysis.momentumScore.toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$label: $value',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      );
}
