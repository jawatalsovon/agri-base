import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'home_content_screen.dart';
import 'discover_screen.dart';
import 'my_region_screen.dart';
import 'assistant_screen.dart';

class AgriBaseHomeScreen extends StatefulWidget {
  const AgriBaseHomeScreen({super.key});

  @override
  State<AgriBaseHomeScreen> createState() => _AgriBaseHomeScreenState();
}

class _AgriBaseHomeScreenState extends State<AgriBaseHomeScreen> {
  int _selectedNavIndex = 2; // Home is selected by default

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const HomeScreen(),
    const DiscoverScreen(),
    const MyRegionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(index: _selectedNavIndex, children: _screens),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AssistantScreen(),
            ),
          );
        },
        icon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.onPrimary),
        label: Text(
          'Ask AI',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'My Region',
          ),
        ],
      ),
    );
  }
}
