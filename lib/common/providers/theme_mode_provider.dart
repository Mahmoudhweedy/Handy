import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';

/// Provider for managing theme mode state
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Notifier for theme mode changes
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final String? savedTheme = StorageService.getSetting<String>(
        AppConstants.themeKey,
        defaultValue: 'system',
      );
      
      switch (savedTheme) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
          break;
      }
      
      log('Theme mode loaded: $savedTheme');
    } catch (e) {
      log('Failed to load theme mode: $e');
      state = ThemeMode.system;
    }
  }

  /// Set theme mode to light
  Future<void> setLightMode() async {
    await _setThemeMode(ThemeMode.light, 'light');
  }

  /// Set theme mode to dark
  Future<void> setDarkMode() async {
    await _setThemeMode(ThemeMode.dark, 'dark');
  }

  /// Set theme mode to system
  Future<void> setSystemMode() async {
    await _setThemeMode(ThemeMode.system, 'system');
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.light:
        await setDarkMode();
        break;
      case ThemeMode.dark:
        await setLightMode();
        break;
      case ThemeMode.system:
        // If system mode, check current brightness and toggle
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        if (brightness == Brightness.dark) {
          await setLightMode();
        } else {
          await setDarkMode();
        }
        break;
    }
  }

  /// Internal method to set theme mode
  Future<void> _setThemeMode(ThemeMode mode, String value) async {
    try {
      state = mode;
      await StorageService.setSetting(AppConstants.themeKey, value);
      log('Theme mode set to: $value');
    } catch (e) {
      log('Failed to set theme mode: $e');
      // Revert state if storage fails
      _loadThemeMode();
    }
  }

  /// Get theme mode as string
  String get themeModeString {
    switch (state) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Check if current theme is dark
  bool get isDarkMode {
    switch (state) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
    }
  }

  /// Check if current theme is light
  bool get isLightMode {
    switch (state) {
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.light;
    }
  }

  /// Check if current theme is system
  bool get isSystemMode {
    return state == ThemeMode.system;
  }

  /// Get theme description for UI
  String get themeDescription {
    switch (state) {
      case ThemeMode.light:
        return 'Light Theme';
      case ThemeMode.dark:
        return 'Dark Theme';
      case ThemeMode.system:
        return 'System Theme';
    }
  }

  /// Reset theme to default
  Future<void> resetTheme() async {
    await setSystemMode();
  }
}
