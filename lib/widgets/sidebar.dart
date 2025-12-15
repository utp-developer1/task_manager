import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/user.dart';
import '../screens/login_screen.dart';
import 'add_user_dialog.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;
    final isSuperior = currentUser.role == UserRole.superior;
    final activeTab = appState.activeTab;

    return Container(
      color: Theme.of(context).cardTheme.color,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text('TaskMaster', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          
          _SidebarItem(
            icon: Icons.dashboard, 
            label: 'Dashboard', 
            isActive: activeTab == 0, 
            onTap: () => appState.setActiveTab(0),
          ),
          _SidebarItem(
            icon: Icons.calendar_month, 
            label: 'Calendar', 
            isActive: activeTab == 1, 
            onTap: () => appState.setActiveTab(1),
          ),
          
          // Placeholders for now, or could map to filter presets
          if (isSuperior) ...[
             const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Divider()),
            _SidebarItem(
              icon: Icons.people, 
              label: 'Team', 
              isActive: false, 
              onTap: () {},
            ),
            _SidebarItem(
              icon: Icons.person_add, 
              label: 'Add Subordinate', 
              isActive: false, 
              onTap: () {
                showDialog(context: context, builder: (_) => const AddUserDialog());
              },
            ),
          ],
            
          const Spacer(),
          const Divider(color: Colors.white10),
          
          // Theme Toggle
          ListTile(
            leading: Icon(appState.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            title: Text(appState.themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode'),
            trailing: Switch(
              value: appState.themeMode == ThemeMode.dark, 
              onChanged: (val) => appState.toggleTheme()
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[800],
                  child: Text(currentUser.name[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(currentUser.name, 
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 20, color: Colors.redAccent),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Theme.of(context).primaryColor : Colors.grey;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: isActive ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black) : Colors.grey)),
      onTap: onTap,
    );
  }
}
