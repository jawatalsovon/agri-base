import 'package:flutter/material.dart';
import '../widgets/sections/historical_data_section.dart' as hist;
import '../widgets/sections/prediction_section.dart' as pred;
import 'analytics_screen.dart';
import 'explorer_screen.dart';
import 'my_region_screen.dart';

class AgriBaseHomeScreen extends StatefulWidget {
  const AgriBaseHomeScreen({super.key});

  @override
  State<AgriBaseHomeScreen> createState() => _AgriBaseHomeScreenState();
}

class _AgriBaseHomeScreenState extends State<AgriBaseHomeScreen> {
  int _selectedNavIndex = 0; // Dashboard is selected

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    
    switch (_selectedNavIndex) {
      case 0:
        currentScreen = const DashboardScreen();
        break;
      case 1:
        currentScreen = const AnalyticsScreen();
        break;
      case 2:
        currentScreen = const ExplorerScreen();
        break;
      case 3:
        currentScreen = const MyRegionScreen();
        break;
      default:
        currentScreen = const DashboardScreen();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 77, 64),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'AgriBase',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: currentScreen,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 0, 77, 64),
        onPressed: () {},
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        label: const Text(
          'Ask AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 0, 77, 64),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explorer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'My Region',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedSectionIndex = 0; // 0: Historical, 1: Prediction

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Section Tabs
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSectionIndex = 0;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'Historical Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedSectionIndex == 0 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedSectionIndex == 0
                                  ? const Color.fromARGB(255, 0, 77, 64)
                                  : Colors.grey,
                            ),
                          ),
                          if (_selectedSectionIndex == 0)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              height: 3,
                              color: const Color.fromARGB(255, 0, 77, 64),
                            ),
                          if (_selectedSectionIndex != 0)
                            const SizedBox(height: 11),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSectionIndex = 1;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'Prediction (AI/ML)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedSectionIndex == 1 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedSectionIndex == 1
                                  ? const Color.fromARGB(255, 0, 77, 64)
                                  : Colors.grey,
                            ),
                          ),
                          if (_selectedSectionIndex == 1)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              height: 3,
                              color: const Color.fromARGB(255, 0, 77, 64),
                            ),
                          if (_selectedSectionIndex != 1)
                            const SizedBox(height: 11),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Content based on selected section
          if (_selectedSectionIndex == 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: hist.HistoricalDataSection(),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: pred.PredictionSection(),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
