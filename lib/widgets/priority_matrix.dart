import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/task.dart';

class PriorityMatrix extends StatelessWidget {
  const PriorityMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tasks = appState.allTasks.where((t) => t.status != TaskStatus.done).toList();

    // Quadrants
    final q1 = tasks.where((t) => t.isUrgent && t.isImportant).toList();
    final q2 = tasks.where((t) => !t.isUrgent && t.isImportant).toList();
    final q3 = tasks.where((t) => t.isUrgent && !t.isImportant).toList();
    final q4 = tasks.where((t) => !t.isUrgent && !t.isImportant).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Eisenhower Matrix', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _Quadrant(title: 'Do First\n(Urgent & Important)', tasks: q1, color: Colors.redAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _Quadrant(title: 'Schedule\n(Important, Not Urgent)', tasks: q2, color: Colors.blueAccent)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _Quadrant(title: 'Delegate\n(Urgent, Not Important)', tasks: q3, color: Colors.orangeAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _Quadrant(title: 'Don\'t Do\n(Not Urgent, Not Important)', tasks: q4, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Quadrant extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final Color color;
  const _Quadrant({required this.title, required this.tasks, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) => Text(
                '• ${tasks[index].title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          )
        ],
      ),
    );
  }
}

extension TaskPriorityExtension on Task {
  bool get isImportant => priority == TaskPriority.high;
  bool get isUrgent => dueDate.difference(DateTime.now()).inDays <= 2;
}
