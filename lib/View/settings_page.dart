import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movieapplication/core/theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : themeProvider.isLightMode
                      ? Icons.light_mode
                      : Icons.brightness_auto,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Theme'),
                subtitle: Text(
                  themeProvider.isDarkMode
                      ? 'Dark Mode'
                      : themeProvider.isLightMode
                      ? 'Light Mode'
                      : 'System Default',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showThemeDialog(context, themeProvider),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('About'),
                subtitle: const Text('App version and information'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Navigate to about page
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light Mode'),
                subtitle: const Text('Use light theme'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                subtitle: const Text('Follow system theme'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
