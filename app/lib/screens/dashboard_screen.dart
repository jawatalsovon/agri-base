import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../widgets/sections/historical_data_section.dart' as hist;
import '../widgets/sections/prediction_section.dart' as pred;
import '../providers/localization_provider.dart';
import '../utils/translations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final locale = localizationProvider.locale;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          Translations.translate(locale, 'dashboard'),
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          tabs: [
            Tab(text: Translations.translate(locale, 'historicalData')),
            Tab(text: Translations.translate(locale, 'prediction')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSectionWithGlassmorphism(context, const hist.HistoricalDataSection()),
          _buildSectionWithGlassmorphism(context, const pred.PredictionSection()),
        ],
      ),
    );
  }

  Widget _buildSectionWithGlassmorphism(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(padding: const EdgeInsets.all(16), child: child),
            ),
          ),
        ),
      ),
    );
  }
}
