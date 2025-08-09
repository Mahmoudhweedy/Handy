/// Base exception for storage-related errors
class StorageException implements Exception {
  const StorageException(this.message);
  final String message;

  @override
  String toString() => 'StorageException: $message';
}

/// Exception thrown when storage initialization fails
class StorageInitializationException extends StorageException {
  const StorageInitializationException(super.message);

  @override
  String toString() => 'StorageInitializationException: $message';
}

/// Exception thrown when secure storage operations fail
class SecureStorageException extends StorageException {
  const SecureStorageException(super.message);

  @override
  String toString() => 'SecureStorageException: $message';
}

/// Exception thrown when cache operations fail
class CacheException extends StorageException {
  const CacheException(super.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when data serialization/deserialization fails
class SerializationException extends StorageException {
  const SerializationException(super.message);

  @override
  String toString() => 'SerializationException: $message';
}
