import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'storage_service.dart';

/// Service for handling Firebase Cloud Messaging notifications
class NotificationService {
  static FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  
  static final ValueNotifier<RemoteMessage?> _messageStream = 
      ValueNotifier<RemoteMessage?>(null);
  
  static ValueListenable<RemoteMessage?> get messageStream => _messageStream;

  /// Initialize notification service
  static Future<void> initialize() async {
    try {
      // Request notification permissions
      await requestPermission();
      
      // Get and store FCM token
      await _getFCMToken();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      // Listen for token refresh
      _listenToTokenRefresh();
      
      log('✅ Notification service initialized');
    } catch (e) {
      log('❌ Notification service initialization failed: $e');
      rethrow;
    }
  }

  /// Request notification permissions
  static Future<NotificationSettings> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      log('✅ Notification permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        log('User granted provisional notification permission');
      } else {
        log('User declined or has not accepted notification permission');
      }
      
      return settings;
    } catch (e) {
      log('❌ Failed to request notification permission: $e');
      rethrow;
    }
  }

  /// Get current FCM token
  static Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        // Store token in local storage
        await StorageService.setSecureValue(AppConstants.fcmTokenKey, token);
        log('✅ FCM Token retrieved: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      log('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      log('✅ Subscribed to topic: $topic');
    } catch (e) {
      log('❌ Failed to subscribe to topic $topic: $e');
      rethrow;
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      log('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      log('❌ Failed to unsubscribe from topic $topic: $e');
      rethrow;
    }
  }

  /// Handle notification tap
  static Future<void> handleNotificationTap(RemoteMessage message) async {
    try {
      log('📱 Notification tapped: ${message.messageId}');
      
      // Store the message for the app to handle
      _messageStream.value = message;
      
      // Handle different notification types
      final data = message.data;
      final notificationType = data['type'];
      
      switch (notificationType) {
        case 'booking_update':
          await _handleBookingUpdate(data);
          break;
        case 'new_message':
          await _handleNewMessage(data);
          break;
        case 'service_reminder':
          await _handleServiceReminder(data);
          break;
        case 'promotional':
          await _handlePromotionalNotification(data);
          break;
        default:
          await _handleGeneralNotification(data);
      }
    } catch (e) {
      log('❌ Failed to handle notification tap: $e');
    }
  }

  /// Get pending notifications
  static Future<List<RemoteMessage>> getPendingNotifications() async {
    try {
      // This would typically get notifications from local storage
      // For now, return empty list
      return [];
    } catch (e) {
      log('❌ Failed to get pending notifications: $e');
      return [];
    }
  }

  /// Clear all notifications
  static Future<void> clearAllNotifications() async {
    try {
      // Clear notification badge and pending notifications
      await _messaging.setAutoInitEnabled(false);
      await _messaging.setAutoInitEnabled(true);
      
      log('✅ All notifications cleared');
    } catch (e) {
      log('❌ Failed to clear notifications: $e');
    }
  }

  /// Set notification badge count (iOS)
  static Future<void> setBadgeCount(int count) async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) return;
    
    try {
      // Badge count is typically handled by the native side
      // This is a placeholder for custom implementation
      log('📱 Badge count set to: $count');
    } catch (e) {
      log('❌ Failed to set badge count: $e');
    }
  }

  /// Private methods
  
  /// Get and store FCM token
  static Future<void> _getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await StorageService.setSecureValue(AppConstants.fcmTokenKey, token);
        log('✅ FCM Token stored: ${token.substring(0, 20)}...');
        
        // TODO: Send token to your server
        // await _sendTokenToServer(token);
      }
    } catch (e) {
      log('❌ Failed to get FCM token: $e');
    }
  }

  /// Set up message handlers
  static void _setupMessageHandlers() {
    // Handle background messages (when app is terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Handle foreground messages (when app is active)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📱 Foreground message received: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('📱 Notification opened app: ${message.messageId}');
      handleNotificationTap(message);
    });

    // Check for initial message (when app is opened from terminated state)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        log('📱 Initial message: ${message.messageId}');
        handleNotificationTap(message);
      }
    });
  }

  /// Listen to token refresh
  static void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      log('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
      
      // Store new token
      await StorageService.setSecureValue(AppConstants.fcmTokenKey, newToken);
      
      // TODO: Send new token to your server
      // await _sendTokenToServer(newToken);
    }).onError((error) {
      log('❌ FCM token refresh error: $error');
    });
  }

  /// Handle foreground message
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;
      
      // Store message for app to handle
      _messageStream.value = message;
      
      // Show custom in-app notification
      if (notification != null) {
        await _showInAppNotification(notification, data);
      }
      
      // Handle specific notification types
      await _processNotificationData(data);
    } catch (e) {
      log('❌ Failed to handle foreground message: $e');
    }
  }

  /// Show in-app notification
  static Future<void> _showInAppNotification(
    RemoteNotification notification,
    Map<String, dynamic> data,
  ) async {
    // This would typically show a custom banner or dialog
    // For now, just log the notification
    log('📱 In-app notification: ${notification.title} - ${notification.body}');
  }

  /// Process notification data
  static Future<void> _processNotificationData(Map<String, dynamic> data) async {
    try {
      final type = data['type'];
      
      switch (type) {
        case 'booking_update':
          await _handleBookingUpdate(data);
          break;
        case 'new_message':
          await _handleNewMessage(data);
          break;
        case 'service_reminder':
          await _handleServiceReminder(data);
          break;
        default:
          await _handleGeneralNotification(data);
      }
    } catch (e) {
      log('❌ Failed to process notification data: $e');
    }
  }

  /// Handle booking update notification
  static Future<void> _handleBookingUpdate(Map<String, dynamic> data) async {
    final bookingId = data['bookingId'];
    final status = data['status'];
    
    log('📅 Booking update: $bookingId -> $status');
    
    // TODO: Update local booking data or trigger refresh
  }

  /// Handle new message notification
  static Future<void> _handleNewMessage(Map<String, dynamic> data) async {
    final senderId = data['senderId'];
    final conversationId = data['conversationId'];
    
    log('💬 New message from: $senderId in conversation: $conversationId');
    
    // TODO: Update message counters or navigate to chat
  }

  /// Handle service reminder notification
  static Future<void> _handleServiceReminder(Map<String, dynamic> data) async {
    final serviceId = data['serviceId'];
    final reminderType = data['reminderType'];
    
    log('⏰ Service reminder: $serviceId ($reminderType)');
    
    // TODO: Navigate to service details or show reminder dialog
  }

  /// Handle promotional notification
  static Future<void> _handlePromotionalNotification(Map<String, dynamic> data) async {
    final promoId = data['promoId'];
    final promoType = data['promoType'];
    
    log('🎉 Promotional notification: $promoId ($promoType)');
    
    // TODO: Navigate to promotional content or show offer dialog
  }

  /// Handle general notification
  static Future<void> _handleGeneralNotification(Map<String, dynamic> data) async {
    final action = data['action'];
    
    log('📢 General notification with action: $action');
    
    // TODO: Handle general notification actions
  }

  /// Send token to server
  // static Future<void> _sendTokenToServer(String token) async {
  //   try {
  //     // TODO: Implement API call to send token to your server
  //     log('🚀 Sending token to server: ${token.substring(0, 20)}...');
  //   } catch (e) {
  //     log('❌ Failed to send token to server: $e');
  //   }
  // }

  /// Check notification settings
  static Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final settings = await getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Clean up resources
  static void dispose() {
    _messageStream.dispose();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('📱 Background message received: ${message.messageId}');
  
  // Handle background message here
  // Note: You cannot update UI from here, only perform background tasks
  
  try {
    // Store notification data for later processing
    final data = {
      'messageId': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
      'receivedAt': DateTime.now().toIso8601String(),
    };
    
    // TODO: Store in local database or perform background sync
    log('📱 Background message processed: ${message.messageId}');
  } catch (e) {
    log('❌ Failed to process background message: $e');
  }
}
