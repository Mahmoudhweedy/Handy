/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AuthException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() {
    return 'AuthException: $message';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthException && 
           other.message == message && 
           other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Exception thrown when authentication is required but user is not signed in
class AuthRequiredException extends AuthException {
  const AuthRequiredException([String? message])
      : super(message ?? 'Authentication required');
}

/// Exception thrown when the authentication session has expired
class AuthSessionExpiredException extends AuthException {
  const AuthSessionExpiredException([String? message])
      : super(message ?? 'Authentication session expired');
}

/// Exception thrown when the user tries to access a feature they don't have permission for
class InsufficientPermissionsException extends AuthException {
  const InsufficientPermissionsException([String? message])
      : super(message ?? 'Insufficient permissions for this action');
}

/// Exception thrown when account verification is required
class AccountVerificationRequiredException extends AuthException {
  const AccountVerificationRequiredException([String? message])
      : super(message ?? 'Account verification required');
}

/// Exception thrown when too many authentication attempts have been made
class TooManyAttemptsException extends AuthException {
  const TooManyAttemptsException([String? message])
      : super(message ?? 'Too many failed attempts. Please try again later');
}
