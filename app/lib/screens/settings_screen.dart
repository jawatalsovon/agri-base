import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Assuming providers are set up
import '../providers/theme_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/font_size_provider.dart';

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
          ListTile(
            title: const Text('Log Out'),
            onTap: () {
              // Handle log out
            },
          ),
        ],
      ),
    );
  }
}
