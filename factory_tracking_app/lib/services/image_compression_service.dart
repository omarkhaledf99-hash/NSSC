import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageCompressionService {
  static const int maxFileSizeBytes = 3 * 1024 * 1024; // 3MB
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int compressionQuality = 85;

  /// Compress a single image file
  static Future<File?> compressImage(File imageFile) async {
    try {
      // Read the image file
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Check if file is already under size limit
      if (imageBytes.length <= maxFileSizeBytes) {
        return imageFile;
      }

      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image if it's too large
      if (image.width > maxImageWidth || image.height > maxImageHeight) {
        image = img.copyResize(
          image,
          width: image.width > maxImageWidth ? maxImageWidth : null,
          height: image.height > maxImageHeight ? maxImageHeight : null,
          maintainAspect: true,
        );
      }

      // Compress the image
      List<int> compressedBytes;
      final String extension = imageFile.path.toLowerCase().split('.').last;
      
      if (extension == 'png') {
        compressedBytes = img.encodePng(image, level: 6);
      } else {
        compressedBytes = img.encodeJpg(image, quality: compressionQuality);
      }

      // If still too large, reduce quality further
      int quality = compressionQuality;
      while (compressedBytes.length > maxFileSizeBytes && quality > 20) {
        quality -= 10;
        compressedBytes = img.encodeJpg(image, quality: quality);
      }

      // Create a new file with compressed data
      final String compressedPath = imageFile.path.replaceAll(
        RegExp(r'\.[^.]+$'),
        '_compressed.jpg',
      );
      
      final File compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Compress multiple images
  static Future<List<File>> compressImages(List<File> imageFiles) async {
    final List<File> compressedImages = [];
    
    for (final File imageFile in imageFiles) {
      final File? compressedImage = await compressImage(imageFile);
      if (compressedImage != null) {
        compressedImages.add(compressedImage);
      }
    }
    
    return compressedImages;
  }

  /// Pick and compress multiple images from gallery
  static Future<List<File>> pickAndCompressImages({
    int maxImages = 5,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage(
        maxWidth: maxImageWidth.toDouble(),
        maxHeight: maxImageHeight.toDouble(),
        imageQuality: compressionQuality,
      );

      if (pickedFiles.isEmpty) {
        return [];
      }

      // Limit to maxImages
      final List<XFile> limitedFiles = pickedFiles.take(maxImages).toList();
      
      // Convert XFile to File and compress
      final List<File> imageFiles = limitedFiles
          .map((xFile) => File(xFile.path))
          .toList();
      
      return await compressImages(imageFiles);
    } catch (e) {
      print('Error picking and compressing images: $e');
      return [];
    }
  }

  /// Pick and compress a single image from camera
  static Future<File?> pickAndCompressImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxImageWidth.toDouble(),
        maxHeight: maxImageHeight.toDouble(),
        imageQuality: compressionQuality,
      );

      if (pickedFile == null) {
        return null;
      }

      final File imageFile = File(pickedFile.path);
      return await compressImage(imageFile);
    } catch (e) {
      print('Error picking and compressing image from camera: $e');
      return null;
    }
  }

  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    final int bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Check if file size is within limit
  static bool isFileSizeValid(File file) {
    return file.lengthSync() <= maxFileSizeBytes;
  }
}