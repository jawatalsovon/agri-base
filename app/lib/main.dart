import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/database_test_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database factory for desktop platforms
  await DatabaseService.initializeDatabaseFactory();
  
  // Initialize database service
  await DatabaseService.instance.initialize();
  
  // Run database test
  print('\n\n=== RUNNING DATABASE TEST ===');
  final testService = DatabaseTestService();
  await testService.testDatabase();
  print('=== DATABASE TEST COMPLETE ===\n\n');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriBase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const AgriBaseHomeScreen(),
    );
  }
}
