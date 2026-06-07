import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to light

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeModeName = prefs.getString('themeMode');
    if (themeModeName != null) {
      switch (themeModeName) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
      }
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    String themeModeName;
    switch (mode) {
      case ThemeMode.light:
        themeModeName = 'light';
        break;
      case ThemeMode.dark:
        themeModeName = 'dark';
        break;
      case ThemeMode.system:
        themeModeName = 'system';
        break;
    }
    await prefs.setString('themeMode', themeModeName);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system, we toggle to light for simplicity (or could check system preference)
      await setThemeMode(ThemeMode.light);
    }
  }
}