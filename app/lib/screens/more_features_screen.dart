import 'package:flutter/material.dart';

class MoreFeaturesScreen extends StatefulWidget {
  const MoreFeaturesScreen({super.key});

  @override
  State<MoreFeaturesScreen> createState() => _MoreFeaturesScreenState();
}

class _MoreFeaturesScreenState extends State<MoreFeaturesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Features'),
        backgroundColor: theme.colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Disaster Loss Data'),
            Tab(text: 'Farmer Wage Data'),
            Tab(text: 'Soil Data'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(
            child: Text('Under development'),
          ), // disaster loss data placeholder
          Center(
            child: Text('Under development'),
          ), // farmer wage data placeholder
          Center(child: Text('Under development')), // soil data placeholder
        ],
      ),
    );
  }
}
