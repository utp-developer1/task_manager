import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

import '../widgets/sidebar.dart'; // We need to create this
import '../widgets/dashboard_content.dart'; // And this

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        
        return Scaffold(
          appBar: !isDesktop ? AppBar(
            title: const Text('Dashboard'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ) : null, // No AppBar on desktop, use Sidebar
          drawer: !isDesktop ? const Drawer(child: Sidebar()) : null,
          body: Row(
            children: [
              if (isDesktop)
                const SizedBox(
                  width: 250,
                  child: Sidebar(),
                ),
              Expanded(
                child: Center(child: DashboardContent()),
              ),
            ],
          ),
        );
      },
    );
  }
}
