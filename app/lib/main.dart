import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/database_test_service.dart';
import 'providers/theme_provider.dart';
import 'providers/localization_provider.dart';
import 'providers/font_size_provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ],
      child: Consumer3<ThemeProvider, LocalizationProvider, FontSizeProvider>(
        builder:
            (
              context,
              themeProvider,
              localizationProvider,
              fontSizeProvider,
              child,
            ) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'AgriBase',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF2E7D32),
                  ),
                  useMaterial3: true,
                  textTheme: ThemeData.light().textTheme.copyWith(
                    bodyLarge: TextStyle(fontSize: fontSizeProvider.fontSize),
                    bodyMedium: TextStyle(fontSize: fontSizeProvider.fontSize),
                    bodySmall: TextStyle(
                      fontSize: fontSizeProvider.fontSize - 2,
                    ),
                    headlineLarge: TextStyle(
                      fontSize: fontSizeProvider.fontSize + 4,
                    ),
                    headlineMedium: TextStyle(
                      fontSize: fontSizeProvider.fontSize + 2,
                    ),
                    headlineSmall: TextStyle(
                      fontSize: fontSizeProvider.fontSize,
                    ),
                    titleLarge: TextStyle(
                      fontSize: fontSizeProvider.fontSize + 2,
                    ),
                    titleMedium: TextStyle(fontSize: fontSizeProvider.fontSize),
                    titleSmall: TextStyle(
                      fontSize: fontSizeProvider.fontSize - 2,
                    ),
                    labelLarge: TextStyle(fontSize: fontSizeProvider.fontSize),
                    labelMedium: TextStyle(
                      fontSize: fontSizeProvider.fontSize - 1,
                    ),
                    labelSmall: TextStyle(
                      fontSize: fontSizeProvider.fontSize - 2,
                    ),
                  ),
                ),
                darkTheme: ThemeData.dark().copyWith(
                  primaryColor: const Color.fromARGB(255, 0, 77, 64),
                  colorScheme: const ColorScheme.dark(
                    primary: Color.fromARGB(255, 0, 77, 64),
                    secondary: Color.fromARGB(255, 76, 175, 80),
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  ),
                  textTheme: ThemeData.dark().textTheme
                      .apply(
                        bodyColor: Colors.white,
                        displayColor: Colors.white,
                      )
                      .copyWith(
                        bodyLarge: TextStyle(
                          fontSize: fontSizeProvider.fontSize,
                          color: Colors.white,
                        ),
                        bodyMedium: TextStyle(
                          fontSize: fontSizeProvider.fontSize,
                          color: Colors.white,
                        ),
                        bodySmall: TextStyle(
                          fontSize: fontSizeProvider.fontSize - 2,
                          color: Colors.white,
                        ),
                        headlineLarge: TextStyle(
                          fontSize: fontSizeProvider.fontSize + 4,
                          color: Colors.white,
                        ),
                        headlineMedium: TextStyle(
                          fontSize: fontSizeProvider.fontSize + 2,
                          color: Colors.white,
                        ),
                        headlineSmall: TextStyle(
                          fontSize: fontSizeProvider.fontSize,
                          color: Colors.white,
                        ),
                        titleLarge: TextStyle(
                          fontSize: fontSizeProvider.fontSize + 2,
                          color: Colors.white,
                        ),
                        titleMedium: TextStyle(
                          fontSize: fontSizeProvider.fontSize,
                          color: Colors.white,
                        ),
                        titleSmall: TextStyle(
                          fontSize: fontSizeProvider.fontSize - 2,
                          color: Colors.white,
                        ),
                        labelLarge: TextStyle(
                          fontSize: fontSizeProvider.fontSize,
                          color: Colors.white,
                        ),
                        labelMedium: TextStyle(
                          fontSize: fontSizeProvider.fontSize - 1,
                          color: Colors.white,
                        ),
                        labelSmall: TextStyle(
                          fontSize: fontSizeProvider.fontSize - 2,
                          color: Colors.white,
                        ),
                      ),
                  cardColor: const Color(0xFF2A2A2A),
                  scaffoldBackgroundColor: const Color(0xFF121212),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color.fromARGB(255, 0, 77, 64),
                    foregroundColor: Colors.white,
                  ),
                ),
                themeMode: themeProvider.themeMode,
                home: const AgriBaseHomeScreen(),
              );
            },
      ),
    );
  }
}
