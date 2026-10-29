import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  title: const Text('System default'),
                  secondary: const Icon(Icons.brightness_auto_rounded),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setTheme(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  title: const Text('Light mode'),
                  secondary: const Icon(Icons.light_mode_outlined),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setTheme(value);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  title: const Text('Dark mode'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setTheme(value);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'More settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Notifications'),
                  subtitle: Text('Notification preferences'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.language_rounded),
                  title: Text('Language'),
                  subtitle: Text('Language preferences'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
