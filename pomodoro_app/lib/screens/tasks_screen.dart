import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/timer_provider.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Tasks'),
        titleWidth: 150,
        actions: [
          ToolBarIconButton(
            label: 'Add Task',
            icon: const MacosIcon(CupertinoIcons.add),
            onPressed: () => _showAddTaskDialog(context),
            showLabel: false,
          ),
          ToolBarIconButton(
            label: 'Clear Completed',
            icon: const MacosIcon(CupertinoIcons.trash),
            onPressed: () {
              context.read<TaskProvider>().clearCompletedTasks();
            },
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Column(
              children: [
                _TaskFilters(),
                Expanded(
                  child: _TaskList(scrollController: scrollController),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showMacosSheet(
      context: context,
      builder: (context) => const _AddTaskSheet(),
    );
  }
}

class _TaskFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MacosTheme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          MacosCheckbox(
            value: tasks.showCompleted,
            onChanged: (value) {
              tasks.setShowCompleted(value ?? false);
            },
          ),
          const SizedBox(width: 8),
          const Text('Show completed'),
          const Spacer(),
          Text(
            '${tasks.activeTasks.length} active, ${tasks.completedTasks.length} completed',
            style: TextStyle(
              fontSize: 12,
              color: MacosTheme.of(context).typography.caption1.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final ScrollController scrollController;

  const _TaskList({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    final filteredTasks = tasks.filteredTasks;

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎯',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 18,
                color: MacosTheme.of(context).typography.headline.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a task to get started!',
              style: TextStyle(
                color: MacosTheme.of(context).typography.caption1.color,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return _TaskCard(task: filteredTasks[index]);
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final tasks = context.read<TaskProvider>();
    final timer = context.read<TimerProvider>();
    final isSelected = timer.currentTaskId == task.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? MacosTheme.of(context).primaryColor.withValues(alpha: 0.1)
            : MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected 
              ? MacosTheme.of(context).primaryColor 
              : MacosTheme.of(context).dividerColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            timer.setCurrentTask(isSelected ? null : task.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                MacosCheckbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    if (value == true && !task.isCompleted) {
                      tasks.completeTask(task.id);
                    }
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: task.isCompleted 
                              ? MacosTheme.of(context).typography.caption1.color
                              : null,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            task.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: MacosTheme.of(context).typography.caption1.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _PriorityBadge(priority: task.priority),
                const SizedBox(width: 8),
                _PomodoroProgress(task: task),
                const SizedBox(width: 8),
                MacosIconButton(
                  icon: const MacosIcon(
                    CupertinoIcons.ellipsis,
                    size: 16,
                  ),
                  onPressed: () => _showTaskOptions(context, task),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskOptions(BuildContext context, Task task) {
    showMacosSheet(
      context: context,
      builder: (context) => _EditTaskSheet(task: task),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final int priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    
    switch (priority) {
      case 1:
        color = const Color(0xFFFF6B6B);
        label = 'High';
        break;
      case 2:
        color = const Color(0xFFFFBE0B);
        label = 'Medium';
        break;
      default:
        color = const Color(0xFF4ECDC4);
        label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PomodoroProgress extends StatelessWidget {
  final Task task;

  const _PomodoroProgress({required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🍅', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          '${task.completedPomodoros}/${task.estimatedPomodoros}',
          style: TextStyle(
            fontSize: 12,
            color: MacosTheme.of(context).typography.caption1.color,
          ),
        ),
      ],
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _estimatedPomodoros = 1;
  int _priority = 2;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosSheet(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            MacosTextField(
              controller: _titleController,
              placeholder: 'Task title',
              autofocus: true,
            ),
            const SizedBox(height: 16),
            MacosTextField(
              controller: _descriptionController,
              placeholder: 'Description (optional)',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Estimated Pomodoros: '),
                const Spacer(),
                MacosIconButton(
                  icon: const MacosIcon(CupertinoIcons.minus),
                  onPressed: _estimatedPomodoros > 1
                      ? () => setState(() => _estimatedPomodoros--)
                      : null,
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '$_estimatedPomodoros',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                MacosIconButton(
                  icon: const MacosIcon(CupertinoIcons.plus),
                  onPressed: _estimatedPomodoros < 10
                      ? () => setState(() => _estimatedPomodoros++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Priority: '),
                const Spacer(),
                _PrioritySelector(
                  value: _priority,
                  onChanged: (value) => setState(() => _priority = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PushButton(
                  controlSize: ControlSize.large,
                  secondary: true,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                PushButton(
                  controlSize: ControlSize.large,
                  onPressed: _addTask,
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTask() {
    if (_titleController.text.isEmpty) return;

    final task = Task(
      title: _titleController.text,
      description: _descriptionController.text.isEmpty 
          ? null 
          : _descriptionController.text,
      estimatedPomodoros: _estimatedPomodoros,
      priority: _priority,
    );

    context.read<TaskProvider>().addTask(task);
    Navigator.of(context).pop();
  }
}

class _PrioritySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _PrioritySelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PriorityOption(
          label: 'High',
          color: const Color(0xFFFF6B6B),
          isSelected: value == 1,
          onTap: () => onChanged(1),
        ),
        const SizedBox(width: 4),
        _PriorityOption(
          label: 'Medium',
          color: const Color(0xFFFFBE0B),
          isSelected: value == 2,
          onTap: () => onChanged(2),
        ),
        const SizedBox(width: 4),
        _PriorityOption(
          label: 'Low',
          color: const Color(0xFF4ECDC4),
          isSelected: value == 3,
          onTap: () => onChanged(3),
        ),
      ],
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EditTaskSheet extends StatefulWidget {
  final Task task;

  const _EditTaskSheet({required this.task});

  @override
  State<_EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<_EditTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _estimatedPomodoros;
  late int _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _estimatedPomodoros = widget.task.estimatedPomodoros;
    _priority = widget.task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacosSheet(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            MacosTextField(
              controller: _titleController,
              placeholder: 'Task title',
            ),
            const SizedBox(height: 16),
            MacosTextField(
              controller: _descriptionController,
              placeholder: 'Description (optional)',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Estimated Pomodoros: '),
                const Spacer(),
                MacosIconButton(
                  icon: const MacosIcon(CupertinoIcons.minus),
                  onPressed: _estimatedPomodoros > 1
                      ? () => setState(() => _estimatedPomodoros--)
                      : null,
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '$_estimatedPomodoros',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                MacosIconButton(
                  icon: const MacosIcon(CupertinoIcons.plus),
                  onPressed: _estimatedPomodoros < 10
                      ? () => setState(() => _estimatedPomodoros++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PushButton(
                  controlSize: ControlSize.large,
                  color: const Color(0xFFFF6B6B),
                  onPressed: () {
                    context.read<TaskProvider>().deleteTask(widget.task.id);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete'),
                ),
                Row(
                  children: [
                    PushButton(
                      controlSize: ControlSize.large,
                      secondary: true,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    PushButton(
                      controlSize: ControlSize.large,
                      onPressed: _saveTask,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) return;

    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descriptionController.text.isEmpty 
          ? null 
          : _descriptionController.text,
      estimatedPomodoros: _estimatedPomodoros,
      priority: _priority,
    );

    context.read<TaskProvider>().updateTask(updatedTask);
    Navigator.of(context).pop();
  }
}
