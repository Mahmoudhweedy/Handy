import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'common/providers/auth_provider.dart';
import 'common/providers/locale_provider.dart';
import 'common/providers/theme_mode_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

class HandyApp extends ConsumerStatefulWidget {
  const HandyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<HandyApp> createState() => _HandyAppState();
}

class _HandyAppState extends ConsumerState<HandyApp> {
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final hasSeenOnboarding = StorageService.getSetting<bool>('has_seen_onboarding', defaultValue: false);
    setState(() {
      _isFirstTime = hasSeenOnboarding != true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final authState = ref.watch(authProvider);

    // Create router with current auth state
    final router = AppRouter.createRouter(
      isAuthenticated: authState.isAuthenticated,
      isFirstTime: _isFirstTime,
    );

    return MaterialApp.router(
      // App Configuration
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Routing
      routerConfig: router,
      
      // Theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // Localization
      locale: locale,
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('ar', 'SA'), // Arabic
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Accessibility & Performance
      showPerformanceOverlay: false,
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
      showSemanticsDebugger: false,
      
      // Builder for additional configuration
      builder: (context, child) {
        // Handle text scaling
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.3,
            ),
          ),
          child: child!,
        );
      },
      
      // Error handling
      // Note: Error handling is done in the router configuration
    );
  }
}

/// Provider that rebuilds the router when auth state changes
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isFirstTime = ref.watch(_isFirstTimeProvider);
  
  return AppRouter.createRouter(
    isAuthenticated: authState.isAuthenticated,
    isFirstTime: isFirstTime,
  );
});

/// Provider for first time user state
final _isFirstTimeProvider = StateProvider<bool>((ref) {
  final hasSeenOnboarding = StorageService.getSetting<bool>('has_seen_onboarding', defaultValue: false);
  return hasSeenOnboarding != true;
});
