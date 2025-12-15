import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/user.dart';
import 'manager_dashboard.dart'; 
import 'employee_dashboard.dart';
import '../screens/calendar_screen.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    // Simple Navigation Logic
    if (appState.activeTab == 1) {
      return const CalendarScreen();
    }
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: appState.currentUser.role == UserRole.superior 
        ? const ManagerDashboard() 
        : const EmployeeDashboard(),
    );
  }
}
