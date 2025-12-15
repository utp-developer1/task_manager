import 'package:flutter/material.dart';

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Notifications
    final notifications = [
      {'title': 'Task Assigned', 'body': 'Alice assigned you "Q1 Report"', 'time': '2 mins ago'},
      {'title': 'Comment Added', 'body': 'Bob commented on "Fix Bug #102"', 'time': '1 hour ago'},
      {'title': 'Deadline Warning', 'body': '"Update Website" is due in 3 hours', 'time': '3 hours ago'},
    ];

    return PopupMenuButton(
      icon: const Icon(Icons.notifications),
      tooltip: 'Notifications',
      itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
        const PopupMenuItem(
          enabled: false,
          child: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...notifications.map((n) => PopupMenuItem(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
            title: Text(n['title']!),
            subtitle: Text(n['body']!),
            trailing: Text(n['time']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            dense: true,
          ),
        )),
        const PopupMenuDivider(),
        const PopupMenuItem(
          child: Center(child: Text('View All', style: TextStyle(color: Colors.blue))),
        )
      ],
    );
  }
}
