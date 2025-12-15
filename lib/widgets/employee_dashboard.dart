import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'task_card.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final myTasks = appState.myTasks;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          
          // Summary Cards
          Row(
            children: [
              _SummaryCard(title: 'Pending', count: myTasks.length, color: Colors.blue),
              const SizedBox(width: 16),
              // We could add more here
            ],
          ),
          
          const SizedBox(height: 32),
          Text('My Tasks', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          
          if (myTasks.isEmpty)
             const Text('No tasks assigned yay!'),
            
          ...myTasks.map((task) => TaskCard(task: task)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SummaryCard({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$count', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: color)),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
