import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/authentication/login_screen.dart';
import 'themes/app_theme.dart';
import 'services/notifi_service.dart';

void main() async {


  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize NotificationService
  NotificationService notificationService = NotificationService();
  await notificationService.initNotification();



  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme, // Light theme
      darkTheme: AppTheme.darkTheme, // Dark theme
      themeMode: ThemeMode.light, // You can change this to ThemeMode.dark
      home: LoginScreen(), // Initial route
    );
  }
}
