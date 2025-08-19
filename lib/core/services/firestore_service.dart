import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/app_constants.dart';
import '../errors/firestore_exceptions.dart';

/// Service for managing Firestore database operations
class FirestoreService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Collections
  static const String _usersCollection = 'users';
  static const String _servicesCollection = 'services';
  static const String _bookingsCollection = 'bookings';
  static const String _reviewsCollection = 'reviews';
  static const String _categoriesCollection = 'categories';

  /// Initialize Firestore settings
  static Future<void> initialize() async {
    try {
      // Set up cache settings with persistence enabled
      _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      log('✅ Firestore initialized successfully');
    } catch (e) {
      log('❌ Firestore initialization failed: $e');
      // Firestore might already be initialized, continue
    }
  }

  /// User operations
  static Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _db.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return {'id': doc.id, ...?doc.data()};
    } catch (e) {
      log('❌ Failed to get user: $e');
      throw FirestoreException('Failed to get user data: $e');
    }
  }

  /// Create or update user
  static Future<void> setUser(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      await _db.collection(_usersCollection).doc(userId).set({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      log('✅ User data saved successfully');
    } catch (e) {
      log('❌ Failed to save user: $e');
      throw FirestoreException('Failed to save user data: $e');
    }
  }

  /// Update user profile
  static Future<void> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _db.collection(_usersCollection).doc(userId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      log('✅ User updated successfully');
    } catch (e) {
      log('❌ Failed to update user: $e');
      throw FirestoreException('Failed to update user: $e');
    }
  }

  /// Delete user
  static Future<void> deleteUser(String userId) async {
    try {
      await _db.collection(_usersCollection).doc(userId).delete();

      log('✅ User deleted successfully');
    } catch (e) {
      log('❌ Failed to delete user: $e');
      throw FirestoreException('Failed to delete user: $e');
    }
  }

  /// Service operations
  static Future<List<Map<String, dynamic>>> getServices({
    String? categoryId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _db.collection(_servicesCollection);

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      log('❌ Failed to get services: $e');
      throw FirestoreException('Failed to get services: $e');
    }
  }

  /// Get service by ID
  static Future<Map<String, dynamic>?> getService(String serviceId) async {
    try {
      final doc = await _db
          .collection(_servicesCollection)
          .doc(serviceId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return {'id': doc.id, ...?doc.data()};
    } catch (e) {
      log('❌ Failed to get service: $e');
      throw FirestoreException('Failed to get service: $e');
    }
  }

  /// Search services
  static Future<List<Map<String, dynamic>>> searchServices(
    String searchTerm, {
    String? categoryId,
    int limit = 20,
  }) async {
    try {
      Query query = _db.collection(_servicesCollection);

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      // Note: Firestore doesn't support full-text search natively
      // For production, consider using Algolia or Elasticsearch
      query = query
          .where('searchKeywords', arrayContainsAny: [searchTerm.toLowerCase()])
          .limit(limit);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      log('❌ Failed to search services: $e');
      throw FirestoreException('Failed to search services: $e');
    }
  }

  /// Booking operations
  static Future<String> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final docRef = await _db.collection(_bookingsCollection).add({
        ...bookingData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': AppConstants.bookingStatusPending,
      });

      log('✅ Booking created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      log('❌ Failed to create booking: $e');
      throw FirestoreException('Failed to create booking: $e');
    }
  }

  /// Get user bookings
  static Future<List<Map<String, dynamic>>> getUserBookings(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _db
          .collection(_bookingsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      log('❌ Failed to get user bookings: $e');
      throw FirestoreException('Failed to get user bookings: $e');
    }
  }

  /// Update booking status
  static Future<void> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      await _db.collection(_bookingsCollection).doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      log('✅ Booking status updated: $bookingId -> $status');
    } catch (e) {
      log('❌ Failed to update booking status: $e');
      throw FirestoreException('Failed to update booking status: $e');
    }
  }

  /// Review operations
  static Future<String> addReview(Map<String, dynamic> reviewData) async {
    try {
      final docRef = await _db.collection(_reviewsCollection).add({
        ...reviewData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      log('✅ Review added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      log('❌ Failed to add review: $e');
      throw FirestoreException('Failed to add review: $e');
    }
  }

  /// Get service reviews
  static Future<List<Map<String, dynamic>>> getServiceReviews(
    String serviceId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _db
          .collection(_reviewsCollection)
          .where('serviceId', isEqualTo: serviceId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      log('❌ Failed to get service reviews: $e');
      throw FirestoreException('Failed to get service reviews: $e');
    }
  }

  /// Category operations
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final snapshot = await _db
          .collection(_categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      log('❌ Failed to get categories: $e');
      throw FirestoreException('Failed to get categories: $e');
    }
  }

  /// Real-time listeners
  static Stream<Map<String, dynamic>?> watchUser(String userId) {
    return _db
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;

          return {'id': doc.id, ...?doc.data()};
        })
        .handleError((error) {
          log('❌ User stream error: $error');
          throw FirestoreException('Failed to watch user: $error');
        });
  }

  /// Watch booking updates
  static Stream<List<Map<String, dynamic>>> watchUserBookings(String userId) {
    return _db
        .collection(_bookingsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        })
        .handleError((error) {
          log('❌ Bookings stream error: $error');
          throw FirestoreException('Failed to watch bookings: $error');
        });
  }

  /// Batch operations
  static Future<void> batchWrite(
    List<FirestoreBatchOperation> operations,
  ) async {
    try {
      final batch = _db.batch();

      for (final operation in operations) {
        switch (operation.type) {
          case FirestoreBatchOperationType.set:
            batch.set(operation.reference, operation.data!);
            break;
          case FirestoreBatchOperationType.update:
            batch.update(operation.reference, operation.data!);
            break;
          case FirestoreBatchOperationType.delete:
            batch.delete(operation.reference);
            break;
        }
      }

      await batch.commit();
      log('✅ Batch operation completed');
    } catch (e) {
      log('❌ Batch operation failed: $e');
      throw FirestoreException('Batch operation failed: $e');
    }
  }

  /// Get collection reference
  static CollectionReference collection(String name) {
    return _db.collection(name);
  }

  /// Get document reference
  static DocumentReference document(String path) {
    return _db.doc(path);
  }

  /// Server timestamp
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();
}

/// Firestore batch operation
class FirestoreBatchOperation {
  final FirestoreBatchOperationType type;
  final DocumentReference reference;
  final Map<String, dynamic>? data;

  const FirestoreBatchOperation({
    required this.type,
    required this.reference,
    this.data,
  });

  factory FirestoreBatchOperation.set(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) {
    return FirestoreBatchOperation(
      type: FirestoreBatchOperationType.set,
      reference: reference,
      data: data,
    );
  }

  factory FirestoreBatchOperation.update(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) {
    return FirestoreBatchOperation(
      type: FirestoreBatchOperationType.update,
      reference: reference,
      data: data,
    );
  }

  factory FirestoreBatchOperation.delete(DocumentReference reference) {
    return FirestoreBatchOperation(
      type: FirestoreBatchOperationType.delete,
      reference: reference,
    );
  }
}

enum FirestoreBatchOperationType { set, update, delete }
