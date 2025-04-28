import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Add this import for kDebugMode
import 'utils/performance_monitor.dart';

import 'screens/get_started_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize performance monitor
  PerformanceMonitor.initPerformanceImprovements();
  
  // Start performance monitoring in debug mode
  if (kDebugMode) {
    PerformanceMonitor.startMonitoring();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinSetu App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8FA7A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        platform: TargetPlatform.android,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStartedScreen(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
