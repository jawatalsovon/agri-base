import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Assuming providers are set up
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/font_size_provider.dart';
import '../providers/auth_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 0, 77, 64),
      ),
      body: ListView(
        children: [
          // Theme Switching
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          const Divider(),
          // Localization
          ListTile(
            title: const Text('Language'),
            subtitle: Text(localizationProvider.language),
            trailing: DropdownButton<String>(
              value: localizationProvider.language,
              items: ['English', 'Bangla'].map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  localizationProvider.setLanguage(value);
                }
              },
            ),
          ),
          const Divider(),
          // Font Size
          const Text(
            'Font Size',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Consumer<FontSizeProvider>(
            builder: (context, fontSizeProvider, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      fontSizeProvider.setFontSize(12.0);
                    },
                    child: const Text('Small'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      fontSizeProvider.setFontSize(14.0);
                    },
                    child: const Text('Default'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      fontSizeProvider.setFontSize(16.0);
                    },
                    child: const Text('Large'),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          // Other Options
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),
          ListTile(
            title: const Text('About Us'),
            onTap: () {
              // Navigate to About Us
            },
          ),
          // Show Login button if user is in guest mode (not authenticated)
          if (!isAuthenticated) ...[
            const Divider(),
            ListTile(
              title: const Text('Login'),
              leading: const Icon(Icons.login),
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
            const Divider(),
            ListTile(
              title: const Text('Log Out'),
              leading: const Icon(Icons.logout),
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
