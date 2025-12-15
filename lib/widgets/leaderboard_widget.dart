import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/user.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final topUsers = appState.topPerformers;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leaderboard 🏆', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (topUsers.isEmpty) const Text('No stats yet!'),
            ...List.generate(topUsers.length, (index) {
              final user = topUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(index),
                  child: Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                title: Text(user.name),
                trailing: Text('${user.tasksCompleted} Tasks', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey;
    if (index == 2) return Colors.brown;
    return Colors.blueGrey;
  }
}
