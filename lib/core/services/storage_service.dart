import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import '../constants/app_constants.dart';
import '../errors/storage_exceptions.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static late Box _settingsBox;
  static late Box _userBox;
  static late Box _productsBox;
  static late Box _cartBox;
  static late Box _ordersBox;
  static late Box _bookingsBox;
  static late Box _cacheBox;

  static Future<void> initialize() async {
    try {
      _settingsBox = await Hive.openBox(AppConstants.settingsBox);
      _userBox = await Hive.openBox(AppConstants.userBox);
      _productsBox = await Hive.openBox(AppConstants.productsBox);
      _cartBox = await Hive.openBox(AppConstants.cartBox);
      _ordersBox = await Hive.openBox(AppConstants.ordersBox);
      _bookingsBox = await Hive.openBox(AppConstants.bookingsBox);
      _cacheBox = await Hive.openBox(AppConstants.cacheBox);
      
      log('Storage service initialized successfully');
    } catch (e, stackTrace) {
      log('Failed to initialize storage service: $e', stackTrace: stackTrace);
      throw const StorageInitializationException('Failed to initialize storage');
    }
  }

  // Secure Storage Methods
  static Future<void> setSecureValue(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw const SecureStorageException('Failed to write secure value');
    }
  }

  static Future<String?> getSecureValue(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw const SecureStorageException('Failed to read secure value');
    }
  }

  static Future<void> deleteSecureValue(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw const SecureStorageException('Failed to delete secure value');
    }
  }

  static Future<void> clearSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw const SecureStorageException('Failed to clear secure storage');
    }
  }

  // Settings Storage
  static Future<void> setSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
    } catch (e) {
      throw const StorageException('Failed to save setting');
    }
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      return _settingsBox.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      log('Failed to get setting: $key, returning default');
      return defaultValue;
    }
  }

  static Future<void> deleteSetting(String key) async {
    try {
      await _settingsBox.delete(key);
    } catch (e) {
      throw const StorageException('Failed to delete setting');
    }
  }

  // User Data Storage
  static Future<void> setUserData(String key, Map<String, dynamic> userData) async {
    try {
      await _userBox.put(key, json.encode(userData));
    } catch (e) {
      throw const StorageException('Failed to save user data');
    }
  }

  static Map<String, dynamic>? getUserData(String key) {
    try {
      final String? data = _userBox.get(key);
      if (data != null) {
        return json.decode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      log('Failed to get user data: $key');
      return null;
    }
  }

  static Future<void> deleteUserData(String key) async {
    try {
      await _userBox.delete(key);
    } catch (e) {
      throw const StorageException('Failed to delete user data');
    }
  }

  static Future<void> clearUserData() async {
    try {
      await _userBox.clear();
    } catch (e) {
      throw const StorageException('Failed to clear user data');
    }
  }

  // Products Cache
  static Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    try {
      final cacheData = {
        'data': products,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await _productsBox.put('products_cache', json.encode(cacheData));
    } catch (e) {
      throw const StorageException('Failed to cache products');
    }
  }

  static List<Map<String, dynamic>>? getCachedProducts() {
    try {
      final String? data = _productsBox.get('products_cache');
      if (data != null) {
        final Map<String, dynamic> cacheData = json.decode(data);
        final int timestamp = cacheData['timestamp'];
        final int now = DateTime.now().millisecondsSinceEpoch;
        
        // Check if cache is still valid
        if (now - timestamp < AppConstants.cacheExpiry.inMilliseconds) {
          final List<dynamic> products = cacheData['data'];
          return products.cast<Map<String, dynamic>>();
        }
      }
      return null;
    } catch (e) {
      log('Failed to get cached products');
      return null;
    }
  }

  // Cart Storage
  static Future<void> saveCartItems(List<Map<String, dynamic>> cartItems) async {
    try {
      await _cartBox.put('cart_items', json.encode(cartItems));
    } catch (e) {
      throw const StorageException('Failed to save cart items');
    }
  }

  static List<Map<String, dynamic>> getCartItems() {
    try {
      final String? data = _cartBox.get('cart_items');
      if (data != null) {
        final List<dynamic> items = json.decode(data);
        return items.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      log('Failed to get cart items');
      return [];
    }
  }

  static Future<void> clearCart() async {
    try {
      await _cartBox.delete('cart_items');
    } catch (e) {
      throw const StorageException('Failed to clear cart');
    }
  }

  // Orders Storage
  static Future<void> saveOrder(String orderId, Map<String, dynamic> order) async {
    try {
      await _ordersBox.put(orderId, json.encode(order));
    } catch (e) {
      throw const StorageException('Failed to save order');
    }
  }

  static Map<String, dynamic>? getOrder(String orderId) {
    try {
      final String? data = _ordersBox.get(orderId);
      if (data != null) {
        return json.decode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      log('Failed to get order: $orderId');
      return null;
    }
  }

  static List<Map<String, dynamic>> getAllOrders() {
    try {
      final List<Map<String, dynamic>> orders = [];
      for (final key in _ordersBox.keys) {
        final String? data = _ordersBox.get(key);
        if (data != null) {
          final order = json.decode(data) as Map<String, dynamic>;
          orders.add(order);
        }
      }
      // Sort by date (newest first)
      orders.sort((a, b) {
        final aDate = DateTime.parse(a['createdAt'] ?? '');
        final bDate = DateTime.parse(b['createdAt'] ?? '');
        return bDate.compareTo(aDate);
      });
      return orders;
    } catch (e) {
      log('Failed to get all orders');
      return [];
    }
  }

  // Bookings Storage
  static Future<void> saveBooking(String bookingId, Map<String, dynamic> booking) async {
    try {
      await _bookingsBox.put(bookingId, json.encode(booking));
    } catch (e) {
      throw const StorageException('Failed to save booking');
    }
  }

  static Map<String, dynamic>? getBooking(String bookingId) {
    try {
      final String? data = _bookingsBox.get(bookingId);
      if (data != null) {
        return json.decode(data) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      log('Failed to get booking: $bookingId');
      return null;
    }
  }

  static List<Map<String, dynamic>> getAllBookings() {
    try {
      final List<Map<String, dynamic>> bookings = [];
      for (final key in _bookingsBox.keys) {
        final String? data = _bookingsBox.get(key);
        if (data != null) {
          final booking = json.decode(data) as Map<String, dynamic>;
          bookings.add(booking);
        }
      }
      // Sort by date (newest first)
      bookings.sort((a, b) {
        final aDate = DateTime.parse(a['scheduledAt'] ?? '');
        final bDate = DateTime.parse(b['scheduledAt'] ?? '');
        return bDate.compareTo(aDate);
      });
      return bookings;
    } catch (e) {
      log('Failed to get all bookings');
      return [];
    }
  }

  // Generic Cache
  static Future<void> setCache(String key, dynamic value, {Duration? expiry}) async {
    try {
      final cacheData = {
        'data': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry?.inMilliseconds ?? AppConstants.cacheExpiry.inMilliseconds,
      };
      await _cacheBox.put(key, json.encode(cacheData));
    } catch (e) {
      throw const StorageException('Failed to set cache');
    }
  }

  static T? getCache<T>(String key) {
    try {
      final String? data = _cacheBox.get(key);
      if (data != null) {
        final Map<String, dynamic> cacheData = json.decode(data);
        final int timestamp = cacheData['timestamp'];
        final int expiry = cacheData['expiry'];
        final int now = DateTime.now().millisecondsSinceEpoch;
        
        // Check if cache is still valid
        if (now - timestamp < expiry) {
          return cacheData['data'] as T?;
        } else {
          // Cache expired, delete it
          _cacheBox.delete(key);
        }
      }
      return null;
    } catch (e) {
      log('Failed to get cache: $key');
      return null;
    }
  }

  static Future<void> deleteCache(String key) async {
    try {
      await _cacheBox.delete(key);
    } catch (e) {
      throw const StorageException('Failed to delete cache');
    }
  }

  static Future<void> clearAllCache() async {
    try {
      await _cacheBox.clear();
    } catch (e) {
      throw const StorageException('Failed to clear all cache');
    }
  }

  // Storage Information
  static int getCacheSize() {
    return _cacheBox.length;
  }

  static List<String> getCacheKeys() {
    return _cacheBox.keys.cast<String>().toList();
  }

  // Cleanup Methods
  static Future<void> clearExpiredCache() async {
    try {
      final keysToDelete = <String>[];
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final key in _cacheBox.keys) {
        try {
          final String? data = _cacheBox.get(key);
          if (data != null) {
            final Map<String, dynamic> cacheData = json.decode(data);
            final int timestamp = cacheData['timestamp'];
            final int expiry = cacheData['expiry'];
            
            if (now - timestamp >= expiry) {
              keysToDelete.add(key as String);
            }
          }
        } catch (e) {
          // If we can't decode the data, mark it for deletion
          keysToDelete.add(key as String);
        }
      }

      for (final key in keysToDelete) {
        await _cacheBox.delete(key);
      }

      log('Cleared ${keysToDelete.length} expired cache entries');
    } catch (e) {
      throw const StorageException('Failed to clear expired cache');
    }
  }

  static Future<void> compactStorage() async {
    try {
      await _settingsBox.compact();
      await _userBox.compact();
      await _productsBox.compact();
      await _cartBox.compact();
      await _ordersBox.compact();
      await _bookingsBox.compact();
      await _cacheBox.compact();
      log('Storage compaction completed');
    } catch (e) {
      throw const StorageException('Failed to compact storage');
    }
  }
}
