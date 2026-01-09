import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'farm_tools_screen.dart';
import 'home_content_screen.dart';
import 'discover_screen.dart';
import 'my_region_screen.dart';
import 'more_features_screen.dart';
import 'assistant_screen.dart';

class AgriBaseHomeScreen extends StatefulWidget {
  const AgriBaseHomeScreen({super.key});

  @override
  State<AgriBaseHomeScreen> createState() => _AgriBaseHomeScreenState();
}

class _AgriBaseHomeScreenState extends State<AgriBaseHomeScreen> {
  int _selectedNavIndex = 3; // Home is center and selected by default

  final List<Widget> _screens = [
    const DashboardScreen(), // Data
    const AnalyticsScreen(), // Analytics
    const FarmToolsScreen(), // Firm Tools
    const HomeScreen(), // Home (center prominent)
    const DiscoverScreen(), // Discover
    const MyRegionScreen(), // My Region
    const MoreFeaturesScreen(), // More Features
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
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AssistantScreen()));
        },
        icon: Icon(
          Icons.chat_bubble_outline,
          color: theme.colorScheme.onPrimary,
        ),
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
          BottomNavigationBarItem(icon: Icon(Icons.dataset), label: 'Data'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'Firm Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'My Region',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
