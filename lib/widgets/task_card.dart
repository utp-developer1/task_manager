import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_state.dart';
import '../screens/task_detail_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showEditDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(task.title, style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.status.name.toUpperCase(),
                      style: TextStyle(color: task.statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(task.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                   const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                   const SizedBox(width: 4),
                   Text(DateFormat('MMM dd').format(task.dueDate), style: Theme.of(context).textTheme.bodySmall),
                   const Spacer(),
                   
                   // Quick Time Tracking
                   IconButton(
                     icon: Icon(task.isTracking ? Icons.stop_circle : Icons.play_circle, color: task.isTracking ? Colors.red : Colors.green),
                     onPressed: () {
                        // Prevent opening detail screen
                        context.read<AppState>().toggleTimeTracking(task.id);
                     },
                     tooltip: task.isTracking ? 'Stop Timer' : 'Start Timer',
                     constraints: const BoxConstraints(),
                     padding: EdgeInsets.zero,
                   ),
                   const SizedBox(width: 12),
                   
                   const Icon(Icons.person, size: 14, color: Colors.grey),
                   const SizedBox(width: 4),
                   Text('Assigned', style: Theme.of(context).textTheme.bodySmall), 
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: task.progress,
                backgroundColor: Colors.grey[800],
                color: task.statusColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // Navigate to Full Detail Screen
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)));
  }
}

class _EditTaskDialog extends StatefulWidget {
  final Task task;
  const _EditTaskDialog({required this.task});

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late TaskStatus _status;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
    _progress = widget.task.progress;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update ${widget.task.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<TaskStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 24),
            Text('Progress: ${(_progress * 100).toInt()}%'),
            Slider(
              value: _progress,
              min: 0, 
              max: 1, 
              divisions: 10,
              onChanged: (v) => setState(() => _progress = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
             Provider.of<AppState>(context, listen: false).updateTaskStatus(widget.task.id, _status, _progress);
             Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
