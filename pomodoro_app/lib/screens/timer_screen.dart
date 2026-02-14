import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../models/pomodoro_session.dart';
import '../providers/timer_provider.dart';
import '../providers/task_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/settings_provider.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Focus Timer'),
        titleWidth: 200,
        actions: [
          ToolBarIconButton(
            label: 'Reset',
            icon: const MacosIcon(CupertinoIcons.arrow_counterclockwise),
            onPressed: () {
              context.read<TimerProvider>().reset();
            },
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: const Column(
                children: [
                  _SessionTypeSelector(),
                  SizedBox(height: 32),
                  _TimerDisplay(),
                  SizedBox(height: 32),
                  _TimerControls(),
                  SizedBox(height: 32),
                  _TaskSelector(),
                  SizedBox(height: 24),
                  _TodayProgress(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SessionTypeSelector extends StatelessWidget {
  const _SessionTypeSelector();

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SessionTypeButton(
          label: 'Focus',
          isSelected: timer.currentSessionType == SessionType.focus,
          onPressed: timer.isRunning ? null : () {
            timer.setSessionType(SessionType.focus);
          },
        ),
        const SizedBox(width: 8),
        _SessionTypeButton(
          label: 'Short Break',
          isSelected: timer.currentSessionType == SessionType.shortBreak,
          onPressed: timer.isRunning ? null : () {
            timer.setSessionType(SessionType.shortBreak);
          },
        ),
        const SizedBox(width: 8),
        _SessionTypeButton(
          label: 'Long Break',
          isSelected: timer.currentSessionType == SessionType.longBreak,
          onPressed: timer.isRunning ? null : () {
            timer.setSessionType(SessionType.longBreak);
          },
        ),
      ],
    );
  }
}

class _SessionTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;

  const _SessionTypeButton({
    required this.label,
    required this.isSelected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MacosTooltip(
      message: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? MacosTheme.of(context).primaryColor 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? MacosTheme.of(context).primaryColor 
                  : MacosTheme.of(context).dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : MacosTheme.of(context).typography.body.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay();

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(280, 280),
            painter: _TimerPainter(
              progress: timer.progress,
              sessionType: timer.currentSessionType,
              isRunning: timer.isRunning,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timer.formattedTime,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: _getColorForSession(timer.currentSessionType),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timer.sessionTypeLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: MacosTheme.of(context).typography.caption1.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '🍅 × ${timer.completedPomodoros}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForSession(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return const Color(0xFFFF6B6B);
      case SessionType.shortBreak:
        return const Color(0xFF4ECDC4);
      case SessionType.longBreak:
        return const Color(0xFF45B7D1);
    }
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final SessionType sessionType;
  final bool isRunning;

  _TimerPainter({
    required this.progress,
    required this.sessionType,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = _getColorForSession(sessionType)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    if (isRunning) {
      progressPaint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        colors: [
          _getColorForSession(sessionType),
          _getColorForSession(sessionType).withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  Color _getColorForSession(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return const Color(0xFFFF6B6B);
      case SessionType.shortBreak:
        return const Color(0xFF4ECDC4);
      case SessionType.longBreak:
        return const Color(0xFF45B7D1);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) {
    return progress != oldDelegate.progress ||
           sessionType != oldDelegate.sessionType ||
           isRunning != oldDelegate.isRunning;
  }
}

class _TimerControls extends StatelessWidget {
  const _TimerControls();

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MacosIconButton(
          icon: const MacosIcon(
            CupertinoIcons.minus_circle,
            size: 24,
          ),
          onPressed: timer.isRunning ? null : () {
            timer.subtractMinute();
          },
        ),
        const SizedBox(width: 16),
        _MainControlButton(timer: timer),
        const SizedBox(width: 16),
        MacosIconButton(
          icon: const MacosIcon(
            CupertinoIcons.plus_circle,
            size: 24,
          ),
          onPressed: timer.isRunning ? null : () {
            timer.addMinute();
          },
        ),
        const SizedBox(width: 32),
        MacosIconButton(
          icon: const MacosIcon(
            CupertinoIcons.forward_end,
            size: 24,
          ),
          onPressed: () {
            timer.skip();
          },
        ),
      ],
    );
  }
}

class _MainControlButton extends StatelessWidget {
  final TimerProvider timer;

  const _MainControlButton({required this.timer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (timer.isRunning) {
          timer.pause();
        } else {
          timer.start();
        }
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: timer.isRunning
                ? [const Color(0xFFFF8E53), const Color(0xFFFF6B6B)]
                : [const Color(0xFF4ECDC4), const Color(0xFF45B7D1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (timer.isRunning 
                  ? const Color(0xFFFF6B6B) 
                  : const Color(0xFF4ECDC4)).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          timer.isRunning 
              ? CupertinoIcons.pause_fill 
              : CupertinoIcons.play_fill,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _TaskSelector extends StatelessWidget {
  const _TaskSelector();

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    final timer = context.watch<TimerProvider>();
    
    if (tasks.activeTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MacosTheme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: MacosTheme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.list_bullet,
              size: 16,
              color: MacosTheme.of(context).typography.caption1.color,
            ),
            const SizedBox(width: 8),
            Text(
              'No active tasks',
              style: TextStyle(
                color: MacosTheme.of(context).typography.caption1.color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: MacosTheme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Working on: '),
          MacosPopupButton<String>(
            value: timer.currentTaskId,
            items: [
              const MacosPopupMenuItem(
                value: null,
                child: Text('No task selected'),
              ),
              ...tasks.activeTasks.map((task) => MacosPopupMenuItem(
                value: task.id,
                child: Text(task.title),
              )),
            ],
            onChanged: (value) {
              timer.setCurrentTask(value);
            },
          ),
        ],
      ),
    );
  }
}

class _TodayProgress extends StatelessWidget {
  const _TodayProgress();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsProvider>();
    final settings = context.watch<SettingsProvider>();
    final progress = stats.todayPomodoros / settings.dailyPomodoroGoal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MacosTheme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Progress',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${stats.todayPomodoros} / ${settings.dailyPomodoroGoal}',
                style: TextStyle(
                  color: MacosTheme.of(context).typography.caption1.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(
                progress >= 1.0 
                    ? const Color(0xFF4ECDC4) 
                    : const Color(0xFFFF6B6B),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Focus Time',
                value: stats.formatMinutes(stats.todayFocusMinutes),
                icon: CupertinoIcons.time,
              ),
              _StatItem(
                label: 'Completed',
                value: '${stats.todayCompletedTasks}',
                icon: CupertinoIcons.check_mark_circled,
              ),
              _StatItem(
                label: 'Streak',
                value: '${stats.currentStreak} days',
                icon: CupertinoIcons.flame,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: MacosTheme.of(context).primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: MacosTheme.of(context).typography.caption1.color,
          ),
        ),
      ],
    );
  }
}
