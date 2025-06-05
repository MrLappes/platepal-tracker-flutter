import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  /// Converts an image file to base64 string
  static Future<String> convertImageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file does not exist: $imagePath');
      }

      final bytes = await file.readAsBytes();
      debugPrint('📷 ImageUtils: Image file size: ${bytes.length} bytes');

      final base64String = base64Encode(bytes);
      debugPrint(
        '📷 ImageUtils: Base64 string length: ${base64String.length} characters',
      );
      debugPrint(
        '📷 ImageUtils: Base64 string preview (first 100 chars): ${base64String.length > 100 ? base64String.substring(0, 100) : base64String}...',
      );
      debugPrint(
        '📷 ImageUtils: Base64 string preview (last 100 chars): ${base64String.length > 100 ? base64String.substring(base64String.length - 100) : base64String}',
      );

      return base64String;
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      rethrow;
    }
  }

  /// Checks if a model supports vision capabilities
  static bool isImageCapableModel(String model) {
    final imageCapableModels = ['vision', 'gpt-4o', 'gpt-4'];
    return imageCapableModels.any(
      (modelName) => model.toLowerCase().contains(modelName.toLowerCase()),
    );
  }

  /// Creates the data URL format for images
  static String createImageDataUrl(String base64Image, {String? imagePath}) {
    // Detect MIME type from file extension or default to JPEG
    String mimeType = 'image/jpeg';

    if (imagePath != null) {
      final extension = imagePath.toLowerCase().split('.').last;
      switch (extension) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        case 'bmp':
          mimeType = 'image/bmp';
          break;
        case 'jpg':
        case 'jpeg':
        default:
          mimeType = 'image/jpeg';
          break;
      }
    }

    return 'data:$mimeType;base64,$base64Image';
  }

  /// Resizes and encodes an image file to base64 JPEG, supporting high/low detail.
  static Future<String> resizeAndEncodeImage(
    String imagePath, {
    required bool isHighDetail,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Image file does not exist: $imagePath');
    }
    final bytes = await file.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) {
      throw Exception('Unable to decode image: $imagePath');
    }
    img.Image resizedImage;
    if (isHighDetail) {
      // High resolution: Scale down to fit within a 2048x2048 square
      if (originalImage.width > 2048 || originalImage.height > 2048) {
        int targetWidth =
            originalImage.width > originalImage.height ? 2048 : -1;
        int targetHeight =
            originalImage.height > originalImage.width ? 2048 : -1;
        resizedImage = img.copyResize(
          originalImage,
          width: targetWidth,
          height: targetHeight,
        );
      } else {
        resizedImage = originalImage;
      }
      // Further scale down so the shortest side is 768px
      int targetWidth = resizedImage.width < resizedImage.height ? 768 : -1;
      int targetHeight = resizedImage.height < resizedImage.width ? 768 : -1;
      resizedImage = img.copyResize(
        resizedImage,
        width: targetWidth,
        height: targetHeight,
      );
    } else {
      // Low resolution: Scale down so the shortest side is 512px
      int targetWidth = originalImage.width < originalImage.height ? 512 : -1;
      int targetHeight = originalImage.height < originalImage.width ? 512 : -1;
      resizedImage = img.copyResize(
        originalImage,
        width: targetWidth,
        height: targetHeight,
      );
    }
    final base64Image = base64Encode(img.encodeJpg(resizedImage));
    return base64Image;
  }
}
