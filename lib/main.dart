import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/dashboard_screen.dart'; // We will create this next
import 'screens/login_screen.dart'; // And this

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Task Manager',
            debugShowCheckedModeBanner: false,
            // Use predefined themes but allow toggling
            theme: AppTheme.lightTheme, 
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode, 
            home: const LoginScreen(),
          );
        }
      ),
    );
  }
}
