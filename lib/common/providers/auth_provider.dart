import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/auth_exceptions.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';

/// Authentication state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? user;
  final String? token;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? user,
    String? token,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error ?? this.error,
    );
  }
}

/// Provider for managing authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Notifier for authentication changes
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
    _listenToFirebaseAuthChanges();
  }

  Timer? _tokenRefreshTimer;
  StreamSubscription<firebase_auth.User?>? _authStateSubscription;

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Check Firebase auth state first
      final firebaseUser = FirebaseService.currentUser;
      
      if (firebaseUser != null) {
        // Convert Firebase user to UserModel
        final userModel = _firebaseUserToUserModel(firebaseUser);
        
        // Get FCM token for notifications
        final fcmToken = await FirebaseService.getFCMToken();
        if (fcmToken != null) {
          await StorageService.setSecureValue(AppConstants.fcmTokenKey, fcmToken);
        }
        
        // Save to local storage
        await _saveAuthData(userModel, firebaseUser.uid);
        
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userModel,
          token: firebaseUser.uid,
          error: null,
        );
        
        log('User authenticated: ${userModel.email}');
      } else {
        // Check local storage as fallback
        final String? token = await StorageService.getSecureValue(AppConstants.authTokenKey);
        final Map<String, dynamic>? userData = StorageService.getUserData(AppConstants.userDataKey);
        
        if (token != null && userData != null) {
          final user = UserModel.fromJson(userData);
          
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: user,
            token: token,
            error: null,
          );
          
          log('User authenticated from local storage: ${user.email}');
        } else {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
          );
        }
      }
    } catch (e) {
      log('Failed to initialize auth: $e');
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: 'Failed to initialize authentication',
      );
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final firebaseUser = await FirebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (firebaseUser != null) {
        final userModel = _firebaseUserToUserModel(firebaseUser);
        
        // Get FCM token for notifications
        final fcmToken = await FirebaseService.getFCMToken();
        if (fcmToken != null) {
          await StorageService.setSecureValue(AppConstants.fcmTokenKey, fcmToken);
        }
        
        // Save auth data
        await _saveAuthData(userModel, firebaseUser.uid);
        
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userModel,
          token: firebaseUser.uid,
          error: null,
        );
        
        log('User signed in: $email');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Sign in failed',
        );
      }
    } on AuthException catch (e) {
      log('Sign in failed: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      log('Sign in failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final displayName = '$firstName $lastName';
      final firebaseUser = await FirebaseService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (firebaseUser != null) {
        final userModel = _firebaseUserToUserModel(firebaseUser).copyWith(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
        );
        
        // Get FCM token for notifications
        final fcmToken = await FirebaseService.getFCMToken();
        if (fcmToken != null) {
          await StorageService.setSecureValue(AppConstants.fcmTokenKey, fcmToken);
        }
        
        // Save auth data
        await _saveAuthData(userModel, firebaseUser.uid);
        
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userModel,
          token: firebaseUser.uid,
          error: null,
        );
        
        log('User signed up: $email');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed',
        );
      }
    } on AuthException catch (e) {
      log('Sign up failed: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      log('Sign up failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed. Please try again.',
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final firebaseUser = await FirebaseService.signInWithGoogle();
      
      if (firebaseUser != null) {
        final userModel = _firebaseUserToUserModel(firebaseUser);
        
        // Get FCM token for notifications
        final fcmToken = await FirebaseService.getFCMToken();
        if (fcmToken != null) {
          await StorageService.setSecureValue(AppConstants.fcmTokenKey, fcmToken);
        }
        
        await _saveAuthData(userModel, firebaseUser.uid);
        
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: userModel,
          token: firebaseUser.uid,
          error: null,
        );
        
        log('User signed in with Google: ${userModel.email}');
      } else {
        // User canceled sign in
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      }
    } on AuthException catch (e) {
      log('Google sign in failed: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      log('Google sign in failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign in failed',
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseService.sendPasswordResetEmail(email);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to send password reset email: $e');
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Cancel token refresh timer
      _tokenRefreshTimer?.cancel();
      
      // Sign out from Firebase
      await FirebaseService.signOut();
      
      // Clear auth data
      await _clearAuthData();
      await StorageService.deleteSecureValue(AppConstants.fcmTokenKey);
      
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
      
      log('User signed out');
    } catch (e) {
      log('Sign out failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign out',
      );
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (!state.isAuthenticated || state.user == null) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedUser = state.user!.copyWith(
        firstName: firstName ?? state.user!.firstName,
        lastName: lastName ?? state.user!.lastName,
        phoneNumber: phoneNumber ?? state.user!.phoneNumber,
        profileImageUrl: profileImageUrl ?? state.user!.profileImageUrl,
        updatedAt: DateTime.now(),
      );
      
      // Save updated user data
      await StorageService.setUserData(AppConstants.userDataKey, updatedUser.toJson());
      
      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
        error: null,
      );
      
      log('User profile updated');
    } catch (e) {
      log('Profile update failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile',
      );
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!state.isAuthenticated) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await FirebaseService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
      
      log('Password changed successfully');
    } on AuthException catch (e) {
      log('Password change failed: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      log('Password change failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to change password',
      );
    }
  }

  /// Delete user account
  Future<void> deleteAccount(String password) async {
    if (!state.isAuthenticated) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await FirebaseService.deleteAccount(password);
      
      // Clear all user data
      await _clearAuthData();
      await StorageService.clearUserData();
      await StorageService.deleteSecureValue(AppConstants.fcmTokenKey);
      
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
      
      log('User account deleted');
    } on AuthException catch (e) {
      log('Account deletion failed: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      log('Account deletion failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete account',
      );
    }
  }

  /// Refresh authentication token
  Future<void> refreshToken() async {
    if (!state.isAuthenticated || state.token == null) {
      return;
    }
    
    try {
      // Simulate token refresh
      await Future.delayed(const Duration(milliseconds: 500));
      
      final newToken = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      
      await StorageService.setSecureValue(AppConstants.authTokenKey, newToken);
      
      state = state.copyWith(token: newToken);
      
      log('Token refreshed');
    } catch (e) {
      log('Token refresh failed: $e');
      // If token refresh fails, sign out the user
      await signOut();
    }
  }

  /// Validate token (mock implementation)
  Future<bool> _validateToken(String token) async {
    try {
      // In a real app, you would validate with your backend
      // For demo, we'll just check if it's not empty and not expired
      return token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Save authentication data
  Future<void> _saveAuthData(UserModel user, String token) async {
    await StorageService.setSecureValue(AppConstants.authTokenKey, token);
    await StorageService.setUserData(AppConstants.userDataKey, user.toJson());
  }

  /// Clear authentication data
  Future<void> _clearAuthData() async {
    await StorageService.deleteSecureValue(AppConstants.authTokenKey);
    await StorageService.deleteUserData(AppConstants.userDataKey);
  }

  /// Set up token refresh timer
  void _setupTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    
    // Refresh token every 15 minutes
    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => refreshToken(),
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Listen to Firebase auth state changes
  void _listenToFirebaseAuthChanges() {
    _authStateSubscription = FirebaseService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser == null && state.isAuthenticated) {
        // User signed out externally
        _handleExternalSignOut();
      } else if (firebaseUser != null && !state.isAuthenticated) {
        // User signed in externally
        _handleExternalSignIn(firebaseUser);
      }
    });
  }
  
  /// Handle sign out from external source
  Future<void> _handleExternalSignOut() async {
    await _clearAuthData();
    await StorageService.deleteSecureValue(AppConstants.fcmTokenKey);
    state = const AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
    log('User signed out externally');
  }
  
  /// Handle sign in from external source
  Future<void> _handleExternalSignIn(firebase_auth.User firebaseUser) async {
    try {
      final userModel = _firebaseUserToUserModel(firebaseUser);
      
      // Get FCM token for notifications
      final fcmToken = await FirebaseService.getFCMToken();
      if (fcmToken != null) {
        await StorageService.setSecureValue(AppConstants.fcmTokenKey, fcmToken);
      }
      
      await _saveAuthData(userModel, firebaseUser.uid);
      
      state = state.copyWith(
        isAuthenticated: true,
        user: userModel,
        token: firebaseUser.uid,
        error: null,
      );
      
      log('User signed in externally: ${userModel.email}');
    } catch (e) {
      log('Failed to handle external sign in: $e');
      state = state.copyWith(
        error: 'Failed to sync external sign in',
      );
    }
  }
  
  /// Convert Firebase user to UserModel
  UserModel _firebaseUserToUserModel(firebase_auth.User firebaseUser) {
    final displayNameParts = firebaseUser.displayName?.split(' ') ?? ['User'];
    final firstName = displayNameParts.first;
    final lastName = displayNameParts.length > 1 
        ? displayNameParts.sublist(1).join(' ')
        : '';
    
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      firstName: firstName,
      lastName: lastName,
      profileImageUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
      isPhoneVerified: false,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
