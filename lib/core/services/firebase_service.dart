import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../errors/auth_exceptions.dart';

class FirebaseService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  static GoogleSignIn get _googleSignIn => GoogleSignIn();

  /// Initialize Firebase services
  static Future<void> initialize() async {
    try {
      // Request notification permissions
      await _requestNotificationPermission();
      
      // Get FCM token for push notifications
      await _getFCMToken();
      
      log('✅ Firebase services initialized');
    } catch (e) {
      log('❌ Firebase services initialization failed: $e');
      rethrow;
    }
  }

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  /// Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  static Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      log('✅ User signed in: ${credential.user?.email}');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      log('❌ Sign in failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      log('❌ Unexpected sign in error: $e');
      throw const AuthException('An unexpected error occurred during sign in');
    }
  }

  /// Sign up with email and password
  static Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      log('✅ User registered: ${credential.user?.email}');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      log('❌ Sign up failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      log('❌ Unexpected sign up error: $e');
      throw const AuthException('An unexpected error occurred during sign up');
    }
  }

  /// Sign in with Google
  static Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      log('✅ User signed in with Google: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log('❌ Google sign in failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      log('❌ Unexpected Google sign in error: $e');
      throw const AuthException('An unexpected error occurred during Google sign in');
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Sign out from Firebase
      await _auth.signOut();
      
      log('✅ User signed out');
    } catch (e) {
      log('❌ Sign out failed: $e');
      throw const AuthException('Failed to sign out');
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      log('❌ Password reset failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      log('❌ Unexpected password reset error: $e');
      throw const AuthException('Failed to send password reset email');
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();
      log('✅ User profile updated');
    } on FirebaseAuthException catch (e) {
      log('❌ Profile update failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      log('❌ Unexpected profile update error: $e');
      throw const AuthException('Failed to update profile');
    }
  }

  /// Change password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      
      log('✅ Password changed successfully');
    } on FirebaseAuthException catch (e) {
      log('❌ Password change failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      log('❌ Unexpected password change error: $e');
      throw const AuthException('Failed to change password');
    }
  }

  /// Delete user account
  static Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Delete account
      await user.delete();
      
      log('✅ User account deleted');
    } on FirebaseAuthException catch (e) {
      log('❌ Account deletion failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      log('❌ Unexpected account deletion error: $e');
      throw const AuthException('Failed to delete account');
    }
  }

  /// Get FCM token for push notifications
  static Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      log('✅ FCM Token retrieved: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      log('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Request notification permission
  static Future<void> _requestNotificationPermission() async {
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

      log('✅ Notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      log('❌ Failed to request notification permission: $e');
    }
  }

  /// Get FCM token (public method)
  static Future<String?> _getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        log('✅ FCM Token: ${token.substring(0, 20)}...');
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          log('✅ FCM Token refreshed: ${newToken.substring(0, 20)}...');
          // Here you can send the new token to your server
        });
      }
      return token;
    } catch (e) {
      log('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /// Handle Firebase Auth exceptions and convert to custom exceptions
  static AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException('No user found with this email address');
      case 'wrong-password':
        return const AuthException('Incorrect password');
      case 'email-already-in-use':
        return const AuthException('An account already exists with this email');
      case 'weak-password':
        return const AuthException('Password is too weak');
      case 'invalid-email':
        return const AuthException('Invalid email address format');
      case 'user-disabled':
        return const AuthException('This account has been disabled');
      case 'too-many-requests':
        return const AuthException('Too many failed attempts. Please try again later');
      case 'operation-not-allowed':
        return const AuthException('This sign-in method is not enabled');
      case 'requires-recent-login':
        return const AuthException('Please sign in again to perform this action');
      default:
        return AuthException('Authentication error: ${e.message ?? e.code}');
    }
  }
}
