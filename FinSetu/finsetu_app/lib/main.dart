import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Add this import for kDebugMode
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'utils/performance_monitor.dart';

import 'screens/get_started_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_page.dart';

void main() {
  // This is for initializing the splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Initialize performance monitor
  PerformanceMonitor.initPerformanceImprovements();
  
  // Start performance monitoring in debug mode
  if (kDebugMode) {
    PerformanceMonitor.startMonitoring();
  }
  
  // When your app is initialized and ready, remove the splash screen
  FlutterNativeSplash.remove();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinSetu',
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
