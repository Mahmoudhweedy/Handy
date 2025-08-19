/// Exception thrown when Firestore operations fail
class FirestoreException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const FirestoreException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    return 'FirestoreException: $message${code != null ? ' (Code: $code)' : ''}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FirestoreException &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(message, code);
}

/// Common Firestore exception types
class FirestoreExceptions {
  static const FirestoreException networkError = FirestoreException(
    'Network error occurred. Please check your internet connection.',
    code: 'network-error',
  );

  static const FirestoreException permissionDenied = FirestoreException(
    'You do not have permission to perform this operation.',
    code: 'permission-denied',
  );

  static const FirestoreException notFound = FirestoreException(
    'The requested document was not found.',
    code: 'not-found',
  );

  static const FirestoreException alreadyExists = FirestoreException(
    'The document already exists.',
    code: 'already-exists',
  );

  static const FirestoreException quotaExceeded = FirestoreException(
    'Quota exceeded. Please try again later.',
    code: 'quota-exceeded',
  );

  static const FirestoreException cancelled = FirestoreException(
    'The operation was cancelled.',
    code: 'cancelled',
  );

  static const FirestoreException invalidArgument = FirestoreException(
    'Invalid argument provided.',
    code: 'invalid-argument',
  );

  static const FirestoreException unavailable = FirestoreException(
    'Service is currently unavailable. Please try again later.',
    code: 'unavailable',
  );
}
