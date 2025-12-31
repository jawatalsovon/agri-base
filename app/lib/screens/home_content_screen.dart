import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/localization_provider.dart';
import '../utils/translations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LocalizationProvider>(
      builder: (context, authProvider, localizationProvider, child) {
        final isAuthenticated = authProvider.isAuthenticated;
        final locale = localizationProvider.locale;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.colorScheme.primary,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SettingsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                  ),
                );
              },
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, color: theme.colorScheme.onPrimary, size: 24),
                const SizedBox(width: 8),
                Text(
                  "AgriBase",
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              if (isAuthenticated)
                IconButton(
                  icon: Icon(Icons.logout, color: theme.colorScheme.onPrimary),
                  onPressed: () => _showSignOutDialog(context, authProvider),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                _buildHeroSection(
                  context,
                  isAuthenticated,
                  locale,
                  authProvider,
                ),

                // Bangladeshi Farming Section
                _buildBangladeshiFarmingSection(context),

                // App Goal Section
                _buildAppGoalSection(),

                // App Overview Section
                _buildAppOverviewSection(context),

                // Contact Section
                _buildContactSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    bool isAuthenticated,
    Locale locale,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 0, 77, 64),
            Color.fromARGB(255, 76, 175, 80),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAuthenticated
                ? '${Translations.translate(locale, 'helloUser')} ${authProvider.username ?? 'User'}'
                : Translations.translate(locale, 'welcomeToAgriBase'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Translations.translate(locale, 'appDescription'),
            style: TextStyle(fontSize: 18, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 24),
          if (!isAuthenticated)
            ElevatedButton.icon(
              onPressed: () => _showAuthPrompt(context),
              icon: const Icon(Icons.login),
              label: Text(
                Translations.translate(locale, 'signInForEnhancedFeatures'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBangladeshiFarmingSection(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final locale = localizationProvider.locale;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(24.0),
          color: isDark ? theme.colorScheme.surface : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translations.translate(locale, 'bangladeshiAgriculture'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Translations.translate(locale, 'bangladeshiFarmingDescription'),
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              // Placeholder for farming images - you can add actual images later
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.agriculture,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Translations.translate(
                          locale,
                          'beautifulBangladeshiFarmland',
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              blurRadius: 4.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppGoalSection() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final locale = localizationProvider.locale;
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.fromARGB(255, 0, 77, 64),
                Color.fromARGB(255, 76, 175, 80),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.visibility, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                Translations.translate(locale, 'ourMission'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                Translations.translate(locale, 'missionStatement'),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppOverviewSection(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final locale = localizationProvider.locale;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(24.0),
          color: isDark ? theme.colorScheme.surface : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translations.translate(locale, 'whatAgribaseOffers'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              _buildOverviewCard(
                context: context,
                locale: locale,
                icon: Icons.analytics,
                titleKey: 'smartAnalytics',
                descKey: 'smartAnalyticsDesc',
              ),
              const SizedBox(height: 16),
              _buildOverviewCard(
                context: context,
                locale: locale,
                icon: Icons.map,
                titleKey: 'regionalInsights',
                descKey: 'regionalInsightsDesc',
              ),
              const SizedBox(height: 16),
              _buildOverviewCard(
                context: context,
                locale: locale,
                icon: Icons.eco,
                titleKey: 'sustainablePractices',
                descKey: 'sustainablePracticesDesc',
              ),
              const SizedBox(height: 16),
              _buildOverviewCard(
                context: context,
                locale: locale,
                icon: Icons.trending_up,
                titleKey: 'marketIntelligence',
                descKey: 'marketIntelligenceDesc',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard({
    required BuildContext context,
    required Locale locale,
    required IconData icon,
    required String titleKey,
    required String descKey,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      color: isDark ? theme.colorScheme.surfaceContainerHighest : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 32, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translations.translate(locale, titleKey),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Translations.translate(locale, descKey),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? theme.colorScheme.onSurfaceVariant
                          : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final locale = localizationProvider.locale;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        // ignore: deprecated_member_use
        return Container(
          padding: const EdgeInsets.all(24.0),
          color: isDark
              // ignore: deprecated_member_use
              ? theme.colorScheme.surfaceContainerHighest
              : const Color(0xFFF5F5F5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translations.translate(locale, 'getInTouch'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Translations.translate(locale, 'haveQuestionsNeedSupport'),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? theme.colorScheme.onSurfaceVariant
                      : const Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildContactCard(
                      context: context,
                      locale: locale,
                      icon: Icons.email,
                      titleKey: 'emailSupport',
                      subtitle: 'shafin2954@gmail.com',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildContactCard(
                      context: context,
                      locale: locale,
                      icon: Icons.phone,
                      titleKey: 'phoneSupport',
                      subtitle: '+8801551552954',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required Locale locale,
    required IconData icon,
    required String titleKey,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? theme.colorScheme.surface : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              Translations.translate(locale, titleKey),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: subtitle));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${subtitle} copied to clipboard'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? theme.colorScheme.onSurfaceVariant
                      : const Color(0xFF9E9E9E),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuthPrompt(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final locale = localizationProvider.locale;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.translate(locale, 'signOut')),
        content: Text(Translations.translate(locale, 'areYouSureSignOut')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(Translations.translate(locale, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Translations.translate(locale, 'logOut')),
                ),
              );
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(Translations.translate(locale, 'signOut')),
          ),
        ],
      ),
    );
  }
}
