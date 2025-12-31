import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Assuming providers are set up
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/font_size_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/translations.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;
    final theme = Theme.of(context);
    final locale = localizationProvider.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.translate(locale, 'settings')),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        children: [
          // Theme Switching
          SwitchListTile(
            title: Text(Translations.translate(locale, 'darkMode')),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          Divider(color: theme.dividerColor),
          // Localization
          ListTile(
            title: Text(Translations.translate(locale, 'language')),
            trailing: DropdownButton<String>(
              value: locale.languageCode == 'bn' ? 'bangla' : 'english',
              items: [
                DropdownMenuItem(
                  value: 'english',
                  child: Text(Translations.translate(locale, 'english')),
                ),
                DropdownMenuItem(
                  value: 'bangla',
                  child: Text(Translations.translate(locale, 'bangla')),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  localizationProvider.setLanguage(
                    value == 'bangla' ? 'Bangla' : 'English',
                  );
                }
              },
            ),
          ),
          Divider(color: theme.dividerColor),
          // Font Size
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              Translations.translate(locale, 'fontSize'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<FontSizeProvider>(
            builder: (context, fontSizeProvider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        fontSizeProvider.setFontSize(12.0);
                      },
                      child: Text(Translations.translate(locale, 'small')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        fontSizeProvider.setFontSize(14.0);
                      },
                      child: Text(Translations.translate(locale, 'default')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        fontSizeProvider.setFontSize(16.0);
                      },
                      child: Text(Translations.translate(locale, 'large')),
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(color: theme.dividerColor),
          // Other Options
          ListTile(
            title: Text(Translations.translate(locale, 'privacyPolicy')),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),
          ListTile(
            title: Text(Translations.translate(locale, 'aboutUs')),
            onTap: () {
              // Navigate to About Us
            },
          ),
          // Show Login button if user is in guest mode (not authenticated)
          if (!isAuthenticated) ...[
            Divider(color: theme.dividerColor),
            ListTile(
              title: Text(Translations.translate(locale, 'login')),
              leading: Icon(Icons.login, color: theme.colorScheme.primary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(
                      onGuestMode: () {
                        // If user chooses guest mode from login screen, just go back
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
            ),
          ],
          // Show Log Out button only if user is authenticated
          if (isAuthenticated) ...[
            Divider(color: theme.dividerColor),
            ListTile(
              title: Text(Translations.translate(locale, 'logOut')),
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              onTap: () async {
                await authProvider.signOut();
                // Navigate back to root so AuthWrapper can show login screen
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
