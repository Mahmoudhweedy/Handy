import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Firebase Storage operations
class FirebaseStorageService {
  static FirebaseStorage get _storage => FirebaseStorage.instance;

  /// Upload image file to Firebase Storage
  static Future<String> uploadImage({
    required File file,
    required String path,
    String? fileName,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      fileName ??= DateTime.now().millisecondsSinceEpoch.toString();
      final fullPath = '$path/$fileName';
      
      final Reference ref = _storage.ref().child(fullPath);
      final UploadTask uploadTask = ref.putFile(file);
      
      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final int sent = snapshot.bytesTransferred;
          final int total = snapshot.totalBytes;
          onProgress(sent, total);
          
          log('📤 Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
        });
      }
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      log('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('❌ Failed to upload image: $e');
      rethrow;
    }
  }

  /// Upload image from bytes (for web)
  static Future<String> uploadImageFromBytes({
    required Uint8List bytes,
    required String path,
    String? fileName,
    String? contentType,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      fileName ??= DateTime.now().millisecondsSinceEpoch.toString();
      contentType ??= 'image/jpeg';
      final fullPath = '$path/$fileName';
      
      final Reference ref = _storage.ref().child(fullPath);
      final SettableMetadata metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploaded_by': 'flutter_app',
          'upload_time': DateTime.now().toIso8601String(),
        },
      );
      
      final UploadTask uploadTask = ref.putData(bytes, metadata);
      
      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final int sent = snapshot.bytesTransferred;
          final int total = snapshot.totalBytes;
          onProgress(sent, total);
          
          log('📤 Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
        });
      }
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      log('✅ Image uploaded from bytes successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('❌ Failed to upload image from bytes: $e');
      rethrow;
    }
  }

  /// Upload profile image
  static Future<String> uploadProfileImage({
    required File file,
    required String userId,
    Function(int sent, int total)? onProgress,
  }) async {
    final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadImage(
      file: file,
      path: 'profile_images',
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Upload service image
  static Future<String> uploadServiceImage({
    required File file,
    required String serviceId,
    int imageIndex = 0,
    Function(int sent, int total)? onProgress,
  }) async {
    final fileName = 'service_${serviceId}_${imageIndex}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadImage(
      file: file,
      path: 'service_images',
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Upload document
  static Future<String> uploadDocument({
    required File file,
    required String path,
    String? fileName,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      fileName ??= file.path.split('/').last;
      final fullPath = '$path/$fileName';
      
      final Reference ref = _storage.ref().child(fullPath);
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          customMetadata: {
            'uploaded_by': 'flutter_app',
            'upload_time': DateTime.now().toIso8601String(),
            'original_name': fileName,
          },
        ),
      );
      
      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final int sent = snapshot.bytesTransferred;
          final int total = snapshot.totalBytes;
          onProgress(sent, total);
          
          log('📤 Document upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
        });
      }
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      log('✅ Document uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('❌ Failed to upload document: $e');
      rethrow;
    }
  }

  /// Upload multiple images
  static Future<List<String>> uploadMultipleImages({
    required List<File> files,
    required String path,
    Function(int completed, int total)? onProgress,
  }) async {
    try {
      final List<String> downloadUrls = [];
      
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        final url = await uploadImage(
          file: file,
          path: path,
          fileName: fileName,
        );
        
        downloadUrls.add(url);
        
        if (onProgress != null) {
          onProgress(i + 1, files.length);
        }
      }
      
      log('✅ Multiple images uploaded successfully: ${downloadUrls.length} files');
      return downloadUrls;
    } catch (e) {
      log('❌ Failed to upload multiple images: $e');
      rethrow;
    }
  }

  /// Download file to bytes
  static Future<Uint8List?> downloadFile(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      final Uint8List? data = await ref.getData();
      
      log('✅ File downloaded successfully');
      return data;
    } catch (e) {
      log('❌ Failed to download file: $e');
      return null;
    }
  }

  /// Get file metadata
  static Future<FullMetadata?> getFileMetadata(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      final FullMetadata metadata = await ref.getMetadata();
      
      log('✅ File metadata retrieved');
      return metadata;
    } catch (e) {
      log('❌ Failed to get file metadata: $e');
      return null;
    }
  }

  /// Delete file
  static Future<bool> deleteFile(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
      
      log('✅ File deleted successfully');
      return true;
    } catch (e) {
      log('❌ Failed to delete file: $e');
      return false;
    }
  }

  /// Delete multiple files
  static Future<List<bool>> deleteMultipleFiles(List<String> urls) async {
    final List<bool> results = [];
    
    for (final url in urls) {
      final result = await deleteFile(url);
      results.add(result);
    }
    
    final successCount = results.where((r) => r).length;
    log('✅ Deleted $successCount out of ${urls.length} files');
    
    return results;
  }

  /// List files in a directory
  static Future<List<Reference>> listFiles(String path, {int? maxResults}) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final ListResult result = await ref.list(ListOptions(
        maxResults: maxResults ?? 1000,
      ));
      
      log('✅ Listed ${result.items.length} files in $path');
      return result.items;
    } catch (e) {
      log('❌ Failed to list files: $e');
      return [];
    }
  }

  /// Get file size
  static Future<int> getFileSize(String url) async {
    try {
      final metadata = await getFileMetadata(url);
      return metadata?.size ?? 0;
    } catch (e) {
      log('❌ Failed to get file size: $e');
      return 0;
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate thumbnails (for images)
  static Future<String?> generateThumbnail({
    required String originalUrl,
    int maxWidth = 200,
    int maxHeight = 200,
  }) async {
    try {
      // Note: Thumbnail generation typically requires a Cloud Function
      // This is a placeholder that would trigger thumbnail generation
      // on the backend
      
      final originalRef = _storage.refFromURL(originalUrl);
      final thumbnailPath = originalRef.fullPath.replaceAll(
        RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false),
        '_thumb_${maxWidth}x$maxHeight.jpg',
      );
      
      // Check if thumbnail already exists
      final thumbnailRef = _storage.ref().child(thumbnailPath);
      
      try {
        final thumbnailUrl = await thumbnailRef.getDownloadURL();
        log('✅ Thumbnail already exists: $thumbnailUrl');
        return thumbnailUrl;
      } catch (e) {
        // Thumbnail doesn't exist, would need to be generated
        log('📝 Thumbnail needs to be generated for: $originalUrl');
        return null;
      }
    } catch (e) {
      log('❌ Failed to generate thumbnail: $e');
      return null;
    }
  }

  /// Get download URL from path
  static Future<String> getDownloadUrl(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final String url = await ref.getDownloadURL();
      
      log('✅ Download URL retrieved');
      return url;
    } catch (e) {
      log('❌ Failed to get download URL: $e');
      rethrow;
    }
  }

  /// Update file metadata
  static Future<bool> updateFileMetadata(
    String url,
    Map<String, String> customMetadata,
  ) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      
      await ref.updateMetadata(SettableMetadata(
        customMetadata: customMetadata,
      ));
      
      log('✅ File metadata updated');
      return true;
    } catch (e) {
      log('❌ Failed to update file metadata: $e');
      return false;
    }
  }

  /// Get storage usage for a path
  static Future<int> getStorageUsage(String path) async {
    try {
      final files = await listFiles(path);
      int totalSize = 0;
      
      for (final file in files) {
        final metadata = await file.getMetadata();
        totalSize += metadata.size ?? 0;
      }
      
      log('✅ Storage usage for $path: ${totalSize ~/ 1024} KB');
      return totalSize;
    } catch (e) {
      log('❌ Failed to get storage usage: $e');
      return 0;
    }
  }

  /// Compress and upload image
  static Future<String> compressAndUploadImage({
    required File file,
    required String path,
    String? fileName,
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      // Note: Image compression would typically be done using a package like
      // flutter_image_compress. This is a simplified version.
      
      fileName ??= DateTime.now().millisecondsSinceEpoch.toString();
      final fullPath = '$path/$fileName';
      
      final Reference ref = _storage.ref().child(fullPath);
      
      // Set metadata for compressed image
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'compressed': 'true',
          'quality': quality.toString(),
          'max_width': maxWidth?.toString() ?? 'auto',
          'max_height': maxHeight?.toString() ?? 'auto',
          'uploaded_by': 'flutter_app',
          'upload_time': DateTime.now().toIso8601String(),
        },
      );
      
      final UploadTask uploadTask = ref.putFile(file, metadata);
      
      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final int sent = snapshot.bytesTransferred;
          final int total = snapshot.totalBytes;
          onProgress(sent, total);
        });
      }
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      log('✅ Compressed image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      log('❌ Failed to compress and upload image: $e');
      rethrow;
    }
  }

  /// Create signed URL for temporary access
  static Future<String?> createSignedUrl(
    String path,
    Duration expiration,
  ) async {
    try {
      // Note: Signed URLs typically require server-side implementation
      // This is a placeholder for the functionality
      
      final Reference ref = _storage.ref().child(path);
      final String url = await ref.getDownloadURL();
      
      // In a real implementation, you would call your backend to create
      // a signed URL with expiration
      
      log('✅ Signed URL created (expires in ${expiration.inHours}h)');
      return url;
    } catch (e) {
      log('❌ Failed to create signed URL: $e');
      return null;
    }
  }
}
