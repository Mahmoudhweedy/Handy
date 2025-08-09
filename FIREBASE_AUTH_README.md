# Firebase Authentication Implementation

This document describes the Firebase Authentication integration implemented in the Handy app.

## Overview

The Firebase Authentication service provides secure user authentication with multiple sign-in methods including email/password and Google Sign-In. The implementation follows clean architecture principles and integrates seamlessly with the existing Riverpod state management.

## Architecture

### Core Components

1. **FirebaseService** (`lib/core/services/firebase_service.dart`)
   - Static service class for Firebase operations
   - Handles authentication, FCM tokens, and Firebase initialization
   - Provides methods for sign-in, sign-up, sign-out, and user management

2. **AuthProvider** (`lib/common/providers/auth_provider.dart`)
   - Riverpod StateNotifier that manages authentication state
   - Integrates with FirebaseService for authentication operations
   - Handles local storage and FCM token management
   - Listens to Firebase auth state changes for automatic synchronization

3. **AuthException** (`lib/core/errors/auth_exceptions.dart`)
   - Custom exception classes for authentication errors
   - Provides user-friendly error messages
   - Handles Firebase-specific error codes

## Features

### Authentication Methods

- **Email/Password Authentication**
  - User registration with email verification
  - Secure sign-in with validation
  - Password reset functionality

- **Google Sign-In**
  - One-tap Google authentication
  - Automatic user profile synchronization

- **User Management**
  - Profile updates (name, photo)
  - Password change functionality
  - Account deletion with re-authentication

### Security Features

- **Token Management**
  - Secure storage of authentication tokens
  - Automatic token refresh
  - FCM token handling for push notifications

- **Session Management**
  - Automatic sign-out on token expiration
  - External auth state synchronization
  - Persistent login across app restarts

## Setup

### Prerequisites

1. **Firebase Project Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in your project
   firebase init
   ```

2. **Android Configuration**
   - Add `google-services.json` to `android/app/`
   - Ensure build.gradle.kts files are properly configured

3. **iOS Configuration** (if needed)
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Configure URL schemes and other settings

### Environment Variables

Update your `.env` file with the following:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key_here
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:android:abcdef123456
FIREBASE_MEASUREMENT_ID=G-ABCDEFGHIJ

# Sentry Configuration
SENTRY_DSN=your_sentry_dsn_here
```

## Usage Examples

### Basic Authentication

```dart
// Get the auth provider
final authNotifier = ref.read(authProvider.notifier);

// Sign up with email/password
await authNotifier.signUpWithEmail(
  email: 'user@example.com',
  password: 'securePassword123',
  firstName: 'John',
  lastName: 'Doe',
);

// Sign in with email/password
await authNotifier.signInWithEmail(
  'user@example.com',
  'securePassword123',
);

// Sign in with Google
await authNotifier.signInWithGoogle();

// Sign out
await authNotifier.signOut();
```

### Password Management

```dart
// Send password reset email
await authNotifier.sendPasswordResetEmail('user@example.com');

// Change password (requires current password)
await authNotifier.changePassword(
  currentPassword: 'oldPassword',
  newPassword: 'newPassword123',
);
```

### Profile Management

```dart
// Update user profile
await authNotifier.updateProfile(
  firstName: 'Jane',
  lastName: 'Smith',
  phoneNumber: '+1234567890',
);

// Delete account (requires password)
await authNotifier.deleteAccount('currentPassword');
```

### State Management

```dart
// Watch authentication state
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (authState.isLoading) {
      return const CircularProgressIndicator();
    }
    
    if (authState.isAuthenticated) {
      return HomePage();
    }
    
    return LoginPage();
  }
}
```

## Error Handling

The implementation provides comprehensive error handling:

```dart
try {
  await authNotifier.signInWithEmail(email, password);
} on AuthException catch (e) {
  // Handle authentication errors
  showSnackBar(e.message);
} catch (e) {
  // Handle unexpected errors
  showSnackBar('An unexpected error occurred');
}
```

### Common Error Codes

- `user-not-found`: No user found with the provided email
- `wrong-password`: Invalid password
- `email-already-in-use`: Email already registered
- `weak-password`: Password doesn't meet security requirements
- `too-many-requests`: Too many failed attempts
- `requires-recent-login`: Operation requires recent authentication

## Testing

### Example Widget

A complete example authentication widget is available at:
`lib/features/auth/presentation/widgets/firebase_auth_example.dart`

This widget demonstrates:
- Email/password authentication forms
- Google Sign-In integration
- Password reset functionality
- Profile management
- Error handling and loading states

### Running Tests

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Test specific authentication flows
flutter test test/auth/
```

## Monitoring and Analytics

### Firebase Console

Monitor authentication metrics in the Firebase Console:
- User sign-ups and sign-ins
- Authentication method usage
- Error rates and types
- User engagement metrics

### Sentry Integration

Authentication errors are automatically reported to Sentry in release mode:
- Exception tracking
- Performance monitoring
- User context for debugging

## Security Considerations

1. **Token Security**
   - Tokens are stored in secure storage (Keychain/Keystore)
   - Automatic token refresh prevents exposure
   - Clear tokens on sign-out

2. **Password Requirements**
   - Minimum 6 characters (configurable)
   - Encourage strong passwords in UI
   - Firebase handles secure hashing

3. **Network Security**
   - All Firebase communication is over HTTPS
   - Certificate pinning for additional security
   - Token-based authentication

4. **Data Privacy**
   - User data stored securely in Firebase
   - GDPR compliance features available
   - User can delete their account and data

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Ensure google-services.json is in android/app/
   - Check that google-services plugin is applied
   - Verify repository configurations in build.gradle

2. **Authentication Errors**
   - Check Firebase project configuration
   - Verify API keys and project IDs
   - Ensure authentication methods are enabled in Firebase Console

3. **Google Sign-In Issues**
   - Verify SHA-1 certificates in Firebase Console
   - Check Google Sign-In configuration
   - Ensure proper OAuth consent screen setup

### Debugging

Enable Firebase debugging:

```dart
// In bootstrap.dart
if (kDebugMode) {
  // Enable Firebase Auth debug logging
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

## Future Enhancements

1. **Additional Authentication Methods**
   - Apple Sign-In
   - Phone number authentication
   - Facebook/Twitter login

2. **Enhanced Security**
   - Biometric authentication
   - Multi-factor authentication (MFA)
   - Advanced threat protection

3. **User Experience**
   - Social profile import
   - Progressive profile completion
   - Authentication analytics

4. **Advanced Features**
   - Custom claims and roles
   - Anonymous authentication
   - Account linking

## Support

For issues and questions:
1. Check Firebase documentation
2. Review Flutter Firebase documentation
3. Check GitHub issues and discussions
4. Contact the development team
