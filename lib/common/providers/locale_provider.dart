import 'dart:developer';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';

/// Provider for managing locale state
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

/// Notifier for locale changes
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  /// Load locale from storage
  Future<void> _loadLocale() async {
    try {
      final String? savedLocale = StorageService.getSetting<String>(
        AppConstants.localeKey,
        defaultValue: AppConstants.defaultLocale,
      );
      
      if (savedLocale != null && AppConstants.supportedLocales.contains(savedLocale)) {
        state = Locale(savedLocale);
        log('Locale loaded: $savedLocale');
      } else {
        // Use system locale if supported, otherwise default
        final systemLocale = PlatformDispatcher.instance.locale;
        if (AppConstants.supportedLocales.contains(systemLocale.languageCode)) {
          state = systemLocale;
          await _saveLocale(systemLocale.languageCode);
        } else {
          state = const Locale(AppConstants.defaultLocale);
          await _saveLocale(AppConstants.defaultLocale);
        }
      }
    } catch (e) {
      log('Failed to load locale: $e');
      state = const Locale(AppConstants.defaultLocale);
    }
  }

  /// Set locale to English
  Future<void> setEnglish() async {
    await _setLocale('en');
  }

  /// Set locale to Arabic
  Future<void> setArabic() async {
    await _setLocale('ar');
  }

  /// Set locale by language code
  Future<void> setLocale(String languageCode) async {
    if (AppConstants.supportedLocales.contains(languageCode)) {
      await _setLocale(languageCode);
    } else {
      log('Unsupported locale: $languageCode');
    }
  }

  /// Toggle between supported locales
  Future<void> toggleLocale() async {
    switch (state.languageCode) {
      case 'en':
        await setArabic();
        break;
      case 'ar':
        await setEnglish();
        break;
      default:
        await setEnglish();
        break;
    }
  }

  /// Internal method to set locale
  Future<void> _setLocale(String languageCode) async {
    try {
      final newLocale = Locale(languageCode);
      state = newLocale;
      await _saveLocale(languageCode);
      log('Locale set to: $languageCode');
    } catch (e) {
      log('Failed to set locale: $e');
      // Revert state if storage fails
      _loadLocale();
    }
  }

  /// Save locale to storage
  Future<void> _saveLocale(String languageCode) async {
    await StorageService.setSetting(AppConstants.localeKey, languageCode);
  }

  /// Get current language code
  String get languageCode => state.languageCode;

  /// Get current locale name
  String get localeName {
    switch (state.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  /// Check if current locale is Arabic (RTL)
  bool get isRTL => state.languageCode == 'ar';

  /// Check if current locale is English (LTR)
  bool get isLTR => state.languageCode == 'en';

  /// Check if current locale is English
  bool get isEnglish => state.languageCode == 'en';

  /// Check if current locale is Arabic
  bool get isArabic => state.languageCode == 'ar';

  /// Get text direction based on current locale
  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get available locales with their display names
  List<Map<String, String>> get availableLocales {
    return [
      {
        'code': 'en',
        'name': 'English',
        'nativeName': 'English',
      },
      {
        'code': 'ar',
        'name': 'Arabic',
        'nativeName': 'العربية',
      },
    ];
  }

  /// Get supported locales as Locale objects
  List<Locale> get supportedLocales {
    return AppConstants.supportedLocales.map((code) => Locale(code)).toList();
  }

  /// Reset locale to default
  Future<void> resetLocale() async {
    await setLocale(AppConstants.defaultLocale);
  }

  /// Get locale flag emoji
  String get flagEmoji {
    switch (state.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'ar':
        return '🇸🇦';
      default:
        return '🇺🇸';
    }
  }

  /// Format currency based on locale
  String formatCurrency(double amount, {String currency = 'USD'}) {
    switch (state.languageCode) {
      case 'ar':
        return '$amount $currency';
      case 'en':
      default:
        return '$currency $amount';
    }
  }

  /// Format date based on locale
  String formatDate(DateTime date) {
    switch (state.languageCode) {
      case 'ar':
        return '${date.day}/${date.month}/${date.year}';
      case 'en':
      default:
        return '${date.month}/${date.day}/${date.year}';
    }
  }

  /// Get greeting based on current time and locale
  String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (isArabic) {
      if (hour < 12) {
        return 'صباح الخير';
      } else if (hour < 17) {
        return 'مساء الخير';
      } else {
        return 'مساء الخير';
      }
    } else {
      if (hour < 12) {
        return 'Good Morning';
      } else if (hour < 17) {
        return 'Good Afternoon';
      } else {
        return 'Good Evening';
      }
    }
  }
}
