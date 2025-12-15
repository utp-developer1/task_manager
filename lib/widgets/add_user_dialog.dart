import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Subordinate'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. David Intern'),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
               context.read<AppState>().addUser(_nameController.text);
               Navigator.pop(context);
               
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_nameController.text} added to team!')));
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
