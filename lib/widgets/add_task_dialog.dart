import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/user.dart';
import '../models/task.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  RecurrenceInterval _recurrence = RecurrenceInterval.none;
  String? _assigneeId;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final subordinates = appState.allUsers.where((u) => u.role == UserRole.subordinate).toList();
    if (_assigneeId == null && subordinates.isNotEmpty) {
      _assigneeId = subordinates.first.id;
    }

    return AlertDialog(
      title: const Text('New Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _assigneeId,
                decoration: const InputDecoration(labelText: 'Assignee'),
                items: subordinates.map((u) => DropdownMenuItem(
                  value: u.id,
                  child: Text(u.name),
                )).toList(),
                onChanged: (v) => setState(() => _assigneeId = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurrenceInterval>(
                value: _recurrence,
                decoration: const InputDecoration(labelText: 'Repeats'),
                items: RecurrenceInterval.values.map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.name.toUpperCase()),
                )).toList(),
                onChanged: (v) => setState(() => _recurrence = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_dueDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _dueDate = date);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              appState.addTask(
                title: _titleController.text,
                description: _descController.text,
                assigneeId: _assigneeId!,
                dueDate: _dueDate,
                recurrence: _recurrence,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
