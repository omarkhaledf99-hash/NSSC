import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static const int maxImageSizeMB = 3;
  static const int maxImageCount = 5;
  static const int compressionQuality = 85;
  static const int maxWidth = 1920;
  static const int maxHeight = 1080;

  /// Pick and compress image from camera or gallery
  static Future<File?> pickAndCompressImage({
    required ImageSource source,
    required BuildContext context,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: compressionQuality,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        return await _compressImageIfNeeded(imageFile, context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({
    required BuildContext context,
    int maxImages = maxImageCount,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: compressionQuality,
      );

      if (images.length > maxImages) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum $maxImages images allowed. Only first $maxImages will be selected.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      final List<File> compressedImages = [];
      final int imagesToProcess = images.length > maxImages ? maxImages : images.length;

      for (int i = 0; i < imagesToProcess; i++) {
        final File imageFile = File(images[i].path);
        final File? compressedImage = await _compressImageIfNeeded(imageFile, context);
        if (compressedImage != null) {
          compressedImages.add(compressedImage);
        }
      }

      return compressedImages;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return [];
  }

  /// Compress image if it exceeds size limit
  static Future<File?> _compressImageIfNeeded(File imageFile, BuildContext context) async {
    try {
      final int fileSizeInBytes = await imageFile.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > maxImageSizeMB) {
        // Try to compress further by reducing quality
        final ImagePicker picker = ImagePicker();
        final XFile? compressedImage = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: (maxWidth * 0.8).toDouble(),
          maxHeight: (maxHeight * 0.8).toDouble(),
          imageQuality: 60, // Lower quality for compression
        );

        if (compressedImage != null) {
          final File compressedFile = File(compressedImage.path);
          final int compressedSizeInBytes = await compressedFile.length();
          final double compressedSizeInMB = compressedSizeInBytes / (1024 * 1024);

          if (compressedSizeInMB <= maxImageSizeMB) {
            return compressedFile;
          }
        }

        // If still too large, show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image size must be less than ${maxImageSizeMB}MB. Please choose a smaller image.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }

      return imageFile;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    final int fileSizeInBytes = await file.length();
    return fileSizeInBytes / (1024 * 1024);
  }

  /// Format file size for display
  static String formatFileSize(double sizeInMB) {
    if (sizeInMB < 1) {
      return '${(sizeInMB * 1024).toStringAsFixed(0)} KB';
    }
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }

  /// Validate image count
  static bool canAddMoreImages(int currentCount, {int maxCount = maxImageCount}) {
    return currentCount < maxCount;
  }

  /// Get remaining image slots
  static int getRemainingSlots(int currentCount, {int maxCount = maxImageCount}) {
    return maxCount - currentCount;
  }
}