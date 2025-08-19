import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/services/firebase_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'firebase_options.dart';

/// Bootstrap function that initializes all necessary services
/// before running the app.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up error handling
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
    if (kReleaseMode) {
      // Report to crash analytics in production
      _reportError(details.exception, details.stack);
    }
  };

  // Handle errors outside of Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    log('PlatformDispatcher error: $error', stackTrace: stack);
    if (kReleaseMode) {
      _reportError(error, stack);
    }
    return true;
  };

  // Initialize services in order
  await _initializeServices();

  // Run the app with error monitoring
  if (kReleaseMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn = dotenv.env['SENTRY_DSN'];
        options.tracesSampleRate = 0.1;
        options.profilesSampleRate = 0.1;
        options.enableAutoPerformanceTracing = true;
        options.attachStacktrace = true;
        options.sendDefaultPii = false;
      },
      appRunner: () async {
        runApp(
          ProviderScope(
            child: await builder(),
          ),
        );
      },
    );
  } else {
    // Run without Sentry in development
    runApp(
      ProviderScope(
        child: await builder(),
      ),
    );
  }
}

/// Initialize all required services
Future<void> _initializeServices() async {
  try {
    // 1. Load environment variables
    await dotenv.load(fileName: '.env');
    log('✅ Environment variables loaded');

    // 2. Initialize Hive for local storage
    await Hive.initFlutter();
    log('✅ Hive initialized');

    // 3. Initialize Firebase Core with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('✅ Firebase Core initialized');

    // 4. Initialize Firestore
    await FirestoreService.initialize();
    log('✅ Firestore initialized');

    // 5. Initialize Firebase Services
    await FirebaseService.initialize();
    log('✅ Firebase Services initialized');

    // 6. Initialize Notification Service
    await NotificationService.initialize();
    log('✅ Notification Service initialized');

    // 7. Initialize Firebase Messaging Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    log('✅ Firebase Messaging background handler initialized');

    // 8. Initialize storage service
    await StorageService.initialize();
    log('✅ Storage service initialized');

    // 9. Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 10. Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    log('✅ All services initialized successfully');
  } catch (error, stackTrace) {
    log('❌ Service initialization failed: $error', stackTrace: stackTrace);
    rethrow;
  }
}

/// Report errors to crash analytics
void _reportError(Object error, StackTrace? stackTrace) {
  if (kReleaseMode) {
    Sentry.captureException(error, stackTrace: stackTrace);
  }
}

/// Firebase background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  log('Handling background message: ${message.messageId}');
  
  // Handle the background message here
  // You can show a local notification or update app badge
  // Example: Show local notification, update app badge, etc.
}

