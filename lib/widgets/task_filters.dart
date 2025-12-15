import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/task.dart';

class TaskFilters extends StatelessWidget {
  const TaskFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => appState.setSearchQuery(value),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              _FilterChip(
                label: 'Overdue',
                selected: appState.isOverdueFilterActive,
                onSelected: (_) => appState.toggleOverdueFilter(),
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              ...TaskPriority.values.map((priority) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _FilterChip(
                  label: priority.name.toUpperCase(),
                  selected: appState.isPriorityFilterActive(priority),
                  onSelected: (_) => appState.togglePriorityFilter(priority),
                  color: _getPriorityColor(priority),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high: return Colors.red;
      case TaskPriority.medium: return Colors.orange;
      case TaskPriority.low: return Colors.green;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: TextStyle(color: selected ? Colors.white : color)),
      selected: selected,
      onSelected: onSelected,
      selectedColor: color,
      checkmarkColor: Colors.white,
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }
}
