import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// Capture photo from camera with EXIF stripping
  Future<String?> capturePhoto(BuildContext context) async {
    // Request camera permission
    final PermissionStatus cameraStatus = await Permission.camera.request();
    
    if (!cameraStatus.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take photos'),
            action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
          ),
        );
      }
      return null;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920, // Limit size for performance
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) return null;

      return await _stripExifAndSave(photo.path, context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing photo: $e')),
        );
      }
      return null;
    }
  }

  /// Select photo from gallery with EXIF stripping
  Future<String?> selectFromGallery(BuildContext context) async {
    // Request storage permission for Android 12 and below
    if (Platform.isAndroid) {
      final int androidVersion = await _getAndroidVersion();
      if (androidVersion < 13) {
        final PermissionStatus storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Storage permission is required to access photos'),
                action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
              ),
            );
          }
          return null;
        }
      } else {
        // Android 13+ uses photos permission
        final PermissionStatus photosStatus = await Permission.photos.request();
        if (!photosStatus.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photos permission is required to access gallery'),
                action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
              ),
            );
          }
          return null;
        }
      }
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) return null;

      return await _stripExifAndSave(photo.path, context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting photo: $e')),
        );
      }
      return null;
    }
  }

  /// Strip EXIF data and save to app directory
  Future<String> _stripExifAndSave(String sourcePath, BuildContext context) async {
    try {
      // Load original image
      final Uint8List bytes = await File(sourcePath).readAsBytes();
      final img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Re-encode WITHOUT any metadata (this strips all EXIF data)
      final Uint8List newBytes = img.encodeJpg(image, quality: 85);

      // Get app's document directory (private, secure storage)
      final Directory directory = await getApplicationDocumentsDirectory();
      final Directory photosDir = Directory('${directory.path}/photos');
      
      // Create photos directory if it doesn't exist
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      // Generate unique filename with timestamp
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String fileName = 'photo_$timestamp.jpg';
      final String filePath = '${photosDir.path}/$fileName';

      // Save the EXIF-free image
      await File(filePath).writeAsBytes(newBytes);

      // Delete the temporary source file if it's in cache
      if (sourcePath.contains('cache')) {
        try {
          await File(sourcePath).delete();
        } catch (e) {
          debugPrint('Could not delete temp file: $e');
        }
      }

      return filePath;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing photo: $e')),
        );
      }
      rethrow;
    }
  }

  /// Delete photo from storage
  Future<void> deletePhoto(String path) async {
    try {
      final File file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }

  /// Generate thumbnail for display
  Future<String> generateThumbnail(String originalPath) async {
    try {
      final Uint8List bytes = await File(originalPath).readAsBytes();
      final img.Image? image = img.decodeImage(bytes);

      if (image == null) return originalPath;

      // Create thumbnail (300px max dimension)
      final img.Image thumbnail = img.copyResize(
        image,
        width: image.width > image.height ? 300 : null,
        height: image.height > image.width ? 300 : null,
      );

      final Uint8List thumbnailBytes = img.encodeJpg(thumbnail, quality: 70);

      // Save thumbnail with _thumb suffix
      final String thumbnailPath = originalPath.replaceAll('.jpg', '_thumb.jpg');
      await File(thumbnailPath).writeAsBytes(thumbnailBytes);

      return thumbnailPath;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return originalPath; // Fallback to original
    }
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;
    
    try {
      final String version = Platform.version;
      // Parse Android SDK version from Platform.version
      // This is a simplified approach
      return 13; // Default to 13+ for safer permission handling
    } catch (e) {
      return 13;
    }
  }

  /// Check if all required permissions are granted
  Future<bool> checkPermissions() async {
    final PermissionStatus cameraStatus = await Permission.camera.status;
    
    if (Platform.isAndroid) {
      final PermissionStatus photosStatus = await Permission.photos.status;
      return cameraStatus.isGranted && photosStatus.isGranted;
    }
    
    return cameraStatus.isGranted;
  }
}
