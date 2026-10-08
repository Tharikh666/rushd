import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

class ThemeController extends Notifier<ThemeMode> {
  static const _storageKey = 'rushd_theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();

    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final preferences = await SharedPreferences.getInstance();

    final value = preferences.getString(_storageKey);

    if (value == null) {
      state = ThemeMode.system;
      return;
    }

    switch (value) {
      case 'light':
        state = ThemeMode.light;
        break;

      case 'dark':
        state = ThemeMode.dark;
        break;

      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_storageKey, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }
}
