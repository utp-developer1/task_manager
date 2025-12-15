import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/user.dart'; // Import user to look up names
import '../providers/app_state.dart';
import 'package:file_picker/file_picker.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final task = appState.allTasks.firstWhere((t) => t.id == widget.taskId, orElse: () => appState.allTasks.first); 
    // Handle task not found case in real app
    
    final assignee = appState.allUsers.firstWhere((u) => u.id == task.assigneeId, orElse: () => User(id: '', name: 'Unknown', role: UserRole.subordinate));

    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        actions: [
          IconButton(
            icon: Icon(task.isTracking ? Icons.stop_circle : Icons.play_circle, color: task.isTracking ? Colors.red : Colors.green),
            onPressed: () {
               context.read<AppState>().toggleTimeTracking(task.id);
            },
            tooltip: task.isTracking ? 'Stop Timer' : 'Start Timer',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Comments'),
            Tab(text: 'Files'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadge(status: task.status),
                const SizedBox(height: 16),
                Text('Description', style: Theme.of(context).textTheme.titleMedium),
                Text(task.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                _DetailRow(icon: Icons.person, label: 'Assignee', value: assignee.name),
                _DetailRow(icon: Icons.calendar_today, label: 'Due Date', value: DateFormat('MMM dd, yyyy').format(task.dueDate)),
                _DetailRow(icon: Icons.priority_high, label: 'Priority', value: task.priority.name.toUpperCase()),
                _DetailRow(icon: Icons.refresh, label: 'Recurring', value: task.recurrence.name.toUpperCase()),
                const SizedBox(height: 24),
                Text('Time Spent: ${task.totalHoursSpent.toStringAsFixed(1)} hrs', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (task.timeLogs.isNotEmpty)
                  ...task.timeLogs.reversed.take(3).map((log) => Text(
                    '${DateFormat('MM/dd HH:mm').format(log.startTime)} - ${log.endTime != null ? DateFormat('HH:mm').format(log.endTime!) : "Running..."}',
                    style: TextStyle(color: Colors.grey),
                  )),
              ],
            ),
          ),
          
          // Comments Tab
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: task.comments.length,
                  itemBuilder: (context, index) {
                    final comment = task.comments[index];
                    final author = appState.allUsers.firstWhere((u) => u.id == comment.authorId, orElse: ()=> User(id:'', name:'Unknown', role:UserRole.subordinate));
                    return ListTile(
                      leading: CircleAvatar(child: Text(author.name[0])),
                      title: Text(author.name),
                      subtitle: Text(comment.content),
                      trailing: Text(DateFormat('MM/dd HH:mm').format(comment.timestamp), style: TextStyle(fontSize: 10)),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: 'Add comment...'))),
                    IconButton(
                        icon: const Icon(Icons.send), 
                        onPressed: () {
                           if (_commentController.text.isNotEmpty) {
                             context.read<AppState>().addComment(task.id, _commentController.text);
                             _commentController.clear();
                           }
                        }
                    )
                  ],
                ),
              )
            ],
          ),

          // Files Tab
          Column(
            children: [
               Expanded(
                 child: ListView.builder(
                   itemCount: task.attachments.length,
                   itemBuilder: (context, index) => ListTile(
                     leading: const Icon(Icons.attach_file),
                     title: Text(task.attachments[index]),
                     trailing: const Icon(Icons.download),
                   ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: ElevatedButton.icon(
                   onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        context.read<AppState>().addAttachment(task.id, result.files.single.name);
                      }
                   },
                   icon: const Icon(Icons.upload_file),
                   label: const Text('Attach File'),
                 ),
               )
            ],
          ),
          
          // Activity Log Tab
          ListView.builder(
             itemCount: task.activityLogs.length,
             itemBuilder: (context, index) {
               final log = task.activityLogs[task.activityLogs.length - 1 - index]; // Reversed
               final user = appState.allUsers.firstWhere((u) => u.id == log.userId, orElse: ()=> User(id: '', name: 'System', role: UserRole.subordinate));
               return ListTile(
                 leading: const Icon(Icons.history, size: 16),
                 title: Text(log.description),
                 subtitle: Text("${user.name} • ${DateFormat('MMM dd HH:mm').format(log.timestamp)}"),
                 dense: true,
               );
             },
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Text('$label:', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});
  
  @override 
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TaskStatus.pending: color = Colors.orange; break;
      case TaskStatus.inProgress: color = Colors.blue; break;
      case TaskStatus.review: color = Colors.purple; break;
      case TaskStatus.done: color = Colors.green; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
