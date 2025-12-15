import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state.dart';
import '../models/task.dart';
import 'task_card.dart';
import 'add_task_dialog.dart';
import 'priority_matrix.dart';
import 'leaderboard_widget.dart';
import 'task_filters.dart';
import 'notification_center.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allTasks = appState.allTasks; // Still use all tasks for charts
    final filteredTasks = appState.filteredTasks; // Use filtered for list
    
    // ... Calculations
    final doneCount = allTasks.where((t) => t.status == TaskStatus.done).length;
    final inProgressCount = allTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final pendingCount = allTasks.where((t) => t.status == TaskStatus.pending).length;
    final reviewCount = allTasks.where((t) => t.status == TaskStatus.review).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddTaskDialog());
        },
        label: const Text('New Task'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Team Overview', style: Theme.of(context).textTheme.headlineMedium),
                Row(
                  children: [
                    const NotificationCenter(),
                    IconButton(
                      icon: const Icon(Icons.download), 
                      onPressed: () async {
                        await context.read<AppState>().generateCsvReport();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report generated (check console)')));
                        }
                      },
                      tooltip: 'Export Report',
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),
            
            // Chart Section
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(color: Colors.green, value: doneCount.toDouble(), title: '$doneCount', radius: 50),
                          PieChartSectionData(color: Colors.blue, value: inProgressCount.toDouble(), title: '$inProgressCount', radius: 50),
                          PieChartSectionData(color: Colors.orange, value: pendingCount.toDouble(), title: '$pendingCount', radius: 50),
                          PieChartSectionData(color: Colors.purple, value: reviewCount.toDouble(), title: '$reviewCount', radius: 50),
                        ],
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendItem(color: Colors.green, label: 'Done'),
                        _LegendItem(color: Colors.blue, label: 'In Progress'),
                        _LegendItem(color: Colors.purple, label: 'Review'),
                        _LegendItem(color: Colors.orange, label: 'Pending'),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const PriorityMatrix(),
            const SizedBox(height: 32),
            const LeaderboardWidget(),
            const SizedBox(height: 32),
            
            Text('All Tasks', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const TaskFilters(),
            const SizedBox(height: 16),
            
            if (filteredTasks.isEmpty) 
               const Center(child: Padding(padding: EdgeInsets.all(32), child: Text("No tasks match your filters"))),

            ...filteredTasks.map((task) => TaskCard(task: task)),
            
            // Add extra padding at bottom for FAB
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
